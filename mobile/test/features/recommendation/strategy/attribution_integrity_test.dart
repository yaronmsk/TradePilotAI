import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/event_risk_confidence_adjuster.dart';
import 'package:mobile/features/recommendation/context/external_context_profile.dart';
import 'package:mobile/features/recommendation/engines/consensus_engine.dart';
import 'package:mobile/features/recommendation/history/historical_confidence_adjuster.dart';
import 'package:mobile/features/recommendation/history/historical_setup_validation.dart';
import 'package:mobile/features/recommendation/models/evidence_definition.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_report.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';

void main() {
  const engine = ConsensusEngine();
  const eventAdjuster = EventRiskConfidenceAdjuster();
  const historicalAdjuster = HistoricalConfidenceAdjuster();

  EvidenceResult evidence({
    required String name,
    required EvidenceFamily family,
    required EvidenceDirection direction,
    required double score,
    double weight = 1,
  }) {
    return EvidenceResult(
      providerName: name,
      definition: EvidenceDefinition(
        family: family,
        name: name,
        description: 'Attribution integrity test evidence.',
        whyItMatters: 'Tests attribution reconciliation.',
        calculation: 'Deterministic test input.',
      ),
      status: EvidenceStatus.available,
      direction: direction,
      strength: EvidenceStrength.strong,
      score: score,
      baseWeight: weight,
      dynamicWeight: 1,
      reliability: 1,
      currentValue: 'test',
      baselineValue: 'test',
      relativeValue: 'test',
      explanation: 'test',
    );
  }

  EvidenceReport report(List<EvidenceResult> results) {
    return EvidenceReport.fromResults(
      results: results,
      expectedProviderCount: results.length,
    );
  }

  HistoricalSetupValidation history(double impact) {
    return HistoricalSetupValidation(
      status: HistoricalValidationStatus.available,
      reliability: HistoricalValidationReliability.high,
      verdict: impact >= 0
          ? HistoricalValidationVerdict.supports
          : HistoricalValidationVerdict.opposes,
      matchedCases: 30,
      effectiveSampleSize: 28,
      averageSimilarity: 0.82,
      alignedOutcomeRate: impact >= 0 ? 0.70 : 0.40,
      controlAlignedOutcomeRate: 0.50,
      edgeVsControlPercentagePoints: impact >= 0 ? 20 : -10,
      medianForwardReturnPercent: impact >= 0 ? 4.0 : -3.0,
      medianDirectionalReturnPercent: impact >= 0 ? 4.0 : -3.0,
      medianFavorableExcursionPercent: 5,
      medianAdverseExcursionPercent: -2,
      confidenceImpactPoints: impact,
      outcomeWindowLabel: 'Next 10 trading days',
      summary: 'test',
      isSynthetic: false,
      sourceLabel: 'test',
      topMatches: const [],
    );
  }

  test(
    'family direction attribution reconciles to signed direction and 100 percent basis',
    () {
      final result = engine.calculate(
        report([
          evidence(
            name: 'Trend',
            family: EvidenceFamily.trend,
            direction: EvidenceDirection.bullish,
            score: 80,
          ),
          evidence(
            name: 'Momentum',
            family: EvidenceFamily.momentum,
            direction: EvidenceDirection.bearish,
            score: 40,
          ),
          evidence(
            name: 'Participation',
            family: EvidenceFamily.participation,
            direction: EvidenceDirection.bullish,
            score: 60,
          ),
        ]),
      );

      expect(
        result.attributedDirectionScore,
        closeTo(result.directionScore!, 0.001),
      );

      expect(
        result.providerAttributedDirectionScore,
        closeTo(result.directionScore!, 0.001),
      );

      expect(result.directionReconciliationError, closeTo(0, 0.001));

      expect(result.providerDirectionReconciliationError, closeTo(0, 0.001));

      expect(result.directionAttributionBasis, greaterThan(0));

      expect(result.directionAttributionShareTotal, closeTo(1, 0.001));
    },
  );

  test(
    'opposing providers reconcile inside one capped family without becoming recommendation percentages',
    () {
      final result = engine.calculate(
        report([
          evidence(
            name: 'Trend Bull',
            family: EvidenceFamily.trend,
            direction: EvidenceDirection.bullish,
            score: 80,
          ),
          evidence(
            name: 'Trend Bear',
            family: EvidenceFamily.trend,
            direction: EvidenceDirection.bearish,
            score: 60,
          ),
        ]),
      );

      final family = result.familyContributions.single;

      expect(family.directionImpactPoints, closeTo(10, 0.001));

      expect(
        family.providers
            .map((provider) => provider.directionImpactPoints)
            .fold<double>(0, (a, b) => a + b),
        closeTo(family.directionImpactPoints, 0.001),
      );

      expect(
        family.providers
            .map((provider) => provider.directionShareWithinFamily)
            .fold<double>(0, (a, b) => a + b),
        closeTo(1, 0.001),
      );

      // The family owns 100% of the current family-level direction basis,
      // while its two providers contain large opposing absolute masses.
      // Therefore provider absolute shares must not be presented as
      // percentages of the recommendation.
      expect(family.directionShare, closeTo(1, 0.001));
      expect(
        family.providers.first.directionImpactPoints,
        greaterThan(family.directionImpactPoints),
      );
      expect(family.providers.last.directionImpactPoints, lessThan(0));
    },
  );

  test(
    'mirrored bullish and bearish evidence preserves attribution parity',
    () {
      final bullish = engine.calculate(
        report([
          evidence(
            name: 'Trend',
            family: EvidenceFamily.trend,
            direction: EvidenceDirection.bullish,
            score: 80,
          ),
          evidence(
            name: 'Momentum',
            family: EvidenceFamily.momentum,
            direction: EvidenceDirection.bullish,
            score: 60,
          ),
        ]),
      );

      final bearish = engine.calculate(
        report([
          evidence(
            name: 'Trend',
            family: EvidenceFamily.trend,
            direction: EvidenceDirection.bearish,
            score: 80,
          ),
          evidence(
            name: 'Momentum',
            family: EvidenceFamily.momentum,
            direction: EvidenceDirection.bearish,
            score: 60,
          ),
        ]),
      );

      expect(bearish.directionScore, closeTo(-bullish.directionScore!, 0.001));

      expect(bearish.confidence, closeTo(bullish.confidence, 0.001));

      expect(
        bearish.directionAttributionBasis,
        closeTo(bullish.directionAttributionBasis, 0.001),
      );

      expect(
        bearish.familyContributions.map((item) => item.directionShare).toList(),
        bullish.familyContributions.map((item) => item.directionShare).toList(),
      );
    },
  );

  test(
    'Event Risk stays outside direction attribution and reconciles separately',
    () {
      final evidenceResult = engine.calculate(
        report([
          evidence(
            name: 'Trend',
            family: EvidenceFamily.trend,
            direction: EvidenceDirection.bullish,
            score: 80,
          ),
          evidence(
            name: 'Momentum',
            family: EvidenceFamily.momentum,
            direction: EvidenceDirection.bullish,
            score: 70,
          ),
        ]),
      );

      final adjusted = eventAdjuster.apply(
        scoringResult: evidenceResult,
        strategy: StrategyType.swing,
        eventRisk: const EventRiskProfile(
          level: EventRiskLevel.high,
          earningsHoursAway: 24,
          macroEventHoursAway: null,
          macroEventLabel: '',
          confidencePenaltyPoints: 0,
          summary: 'Earnings soon.',
        ),
      );

      expect(adjusted.directionScore, evidenceResult.directionScore);

      expect(
        adjusted.familyContributions,
        same(evidenceResult.familyContributions),
      );

      expect(adjusted.evidenceConfidence, evidenceResult.evidenceConfidence);

      expect(adjusted.eventRiskAdjustmentPoints, lessThan(0));
      expect(adjusted.eventRiskAdjustmentPoints, greaterThanOrEqualTo(-12));
      expect(adjusted.historicalValidationAdjustmentPoints, 0);

      expect(adjusted.finalConfidenceReconciliationError, closeTo(0, 0.001));
    },
  );

  test(
    'evidence confidence plus Event Risk plus Historical Validation equals final confidence',
    () {
      final evidenceResult = engine.calculate(
        report([
          evidence(
            name: 'Trend',
            family: EvidenceFamily.trend,
            direction: EvidenceDirection.bullish,
            score: 85,
          ),
          evidence(
            name: 'Momentum',
            family: EvidenceFamily.momentum,
            direction: EvidenceDirection.bullish,
            score: 75,
          ),
          evidence(
            name: 'Participation',
            family: EvidenceFamily.participation,
            direction: EvidenceDirection.bullish,
            score: 70,
          ),
        ]),
      );

      final afterEvent = eventAdjuster.apply(
        scoringResult: evidenceResult,
        strategy: StrategyType.swing,
        eventRisk: const EventRiskProfile(
          level: EventRiskLevel.high,
          earningsHoursAway: 48,
          macroEventHoursAway: null,
          macroEventLabel: '',
          confidencePenaltyPoints: 0,
          summary: 'Earnings approaching.',
        ),
      );

      final finalResult = historicalAdjuster.apply(
        scoringResult: afterEvent,
        validation: history(5),
      );

      expect(finalResult.directionScore, evidenceResult.directionScore);

      expect(
        finalResult.attributedDirectionScore,
        closeTo(evidenceResult.directionScore!, 0.001),
      );

      expect(finalResult.evidenceConfidence, evidenceResult.evidenceConfidence);

      expect(finalResult.eventRiskAdjustmentPoints, lessThan(0));

      expect(
        finalResult.historicalValidationAdjustmentPoints,
        closeTo(5, 0.001),
      );

      expect(
        finalResult.reconciledFinalConfidence,
        closeTo(finalResult.confidence, 0.001),
      );

      expect(finalResult.finalConfidenceReconciliationError, closeTo(0, 0.001));

      expect(
        finalResult.evidenceConfidenceReconciliationError,
        closeTo(0, 0.001),
      );
    },
  );
}
