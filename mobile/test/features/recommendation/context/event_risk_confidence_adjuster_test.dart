import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/recommendation/context/event_risk_confidence_adjuster.dart';
import 'package:mobile/features/recommendation/context/external_context_profile.dart';
import 'package:mobile/features/recommendation/models/analysis_context_explainability_catalog.dart';
import 'package:mobile/features/recommendation/models/analysis_context_metric.dart';
import 'package:mobile/features/recommendation/models/metric_explainability.dart';
import 'package:mobile/features/recommendation/models/scoring_result.dart';

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
    'reduces confidence without changing direction or evidence confidence',
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

  test('zero or negative penalty can never create a confidence bonus', () {
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

  test('does nothing when event context is unavailable', () {
    final result = adjuster.apply(
      scoringResult: scoring,
      eventRisk: const EventRiskProfile.unavailable(),
    );

    expect(result.confidence, 74);
    expect(result.directionScore, 60);
    expect(result.evidenceConfidence, 74);
    expect(result.confidenceModifiers, isEmpty);
  });

  test('Event Risk explainability agrees with implementation semantics', () {
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
}
