import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/strategy/support_resistance_strategy_policy.dart';

void main() {
  group('SupportResistanceStrategyPolicy', () {
    test(
      '1D Swing uses multi-session structure and two-close confirmation',
      () {
        final policy = SupportResistanceStrategyPolicy.forStrategy(
          strategy: StrategyType.swing,
          timeframe: '1d',
        );

        expect(policy, isNotNull);
        expect(policy!.structureLookback, 40);
        expect(policy.minimumCandles, 24);
        expect(policy.atrPeriod, 14);
        expect(policy.confirmationCloses, 2);
        expect(policy.breakoutBufferAtr, 0.20);
        expect(policy.proximityAtr, 0.50);
      },
    );

    test('4H Swing uses longer structure and three-close confirmation', () {
      final policy = SupportResistanceStrategyPolicy.forStrategy(
        strategy: StrategyType.swing,
        timeframe: '4h',
      );

      expect(policy, isNotNull);
      expect(policy!.structureLookback, 60);
      expect(policy.minimumCandles, 30);
      expect(policy.confirmationCloses, 3);
      expect(policy.breakoutBufferAtr, 0.25);
      expect(policy.maximumReliability, 0.85);
    });

    test('unsupported interval and non-Swing strategy have no policy', () {
      expect(
        SupportResistanceStrategyPolicy.forStrategy(
          strategy: StrategyType.swing,
          timeframe: '1h',
        ),
        isNull,
      );

      expect(
        SupportResistanceStrategyPolicy.forStrategy(
          strategy: StrategyType.investor,
          timeframe: '1d',
        ),
        isNull,
      );
    });
  });
}
