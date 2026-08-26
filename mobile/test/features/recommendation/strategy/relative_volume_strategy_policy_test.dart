import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/strategy/relative_volume_strategy_policy.dart';

void main() {
  group('RelativeVolumeStrategyPolicy', () {
    test('1D Swing can use sequential daily history', () {
      final policy = RelativeVolumeStrategyPolicy.forStrategy(
        strategy: StrategyType.swing,
        timeframe: '1d',
      );

      expect(policy, isNotNull);
      expect(policy!.lookback, 20);
      expect(policy.minimumHistoricalCandles, 10);
      expect(policy.targetHistoricalCandles, 20);
      expect(policy.canEvaluateFromSequentialCandles, isTrue);
    });

    test('4H Swing requires comparable session-position history', () {
      final policy = RelativeVolumeStrategyPolicy.forStrategy(
        strategy: StrategyType.swing,
        timeframe: '4h',
      );

      expect(policy, isNotNull);
      expect(policy!.requiresComparableSessionPositionHistory, isTrue);
      expect(policy.canEvaluateFromSequentialCandles, isFalse);
    });

    test('unsupported Swing interval has no RVOL policy', () {
      expect(
        RelativeVolumeStrategyPolicy.forStrategy(
          strategy: StrategyType.swing,
          timeframe: '1h',
        ),
        isNull,
      );
    });
  });
}
