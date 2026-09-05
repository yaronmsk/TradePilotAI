import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/history/historical_setup_validation.dart';
import 'package:mobile/features/recommendation/investor/engines/investor_recommendation_engine.dart';
import 'package:mobile/features/recommendation/investor/models/investor_metric_assessment.dart';
import 'package:mobile/features/recommendation/investor/strategy/investor_recommendation_policy.dart';
import 'package:mobile/features/recommendation/models/evidence_contribution.dart';
import 'package:mobile/features/recommendation/models/evidence_definition.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';

void main() {
  const engine = InvestorRecommendationEngine();
  final analysisTime = DateTime(2026, 9, 4);

  InvestorEvidenceAssessment assessment(EvidenceFamily family) {
    return InvestorEvidenceAssessment(
      evidence: EvidenceResult(
        providerName: 'Test ${family.name}',
        definition: EvidenceDefinition(
          family: family,
          name: family.name,
          description: 'Test',
          whyItMatters: 'Test',
          calculation: 'Test',
        ),
        status: EvidenceStatus.available,
        direction: EvidenceDirection.bullish,
        strength: EvidenceStrength.strong,
        score: 70,
        baseWeight: 1,
        dynamicWeight: 1,
        reliability: 1,
        currentValue: 'Test',
        baselineValue: 'Test',
        relativeValue: 'Test',
        explanation: 'Test',
      ),
      metrics: const [],
    );
  }

  InvestorRecommendationAnalysis current() => engine.create(
    assessments: [
      for (final family
          in InvestorRecommendationPolicy.breadthEligibleCoreFamilies)
        assessment(family),
    ],
    analysisTime: analysisTime,
  );

  HistoricalSetupValidation validation(double impact) =>
      HistoricalSetupValidation(
        status: HistoricalValidationStatus.available,
        reliability: HistoricalValidationReliability.high,
        verdict: impact > 0
            ? HistoricalValidationVerdict.supports
            : HistoricalValidationVerdict.opposes,
        matchedCases: 20,
        effectiveSampleSize: 16,
        averageSimilarity: 0.84,
        alignedOutcomeRate: 0.70,
        controlAlignedOutcomeRate: 0.50,
        edgeVsControlPercentagePoints: 20,
        medianForwardReturnPercent: 12,
        medianDirectionalReturnPercent: 12,
        medianFavorableExcursionPercent: 0,
        medianAdverseExcursionPercent: 0,
        confidenceImpactPoints: impact,
        outcomeWindowLabel: '6m / 12m / 24m',
        outcomeWindowShortLabel: '6m / 12m / 24m',
        summary: 'Test historical validation',
        isSynthetic: true,
        sourceLabel: 'Test',
        topMatches: const [],
      );

  test(
    'historical confidence modifier leaves direction attribution unchanged',
    () {
      final before = current();
      final beforeDirection = before.recommendation.consensus.directionScore;
      final beforeFamilyDirection = [
        for (final contribution
            in before.recommendation.consensus.familyContributions)
          contribution.directionImpactPoints,
      ];

      final after = engine.applyHistoricalValidation(
        analysis: before,
        validation: validation(6),
      );

      expect(
        after.recommendation.consensus.directionScore,
        closeTo(beforeDirection!, 0.000001),
      );
      expect([
        for (final contribution
            in after.recommendation.consensus.familyContributions)
          contribution.directionImpactPoints,
      ], beforeFamilyDirection);
    },
  );

  test('historical confidence is a separate bounded modifier', () {
    final before = current();

    final after = engine.applyHistoricalValidation(
      analysis: before,
      validation: validation(8),
    );

    expect(
      after.recommendation.consensus.historicalValidationAdjustmentPoints,
      closeTo(8, 0.000001),
    );
    expect(after.recommendation.consensus.confidence, lessThanOrEqualTo(100));
    expect(
      after.recommendation.consensus.confidenceModifiers.last.source,
      ConfidenceModifierSource.historicalValidation,
    );
    expect(after.recommendation.historicalValidation.confidenceImpactPoints, 8);
  });

  test('historical validation cannot change core breadth or context share', () {
    final before = current();

    final after = engine.applyHistoricalValidation(
      analysis: before,
      validation: validation(-8),
    );

    expect(after.coreFamilyCount, before.coreFamilyCount);
    expect(after.coreCoverage, before.coreCoverage);
    expect(
      after.requiredCoreFamiliesAvailable,
      before.requiredCoreFamiliesAvailable,
    );
    expect(after.contextDirectionShare, before.contextDirectionShare);
    expect(
      after.excludedRecommendationFamilies,
      before.excludedRecommendationFamilies,
    );
  });
}
