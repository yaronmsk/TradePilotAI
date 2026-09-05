import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/evidence_report.dart';
import 'package:mobile/features/recommendation/models/recommendation.dart';
import 'package:mobile/features/recommendation/models/strategy_recommendation.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/services/strategy_summary_service.dart';

void main() {
  const service = StrategySummaryService();

  Recommendation createRecommendation({
    RecommendationType type = RecommendationType.strongBuy,
    double confidence = 91,
  }) {
    return Recommendation(
      type: type,
      evidenceScore: confidence,
      oneLineExplanation: 'Test recommendation.',
      timeframe: '5m',
      candleCount: 48,
      analysisTime: DateTime(2026, 8, 14, 10),
      evidenceReport: EvidenceReport.fromResults(
        results: const [],
        expectedProviderCount: 0,
      ),
    );
  }

  test('builds active Trader, ready Swing and future Investor summaries', () {
    final traderRecommendation = StrategyRecommendation(
      strategy: StrategyType.trader,
      recommendation: createRecommendation(),
    );

    final summaries = service.build(recommendations: [traderRecommendation]);

    expect(summaries.length, 3);

    expect(summaries[0].type, StrategyType.trader);
    expect(summaries[0].status, StrategyStatus.active);
    expect(summaries[0].confidence, 91);

    expect(summaries[1].type, StrategyType.swing);
    expect(summaries[1].status, StrategyStatus.active);
    expect(summaries[1].recommendation, 'Ready to analyze');
    expect(summaries[1].confidence, isNull);

    expect(summaries[2].type, StrategyType.investor);
    expect(summaries[2].status, StrategyStatus.comingSoon);
  });

  test(
    'shows dedicated Investor backend as ready without generic activation',
    () {
      final summaries = service.build(
        recommendations: const [],
        dedicatedAvailableStrategies: const {StrategyType.investor},
      );

      expect(summaries[0].status, StrategyStatus.active);
      expect(summaries[1].status, StrategyStatus.active);
      expect(summaries[2].status, StrategyStatus.active);
      expect(summaries[2].recommendation, 'Ready to analyze');
      expect(summaries[2].confidence, isNull);
    },
  );

  test('activates any strategy that has a recommendation', () {
    final summaries = service.build(
      recommendations: [
        StrategyRecommendation(
          strategy: StrategyType.trader,
          recommendation: createRecommendation(),
        ),
        StrategyRecommendation(
          strategy: StrategyType.swing,
          recommendation: createRecommendation(
            type: RecommendationType.hold,
            confidence: 72,
          ),
        ),
      ],
    );

    expect(summaries[1].status, StrategyStatus.active);
    expect(summaries[1].recommendation, 'No Clear Direction');
    expect(summaries[1].confidence, 72);
    expect(summaries[2].status, StrategyStatus.comingSoon);
  });
}
