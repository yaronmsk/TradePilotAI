import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/history/historical_confidence_adjuster.dart';
import 'package:mobile/features/recommendation/history/historical_setup_validation.dart';
import 'package:mobile/features/recommendation/models/evidence_contribution.dart';
import 'package:mobile/features/recommendation/models/scoring_result.dart';

void main() {
  const adjuster = HistoricalConfidenceAdjuster();

  ScoringResult scoring(double confidence) {
    return ScoringResult(
      score: confidence,
      coverage: 1,
      bullishWeight: 1,
      bearishWeight: 0,
      neutralWeight: 0,
      warnings: const [],
      directionScore: 70,
      baseEvidenceStrength: 80,
      evidenceConfidence: confidence,
      confidenceModifiers: [
        ConfidenceModifierImpact(
          label: 'Data reliability',
          factor: confidence / 80,
          before: 80,
          after: confidence,
        ),
      ],
    );
  }

  HistoricalSetupValidation validation(double impact) {
    return HistoricalSetupValidation(
      status: HistoricalValidationStatus.available,
      reliability: HistoricalValidationReliability.high,
      verdict: impact > 0
          ? HistoricalValidationVerdict.supports
          : HistoricalValidationVerdict.opposes,
      matchedCases: 30,
      effectiveSampleSize: 28,
      averageSimilarity: 0.82,
      alignedOutcomeRate: impact > 0 ? 0.7 : 0.4,
      controlAlignedOutcomeRate: 0.5,
      edgeVsControlPercentagePoints: impact > 0 ? 20 : -10,
      medianForwardReturnPercent: impact > 0 ? 1.1 : -0.8,
      medianDirectionalReturnPercent: impact > 0 ? 1.1 : -0.8,
      medianFavorableExcursionPercent: 1.7,
      medianAdverseExcursionPercent: -0.7,
      confidenceImpactPoints: impact,
      outcomeWindowLabel: 'Next 24 × 5m bars (~2 hours)',
      summary: 'test',
      isSynthetic: false,
      sourceLabel: 'test',
      topMatches: const [],
    );
  }

  test(
    'supportive history raises final confidence without changing evidence confidence',
    () {
      final result = adjuster.apply(
        scoringResult: scoring(70),
        validation: validation(4),
      );

      expect(result.confidence, 74);
      expect(result.evidenceConfidence, 70);
      expect(result.directionScore, 70);
      expect(
        result.confidenceModifiers.last.label,
        'Historical setup validation',
      );
      expect(result.confidenceModifiers.last.impactPoints, closeTo(4, 0.001));
    },
  );

  test('opposing history can reduce final confidence', () {
    final result = adjuster.apply(
      scoringResult: scoring(70),
      validation: validation(-5),
    );

    expect(result.confidence, 65);
    expect(result.evidenceConfidence, 70);
    expect(result.directionScore, 70);
  });

  test('supportive impact is hard-capped at positive eight points', () {
    final result = adjuster.apply(
      scoringResult: scoring(70),
      validation: validation(20),
    );

    expect(result.confidence, 78);
    expect(result.evidenceConfidence, 70);
    expect(result.directionScore, 70);

    expect(
      result.confidenceModifiers.last.impactPoints,
      closeTo(HistoricalSetupValidation.maximumConfidenceImpactPoints, 0.001),
    );
  });

  test('opposing impact is hard-capped at negative eight points', () {
    final result = adjuster.apply(
      scoringResult: scoring(70),
      validation: validation(-20),
    );

    expect(result.confidence, 62);
    expect(result.evidenceConfidence, 70);
    expect(result.directionScore, 70);

    expect(
      result.confidenceModifiers.last.impactPoints,
      closeTo(-HistoricalSetupValidation.maximumConfidenceImpactPoints, 0.001),
    );
  });
}
