import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/strategy/volume_confirmation_strategy_policy.dart';

void main() {
  group('VolumeConfirmationStrategyPolicy', () {
    test('1D Swing uses daily multi-session calibration', () {
      final policy = VolumeConfirmationStrategyPolicy.forStrategy(
        strategy: StrategyType.swing,
        timeframe: '1d',
      );

      expect(policy, isNotNull);
      expect(policy!.lookback, 20);
      expect(policy.minimumCandles, 14);
      expect(policy.atrPeriod, 14);
      expect(policy.minimumDirectionalMoveAtr, 1.25);
      expect(policy.expandingVolumeRatio, 1.20);
      expect(policy.fadingVolumeRatio, 0.80);
    });

    test('4H Swing uses a longer and more conservative calibration', () {
      final policy = VolumeConfirmationStrategyPolicy.forStrategy(
        strategy: StrategyType.swing,
        timeframe: '4h',
      );

      expect(policy, isNotNull);
      expect(policy!.lookback, 30);
      expect(policy.minimumCandles, 18);
      expect(policy.minimumDirectionalMoveAtr, 1.50);
      expect(policy.maximumReliability, 0.82);
    });

    test('unsupported interval and non-Swing strategy have no policy', () {
      expect(
        VolumeConfirmationStrategyPolicy.forStrategy(
          strategy: StrategyType.swing,
          timeframe: '1h',
        ),
        isNull,
      );

      expect(
        VolumeConfirmationStrategyPolicy.forStrategy(
          strategy: StrategyType.investor,
          timeframe: '1d',
        ),
        isNull,
      );
    });
  });
}
