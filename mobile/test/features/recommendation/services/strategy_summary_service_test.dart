import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/evidence_report.dart';
import 'package:mobile/features/recommendation/models/recommendation.dart';
import 'package:mobile/features/recommendation/models/strategy_recommendation.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/services/strategy_summary_service.dart';

void main() {
  const service = StrategySummaryService();

  Recommendation createRecommendation() {
    return Recommendation(
      type: RecommendationType.strongBuy,
      evidenceScore: 91,
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

  test('builds Trader, Swing and Investor summaries', () {
    final traderRecommendation = StrategyRecommendation(
      strategy: StrategyType.trader,
      recommendation: createRecommendation(),
    );

    final summaries = service.build(traderRecommendation: traderRecommendation);

    expect(summaries.length, 3);

    expect(summaries[0].type, StrategyType.trader);
    expect(summaries[0].status, StrategyStatus.active);
    expect(summaries[0].confidence, 91);

    expect(summaries[1].type, StrategyType.swing);
    expect(summaries[1].status, StrategyStatus.comingSoon);

    expect(summaries[2].type, StrategyType.investor);
    expect(summaries[2].status, StrategyStatus.comingSoon);
  });
}
