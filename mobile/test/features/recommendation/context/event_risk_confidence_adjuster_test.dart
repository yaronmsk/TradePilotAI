import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/event_risk_confidence_adjuster.dart';
import 'package:mobile/features/recommendation/context/external_context_profile.dart';
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

  test('reduces confidence without changing direction', () {
    const risk = EventRiskProfile(
      level: EventRiskLevel.high,
      earningsHoursAway: 24,
      macroEventHoursAway: 36,
      macroEventLabel: 'Macro event',
      confidencePenaltyPoints: 6,
      summary: 'Elevated event risk.',
    );

    final result = adjuster.apply(scoringResult: scoring, eventRisk: risk);

    expect(result.score, 68);
    expect(result.directionScore, 60);
    expect(result.evidenceConfidence, 74);
    expect(result.confidenceModifiers.last.label, 'Upcoming event risk');
    expect(result.confidenceModifiers.last.impactPoints, -6);
  });

  test('caps event risk penalty', () {
    const risk = EventRiskProfile(
      level: EventRiskLevel.critical,
      earningsHoursAway: 2,
      macroEventHoursAway: 2,
      macroEventLabel: 'Macro event',
      confidencePenaltyPoints: 25,
      summary: 'Extreme event proximity.',
    );

    final result = adjuster.apply(scoringResult: scoring, eventRisk: risk);

    expect(result.score, 62);
  });

  test('does nothing when event context is unavailable', () {
    final result = adjuster.apply(
      scoringResult: scoring,
      eventRisk: const EventRiskProfile.unavailable(),
    );

    expect(result.score, 74);
    expect(result.confidenceModifiers, isEmpty);
  });
}
