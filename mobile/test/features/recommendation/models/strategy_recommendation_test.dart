import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/evidence_report.dart';
import 'package:mobile/features/recommendation/models/recommendation.dart';
import 'package:mobile/features/recommendation/models/strategy_recommendation.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';

void main() {
  Recommendation createRecommendation({double evidenceScore = 82}) {
    return Recommendation(
      type: RecommendationType.buy,
      evidenceScore: evidenceScore,
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

  group('StrategyRecommendation', () {
    test('provides Trader metadata', () {
      final result = StrategyRecommendation(
        strategy: StrategyType.trader,
        recommendation: createRecommendation(),
      );

      expect(result.title, 'Trader');
      expect(result.horizon, 'Hours–Days');
    });

    test('provides Swing metadata', () {
      final result = StrategyRecommendation(
        strategy: StrategyType.swing,
        recommendation: createRecommendation(),
      );

      expect(result.title, 'Swing');
      expect(result.horizon, 'Days–Weeks');
    });

    test('provides Investor metadata', () {
      final result = StrategyRecommendation(
        strategy: StrategyType.investor,
        recommendation: createRecommendation(),
      );

      expect(result.title, 'Investor');
      expect(result.horizon, 'Months–Years');
    });

    test('uses recommendation evidence score as confidence', () {
      final result = StrategyRecommendation(
        strategy: StrategyType.trader,
        recommendation: createRecommendation(evidenceScore: 87),
      );

      expect(result.confidence, 87);
    });
  });
}
