import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/engines/recommendation_engine.dart';
import 'package:mobile/features/recommendation/models/evidence_report.dart';
import 'package:mobile/features/recommendation/models/recommendation.dart';
import 'package:mobile/features/recommendation/models/scoring_result.dart';

void main() {
  const engine = RecommendationEngine();

  EvidenceReport createReport({int expectedProviderCount = 1}) {
    return EvidenceReport.fromResults(
      results: const [],
      expectedProviderCount: expectedProviderCount,
    );
  }

  Recommendation createRecommendation({
    required ScoringResult scoringResult,
    EvidenceReport? evidenceReport,
  }) {
    return engine.create(
      scoringResult: scoringResult,
      evidenceReport: evidenceReport ?? createReport(),
      timeframe: '5m',
      candleCount: 48,
      analysisTime: DateTime(2026, 8, 3, 10),
    );
  }

  group('RecommendationEngine', () {
    test('returns wait when evidence coverage is insufficient', () {
      final recommendation = createRecommendation(
        scoringResult: const ScoringResult(
          score: 90,
          coverage: 0.50,
          bullishWeight: 1,
          bearishWeight: 0,
          neutralWeight: 0,
          warnings: [],
          directionScore: 90,
        ),
      );

      expect(recommendation.type, RecommendationType.wait);
    });

    test('returns strong buy for strong bullish consensus', () {
      final recommendation = createRecommendation(
        scoringResult: const ScoringResult(
          score: 90,
          coverage: 1,
          bullishWeight: 1,
          bearishWeight: 0,
          neutralWeight: 0,
          warnings: [],
          directionScore: 82,
        ),
      );

      expect(recommendation.type, RecommendationType.strongBuy);
      expect(recommendation.confidenceScore, 90);
      expect(recommendation.directionScore, 82);
    });

    test('returns buy for moderate bullish consensus', () {
      final recommendation = createRecommendation(
        scoringResult: const ScoringResult(
          score: 65,
          coverage: 1,
          bullishWeight: 1,
          bearishWeight: 0,
          neutralWeight: 0,
          warnings: [],
          directionScore: 45,
        ),
      );

      expect(recommendation.type, RecommendationType.buy);
    });

    test('returns strong sell for strong bearish consensus', () {
      final recommendation = createRecommendation(
        scoringResult: const ScoringResult(
          score: 90,
          coverage: 1,
          bullishWeight: 0,
          bearishWeight: 1,
          neutralWeight: 0,
          warnings: [],
          directionScore: -82,
        ),
      );

      expect(recommendation.type, RecommendationType.strongSell);
    });

    test('returns sell for moderate bearish consensus', () {
      final recommendation = createRecommendation(
        scoringResult: const ScoringResult(
          score: 65,
          coverage: 1,
          bullishWeight: 0,
          bearishWeight: 1,
          neutralWeight: 0,
          warnings: [],
          directionScore: -45,
        ),
      );

      expect(recommendation.type, RecommendationType.sell);
    });

    test('returns hold when directional consensus is neutral', () {
      final recommendation = createRecommendation(
        scoringResult: const ScoringResult(
          score: 70,
          coverage: 1,
          bullishWeight: 0.8,
          bearishWeight: 0.8,
          neutralWeight: 0,
          warnings: [],
          directionScore: 0,
          conflict: 1,
        ),
      );

      expect(recommendation.type, RecommendationType.hold);
      expect(recommendation.oneLineExplanation, contains('conflicted'));
    });

    test('returns wait when bias exists but confidence is too low', () {
      final recommendation = createRecommendation(
        scoringResult: const ScoringResult(
          score: 45,
          coverage: 1,
          bullishWeight: 0.6,
          bearishWeight: 0.2,
          neutralWeight: 0.2,
          warnings: [],
          directionScore: 50,
        ),
      );

      expect(recommendation.type, RecommendationType.wait);
    });

    test('supports legacy callers that only provide directional weights', () {
      final recommendation = createRecommendation(
        scoringResult: const ScoringResult(
          score: 90,
          coverage: 1,
          bullishWeight: 1,
          bearishWeight: 0,
          neutralWeight: 0,
          warnings: [],
        ),
      );

      expect(recommendation.type, RecommendationType.strongBuy);
    });

    test('preserves recommendation metadata and consensus', () {
      const scoring = ScoringResult(
        score: 65,
        coverage: 1,
        bullishWeight: 1,
        bearishWeight: 0,
        neutralWeight: 0,
        warnings: [],
        directionScore: 45,
        agreement: 0.8,
        conflict: 0.2,
      );

      final recommendation = createRecommendation(scoringResult: scoring);

      expect(recommendation.timeframe, '5m');
      expect(recommendation.candleCount, 48);
      expect(recommendation.analysisTime, DateTime(2026, 8, 3, 10));
      expect(recommendation.consensus.agreement, 0.8);
      expect(recommendation.consensus.conflict, 0.2);
    });
  });
}
