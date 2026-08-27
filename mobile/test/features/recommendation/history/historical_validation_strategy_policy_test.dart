import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/stock_behavior_profile.dart';
import 'package:mobile/features/recommendation/history/historical_validation_strategy_policy.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';

void main() {
  group('HistoricalValidationStrategyPolicy', () {
    test('Trader preserves the established historical scoring policy', () {
      const policy = HistoricalValidationStrategyPolicy.trader;

      expect(policy.minimumMatchedCases, 8);
      expect(policy.effectiveSampleFloor, 8);
      expect(policy.effectiveSampleFull, 30);
      expect(policy.matchSimilarityFloor, 0.58);
      expect(policy.matchSimilarityFull, 0.82);

      expect(policy.expectedMoveScaleFor(StockBehaviorType.steady), 0.8);
      expect(policy.expectedMoveScaleFor(StockBehaviorType.balanced), 1.3);
      expect(policy.expectedMoveScaleFor(StockBehaviorType.volatile), 2.1);
    });

    test('Swing 4H uses its own outcome and reliability calibration', () {
      final policy = HistoricalValidationStrategyPolicy.forContext(
        strategy: StrategyType.swing,
        primaryTimeframe: '4h',
      );

      expect(
        identical(policy, HistoricalValidationStrategyPolicy.swingFourHour),
        isTrue,
      );

      expect(policy.minimumMatchedCases, 10);
      expect(policy.effectiveSampleFloor, 10);
      expect(policy.effectiveSampleFull, 32);
      expect(policy.matchSimilarityFloor, 0.60);
      expect(policy.matchSimilarityFull, 0.84);

      expect(policy.expectedMoveScaleFor(StockBehaviorType.steady), 2.0);
      expect(policy.expectedMoveScaleFor(StockBehaviorType.balanced), 3.3);
      expect(policy.expectedMoveScaleFor(StockBehaviorType.volatile), 5.5);
    });

    test('Swing 1D uses the ten-day movement scale', () {
      final policy = HistoricalValidationStrategyPolicy.forContext(
        strategy: StrategyType.swing,
        primaryTimeframe: '1d',
      );

      expect(
        identical(policy, HistoricalValidationStrategyPolicy.swingDaily),
        isTrue,
      );

      expect(policy.expectedMoveScaleFor(StockBehaviorType.steady), 2.5);
      expect(policy.expectedMoveScaleFor(StockBehaviorType.balanced), 4.0);
      expect(policy.expectedMoveScaleFor(StockBehaviorType.volatile), 6.5);
    });

    test('Investor fallback is explicitly not v0.12 calibration', () {
      final policy = HistoricalValidationStrategyPolicy.forContext(
        strategy: StrategyType.investor,
        primaryTimeframe: '1d',
      );

      expect(policy.isStrategyCalibrated, isFalse);

      expect(
        identical(
          policy,
          HistoricalValidationStrategyPolicy.investorLegacyFallback,
        ),
        isTrue,
      );
    });
  });
}
