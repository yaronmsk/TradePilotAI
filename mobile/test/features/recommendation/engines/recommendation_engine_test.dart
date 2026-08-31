import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/engines/recommendation_engine.dart';
import 'package:mobile/features/recommendation/models/evidence_report.dart';
import 'package:mobile/features/recommendation/models/recommendation.dart';
import 'package:mobile/features/recommendation/models/scoring_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';

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
    StrategyType strategy = StrategyType.trader,
  }) {
    return engine.create(
      scoringResult: scoringResult,
      evidenceReport: evidenceReport ?? createReport(),
      timeframe: '5m',
      candleCount: 48,
      analysisTime: DateTime(2026, 8, 3, 10),
      strategy: strategy,
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
      expect(recommendation.decisionReasons, [
        RecommendationDecisionReason.insufficientCoverage,
      ]);
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
      expect(recommendation.decisionReasons, [
        RecommendationDecisionReason.strongBullishAction,
      ]);
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
      expect(recommendation.decisionReasons, [
        RecommendationDecisionReason.bullishAction,
      ]);
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
      expect(recommendation.decisionReasons, [
        RecommendationDecisionReason.strongBearishAction,
      ]);
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
      expect(recommendation.decisionReasons, [
        RecommendationDecisionReason.bearishAction,
      ]);
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
      expect(recommendation.decisionReasons, [
        RecommendationDecisionReason.materialConflict,
      ]);
      expect(recommendation.oneLineExplanation, contains('currently conflict'));
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
      expect(recommendation.decisionReasons, [
        RecommendationDecisionReason.insufficientConfidence,
      ]);
      expect(
        recommendation.oneLineExplanation,
        contains('confidence is still below'),
      );
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

    test('Swing does not inherit the Trader Buy threshold', () {
      const scoring = ScoringResult(
        score: 58,
        coverage: 1,
        bullishWeight: 1,
        bearishWeight: 0,
        neutralWeight: 0,
        warnings: [],
        directionScore: 32,
        independentFamilyCount: 4,
      );

      final trader = createRecommendation(scoringResult: scoring);

      final swing = createRecommendation(
        scoringResult: scoring,
        strategy: StrategyType.swing,
      );

      expect(trader.type, RecommendationType.buy);
      expect(swing.type, RecommendationType.wait);
      expect(
        swing.decisionReasons,
        containsAll([
          RecommendationDecisionReason.insufficientDirectionalStrength,
          RecommendationDecisionReason.insufficientConfidence,
        ]),
      );
    });

    test('Swing Buy and Sell thresholds preserve parity', () {
      const bullish = ScoringResult(
        score: 65,
        coverage: 1,
        bullishWeight: 1,
        bearishWeight: 0,
        neutralWeight: 0,
        warnings: [],
        directionScore: 45,
        independentFamilyCount: 4,
      );

      const bearish = ScoringResult(
        score: 65,
        coverage: 1,
        bullishWeight: 0,
        bearishWeight: 1,
        neutralWeight: 0,
        warnings: [],
        directionScore: -45,
        independentFamilyCount: 4,
      );

      expect(
        createRecommendation(
          scoringResult: bullish,
          strategy: StrategyType.swing,
        ).type,
        RecommendationType.buy,
      );

      expect(
        createRecommendation(
          scoringResult: bearish,
          strategy: StrategyType.swing,
        ).type,
        RecommendationType.sell,
      );
    });

    test('Swing Strong Buy and Strong Sell preserve parity', () {
      const bullish = ScoringResult(
        score: 85,
        coverage: 1,
        bullishWeight: 1,
        bearishWeight: 0,
        neutralWeight: 0,
        warnings: [],
        directionScore: 75,
        independentFamilyCount: 4,
      );

      const bearish = ScoringResult(
        score: 85,
        coverage: 1,
        bullishWeight: 0,
        bearishWeight: 1,
        neutralWeight: 0,
        warnings: [],
        directionScore: -75,
        independentFamilyCount: 4,
      );

      expect(
        createRecommendation(
          scoringResult: bullish,
          strategy: StrategyType.swing,
        ).type,
        RecommendationType.strongBuy,
      );

      expect(
        createRecommendation(
          scoringResult: bearish,
          strategy: StrategyType.swing,
        ).type,
        RecommendationType.strongSell,
      );
    });

    test('material Swing cross-family conflict resolves to Hold', () {
      final recommendation = createRecommendation(
        scoringResult: const ScoringResult(
          score: 72,
          coverage: 1,
          bullishWeight: 0.7,
          bearishWeight: 0.3,
          neutralWeight: 0,
          warnings: [],
          directionScore: 40,
          conflict: 0.60,
          independentFamilyCount: 5,
        ),
        strategy: StrategyType.swing,
      );

      expect(recommendation.type, RecommendationType.hold);
      expect(recommendation.decisionReasons, [
        RecommendationDecisionReason.materialConflict,
      ]);
      expect(recommendation.oneLineExplanation, contains('currently conflict'));
    });

    test('Swing requires at least three independent families for action', () {
      final recommendation = createRecommendation(
        scoringResult: const ScoringResult(
          score: 75,
          coverage: 1,
          bullishWeight: 1,
          bearishWeight: 0,
          neutralWeight: 0,
          warnings: [],
          directionScore: 55,
          independentFamilyCount: 2,
        ),
        strategy: StrategyType.swing,
      );

      expect(recommendation.type, RecommendationType.wait);
      expect(recommendation.decisionReasons, [
        RecommendationDecisionReason.insufficientFamilyBreadth,
      ]);
      expect(
        recommendation.oneLineExplanation,
        contains('too few independent evidence groups'),
      );
    });

    test(
      'Swing explains directional strength when confidence and breadth are sufficient',
      () {
        final recommendation = createRecommendation(
          scoringResult: const ScoringResult(
            score: 65,
            coverage: 1,
            bullishWeight: 1,
            bearishWeight: 0,
            neutralWeight: 0,
            warnings: [],
            directionScore: 32,
            independentFamilyCount: 4,
          ),
          strategy: StrategyType.swing,
        );

        expect(recommendation.type, RecommendationType.wait);
        expect(recommendation.decisionReasons, [
          RecommendationDecisionReason.insufficientDirectionalStrength,
        ]);
        expect(
          recommendation.oneLineExplanation,
          contains('directional edge is not yet strong enough'),
        );
        expect(
          recommendation.oneLineExplanation,
          isNot(contains('confidence is still below')),
        );
      },
    );

    test('Swing requires at least sixty-five percent provider coverage', () {
      final recommendation = createRecommendation(
        scoringResult: const ScoringResult(
          score: 80,
          coverage: 0.62,
          bullishWeight: 1,
          bearishWeight: 0,
          neutralWeight: 0,
          warnings: [],
          directionScore: 70,
          independentFamilyCount: 5,
        ),
        strategy: StrategyType.swing,
      );

      expect(recommendation.type, RecommendationType.wait);
      expect(recommendation.decisionReasons, [
        RecommendationDecisionReason.insufficientCoverage,
      ]);
    });

    test('Investor recommendation decision remains unavailable', () {
      expect(
        () => createRecommendation(
          scoringResult: const ScoringResult(
            score: 90,
            coverage: 1,
            bullishWeight: 1,
            bearishWeight: 0,
            neutralWeight: 0,
            warnings: [],
            directionScore: 90,
            independentFamilyCount: 5,
          ),
          strategy: StrategyType.investor,
        ),
        throwsStateError,
      );
    });
  });
}
