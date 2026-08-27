import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/event_risk_confidence_adjuster.dart';
import 'package:mobile/features/recommendation/context/external_context_profile.dart';
import 'package:mobile/features/recommendation/models/analysis_context_explainability_catalog.dart';
import 'package:mobile/features/recommendation/models/analysis_context_metric.dart';
import 'package:mobile/features/recommendation/models/metric_explainability.dart';
import 'package:mobile/features/recommendation/models/scoring_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';

void main() {
  const adjuster = EventRiskConfidenceAdjuster();

  const scoring = ScoringResult(
    score: 74,
    coverage: 1,
    bullishWeight: 1,
    bearishWeight: 0,
    neutralWeight: 0,
    warnings: [],
    directionScore: 60,
    evidenceConfidence: 74,
  );

  test(
    'Trader reduces confidence without changing direction or evidence confidence',
    () {
      const risk = EventRiskProfile(
        level: EventRiskLevel.high,
        earningsHoursAway: 24,
        macroEventHoursAway: 36,
        macroEventLabel: 'Macro event',
        confidencePenaltyPoints: 6,
        summary: 'Elevated event risk.',
      );

      final result = adjuster.apply(scoringResult: scoring, eventRisk: risk);

      expect(result.confidence, 68);
      expect(result.directionScore, 60);
      expect(result.evidenceConfidence, 74);

      expect(result.confidenceModifiers.last.label, 'Upcoming event risk');

      expect(result.confidenceModifiers.last.impactPoints, -6);
    },
  );

  test('hard-caps event risk penalty at twelve points', () {
    const risk = EventRiskProfile(
      level: EventRiskLevel.critical,
      earningsHoursAway: 2,
      macroEventHoursAway: 2,
      macroEventLabel: 'Macro event',
      confidencePenaltyPoints: 25,
      summary: 'Extreme event proximity.',
    );

    final result = adjuster.apply(scoringResult: scoring, eventRisk: risk);

    expect(EventRiskConfidenceAdjuster.maximumAllowedPenaltyPoints, 12);

    expect(result.confidence, 62);
    expect(result.directionScore, 60);
    expect(result.evidenceConfidence, 74);

    expect(
      result.confidenceModifiers.last.impactPoints,
      -EventRiskConfidenceAdjuster.maximumAllowedPenaltyPoints,
    );
  });

  test('cannot be configured above the architectural twelve-point cap', () {
    expect(
      () => EventRiskConfidenceAdjuster(maximumPenaltyPoints: 13),
      throwsAssertionError,
    );
  });

  test('zero or negative Trader penalty can never create a bonus', () {
    const zeroRisk = EventRiskProfile(
      level: EventRiskLevel.low,
      earningsHoursAway: 120,
      macroEventHoursAway: 120,
      macroEventLabel: 'Distant event',
      confidencePenaltyPoints: 0,
      summary: 'Low event risk.',
    );

    const negativeRisk = EventRiskProfile(
      level: EventRiskLevel.low,
      earningsHoursAway: 120,
      macroEventHoursAway: 120,
      macroEventLabel: 'Distant event',
      confidencePenaltyPoints: -5,
      summary: 'Invalid negative penalty.',
    );

    final zeroResult = adjuster.apply(
      scoringResult: scoring,
      eventRisk: zeroRisk,
    );

    final negativeResult = adjuster.apply(
      scoringResult: scoring,
      eventRisk: negativeRisk,
    );

    expect(zeroResult.confidence, 74);
    expect(negativeResult.confidence, 74);

    expect(zeroResult.directionScore, 60);
    expect(negativeResult.directionScore, 60);

    expect(zeroResult.evidenceConfidence, 74);
    expect(negativeResult.evidenceConfidence, 74);

    expect(zeroResult.confidenceModifiers, isEmpty);
    expect(negativeResult.confidenceModifiers, isEmpty);
  });

  test(
    'Swing re-derives event penalty from timing instead of trusting upstream value',
    () {
      const risk = EventRiskProfile(
        level: EventRiskLevel.low,
        earningsHoursAway: 28,
        macroEventHoursAway: 36,
        macroEventLabel: 'Macro event',
        confidencePenaltyPoints: 1,
        summary: 'Upstream penalty intentionally Trader-shaped.',
      );

      final result = adjuster.apply(
        scoringResult: scoring,
        eventRisk: risk,
        strategy: StrategyType.swing,
      );

      // Swing: earnings 28h = 8 points, macro 36h = 3 points.
      expect(result.confidence, 63);
      expect(result.directionScore, 60);
      expect(result.evidenceConfidence, 74);

      expect(result.confidenceModifiers.last.impactPoints, -11);
    },
  );

  test(
    'Swing distant events cannot create a penalty merely because upstream supplied one',
    () {
      const risk = EventRiskProfile(
        level: EventRiskLevel.high,
        earningsHoursAway: 400,
        macroEventHoursAway: 200,
        macroEventLabel: 'Distant macro event',
        confidencePenaltyPoints: 12,
        summary: 'Events are outside the Swing relevance windows.',
      );

      final result = adjuster.apply(
        scoringResult: scoring,
        eventRisk: risk,
        strategy: StrategyType.swing,
      );

      expect(result.confidence, 74);
      expect(result.directionScore, 60);
      expect(result.evidenceConfidence, 74);
      expect(result.confidenceModifiers, isEmpty);
    },
  );

  test('Investor Event Risk remains deferred', () {
    const risk = EventRiskProfile(
      level: EventRiskLevel.critical,
      earningsHoursAway: 2,
      macroEventHoursAway: 2,
      macroEventLabel: 'Macro event',
      confidencePenaltyPoints: 12,
      summary: 'Near event.',
    );

    final result = adjuster.apply(
      scoringResult: scoring,
      eventRisk: risk,
      strategy: StrategyType.investor,
    );

    expect(result.confidence, 74);
    expect(result.directionScore, 60);
    expect(result.evidenceConfidence, 74);
    expect(result.confidenceModifiers, isEmpty);
  });

  test('does nothing when event context is unavailable', () {
    final result = adjuster.apply(
      scoringResult: scoring,
      eventRisk: const EventRiskProfile.unavailable(),
      strategy: StrategyType.swing,
    );

    expect(result.confidence, 74);
    expect(result.directionScore, 60);
    expect(result.evidenceConfidence, 74);
    expect(result.confidenceModifiers, isEmpty);
  });

  test('generic Event Risk explainability agrees with invariant', () {
    final explanation = AnalysisContextExplainabilityCatalog.forMetric(
      AnalysisContextMetric.eventRisk,
    );

    expect(explanation.semanticRole, MetricSemanticRole.confidenceRiskOnly);

    expect(explanation.allowsDirectionalInfluence, isFalse);
    expect(explanation.supportiveInterpretation, isNull);
    expect(explanation.opposingInterpretation, isNull);
    expect(explanation.boundedImpact, contains('12 points'));

    expect(
      explanation.boundedImpact,
      contains('cannot create Buy/Sell direction'),
    );
  });

  test('Swing Event Risk explainability exposes its longer horizon', () {
    final explanation = AnalysisContextExplainabilityCatalog.forMetric(
      AnalysisContextMetric.eventRisk,
      strategy: StrategyType.swing,
    );

    expect(explanation.semanticRole, MetricSemanticRole.confidenceRiskOnly);

    expect(explanation.allowsDirectionalInfluence, isFalse);
    expect(explanation.calculation, contains('14 days'));
    expect(explanation.calculation, contains('7 days'));

    expect(explanation.boundedImpact, contains('-12 confidence points'));

    expect(
      explanation.recommendationImpact,
      contains('excluded from the directional evidence attribution'),
    );
  });
}
