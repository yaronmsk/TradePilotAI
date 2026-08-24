import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/strategy/ema_structure_strategy_policy.dart';

void main() {
  group('EmaStructureStrategyPolicy', () {
    test('daily Swing uses 20/50 EMA structure', () {
      final policy = EmaStructureStrategyPolicy.forStrategy(
        strategy: StrategyType.swing,
        timeframe: '1d',
      );

      expect(policy, isNotNull);
      expect(policy!.fastPeriod, 20);
      expect(policy.slowPeriod, 50);
      expect(policy.slopeLookback, 5);
      expect(policy.minimumCandleCount, 55);
      expect(policy.targetCandleCount, 80);
    });

    test('4H Swing uses shorter slope lookback', () {
      final policy = EmaStructureStrategyPolicy.forStrategy(
        strategy: StrategyType.swing,
        timeframe: '4h',
      );

      expect(policy, isNotNull);
      expect(policy!.fastPeriod, 20);
      expect(policy.slowPeriod, 50);
      expect(policy.slopeLookback, 3);
      expect(policy.minimumCandleCount, 53);
      expect(policy.targetCandleCount, 60);
    });

    test('unsupported interval has no Swing policy', () {
      expect(
        EmaStructureStrategyPolicy.forStrategy(
          strategy: StrategyType.swing,
          timeframe: '1h',
        ),
        isNull,
      );
    });
  });
}
