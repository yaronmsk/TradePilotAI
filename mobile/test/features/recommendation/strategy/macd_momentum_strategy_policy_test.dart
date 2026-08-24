import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/strategy/macd_momentum_strategy_policy.dart';

void main() {
  group('MacdMomentumStrategyPolicy', () {
    test('daily Swing keeps 12/26/9 and uses 3-bar transition context', () {
      final policy = MacdMomentumStrategyPolicy.forStrategy(
        strategy: StrategyType.swing,
        timeframe: '1d',
      );

      expect(policy, isNotNull);
      expect(policy!.fastPeriod, 12);
      expect(policy.slowPeriod, 26);
      expect(policy.signalPeriod, 9);
      expect(policy.transitionLookback, 3);
      expect(policy.freshCrossoverBars, 3);
      expect(policy.atrPeriod, 14);
    });

    test('4H Swing uses faster transition observation', () {
      final policy = MacdMomentumStrategyPolicy.forStrategy(
        strategy: StrategyType.swing,
        timeframe: '4h',
      );

      expect(policy, isNotNull);
      expect(policy!.transitionLookback, 2);
      expect(policy.minimumCandleCount, 40);
    });

    test('unsupported Swing timeframe has no MACD policy', () {
      expect(
        MacdMomentumStrategyPolicy.forStrategy(
          strategy: StrategyType.swing,
          timeframe: '1h',
        ),
        isNull,
      );
    });
  });
}
