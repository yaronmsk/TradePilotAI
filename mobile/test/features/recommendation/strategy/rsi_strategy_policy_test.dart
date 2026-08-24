import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/strategy/rsi_strategy_policy.dart';

void main() {
  group('RsiStrategyPolicy', () {
    test('daily Swing uses RSI 14 with 20/50 trend context', () {
      final policy = RsiStrategyPolicy.forStrategy(
        strategy: StrategyType.swing,
        timeframe: '1d',
      );

      expect(policy, isNotNull);
      expect(policy!.rsiPeriod, 14);
      expect(policy.contextFastEmaPeriod, 20);
      expect(policy.contextSlowEmaPeriod, 50);
      expect(policy.contextSlopeLookback, 5);
      expect(policy.bullishMomentumFloor, 55);
      expect(policy.bearishMomentumCeiling, 45);
      expect(policy.extremeHigh, 80);
      expect(policy.extremeLow, 20);
    });

    test('4H Swing uses shorter context slope lookback', () {
      final policy = RsiStrategyPolicy.forStrategy(
        strategy: StrategyType.swing,
        timeframe: '4h',
      );

      expect(policy, isNotNull);
      expect(policy!.contextSlopeLookback, 3);
      expect(policy.minimumCandleCount, 53);
    });

    test('unsupported Swing timeframe has no RSI policy', () {
      expect(
        RsiStrategyPolicy.forStrategy(
          strategy: StrategyType.swing,
          timeframe: '1h',
        ),
        isNull,
      );
    });
  });
}
