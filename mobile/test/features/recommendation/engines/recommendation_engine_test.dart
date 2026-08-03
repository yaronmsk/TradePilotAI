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
        ),
      );

      expect(recommendation.type, RecommendationType.wait);
    });

    test('returns strong buy for strong bullish evidence', () {
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
      expect(recommendation.evidenceScore, 90);
    });

    test('returns buy for moderate bullish evidence', () {
      final recommendation = createRecommendation(
        scoringResult: const ScoringResult(
          score: 65,
          coverage: 1,
          bullishWeight: 1,
          bearishWeight: 0,
          neutralWeight: 0,
          warnings: [],
        ),
      );

      expect(recommendation.type, RecommendationType.buy);
    });

    test('returns strong sell for strong bearish evidence', () {
      final recommendation = createRecommendation(
        scoringResult: const ScoringResult(
          score: 90,
          coverage: 1,
          bullishWeight: 0,
          bearishWeight: 1,
          neutralWeight: 0,
          warnings: [],
        ),
      );

      expect(recommendation.type, RecommendationType.strongSell);
    });

    test('returns sell for moderate bearish evidence', () {
      final recommendation = createRecommendation(
        scoringResult: const ScoringResult(
          score: 65,
          coverage: 1,
          bullishWeight: 0,
          bearishWeight: 1,
          neutralWeight: 0,
          warnings: [],
        ),
      );

      expect(recommendation.type, RecommendationType.sell);
    });

    test('returns hold when all evidence is neutral', () {
      final recommendation = createRecommendation(
        scoringResult: const ScoringResult(
          score: 50,
          coverage: 1,
          bullishWeight: 0,
          bearishWeight: 0,
          neutralWeight: 1,
          warnings: [],
        ),
      );

      expect(recommendation.type, RecommendationType.hold);
    });

    test('returns wait when directional evidence is mixed', () {
      final recommendation = createRecommendation(
        scoringResult: const ScoringResult(
          score: 70,
          coverage: 1,
          bullishWeight: 0.55,
          bearishWeight: 0.45,
          neutralWeight: 0,
          warnings: [],
        ),
      );

      expect(recommendation.type, RecommendationType.wait);
    });

    test('preserves recommendation metadata', () {
      final recommendation = createRecommendation(
        scoringResult: const ScoringResult(
          score: 65,
          coverage: 1,
          bullishWeight: 1,
          bearishWeight: 0,
          neutralWeight: 0,
          warnings: [],
        ),
      );

      expect(recommendation.timeframe, '5m');
      expect(recommendation.candleCount, 48);
      expect(recommendation.analysisTime, DateTime(2026, 8, 3, 10));
    });
  });
}
