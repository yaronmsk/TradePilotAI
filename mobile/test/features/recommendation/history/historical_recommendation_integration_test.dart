import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/history/historical_setup_validation.dart';
import 'package:mobile/features/recommendation/models/evidence_report.dart';
import 'package:mobile/features/recommendation/models/recommendation.dart';
import 'package:mobile/features/recommendation/models/scoring_result.dart';
import 'package:mobile/features/recommendation/services/recommendation_service.dart';

void main() {
  const service = RecommendationService(providers: []);

  Recommendation recommendation({double confidence = 53}) {
    final scoring = ScoringResult(
      score: confidence,
      evidenceConfidence: confidence,
      coverage: 1,
      bullishWeight: 1,
      bearishWeight: 0,
      neutralWeight: 0,
      warnings: const [],
      directionScore: 45,
      familyCoverage: 1,
      agreement: 1,
      conflict: 0,
      baseEvidenceStrength: 70,
    );

    return Recommendation(
      type: RecommendationType.wait,
      evidenceScore: confidence,
      oneLineExplanation: 'Directional bias exists.',
      timeframe: '5m',
      candleCount: 48,
      analysisTime: DateTime.utc(2026, 8, 20),
      evidenceReport: EvidenceReport.fromResults(
        results: const [],
        expectedProviderCount: 0,
      ),
      consensus: scoring,
    );
  }

  HistoricalSetupValidation validation(double impact) {
    return HistoricalSetupValidation(
      status: HistoricalValidationStatus.available,
      reliability: HistoricalValidationReliability.high,
      verdict: impact >= 0
          ? HistoricalValidationVerdict.supports
          : HistoricalValidationVerdict.opposes,
      matchedCases: 30,
      effectiveSampleSize: 26,
      averageSimilarity: 0.8,
      alignedOutcomeRate: impact >= 0 ? 0.7 : 0.4,
      controlAlignedOutcomeRate: 0.5,
      edgeVsControlPercentagePoints: impact >= 0 ? 20 : -10,
      medianForwardReturnPercent: impact >= 0 ? 1 : -1,
      medianDirectionalReturnPercent: impact >= 0 ? 1 : -1,
      medianFavorableExcursionPercent: 1.5,
      medianAdverseExcursionPercent: -0.8,
      confidenceImpactPoints: impact,
      outcomeWindowLabel: 'Next 24 × 5m bars (~2 hours)',
      summary: 'test',
      isSynthetic: false,
      sourceLabel: 'test',
      topMatches: const [],
    );
  }

  test(
    'historical support can increase actionability without changing direction score',
    () {
      final base = recommendation(confidence: 53);

      final adjusted = service.applyHistoricalValidation(
        recommendation: base,
        validation: validation(4),
      );

      expect(adjusted.consensus.directionScore, base.consensus.directionScore);
      expect(adjusted.confidenceScore, 57);
      expect(adjusted.consensus.evidenceConfidence, 53);
      expect(adjusted.type, RecommendationType.buy);
      expect(
        adjusted.historicalValidation.verdict,
        HistoricalValidationVerdict.supports,
      );
    },
  );

  test('historical opposition can move a borderline buy back to wait', () {
    final base = recommendation(
      confidence: 58,
    ).copyWith(type: RecommendationType.buy);

    final adjusted = service.applyHistoricalValidation(
      recommendation: base,
      validation: validation(-5),
    );

    expect(adjusted.confidenceScore, 53);
    expect(adjusted.type, RecommendationType.wait);
    expect(adjusted.directionScore, 45);
  });
}
