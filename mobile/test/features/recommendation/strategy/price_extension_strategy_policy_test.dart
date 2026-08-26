import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/strategy/price_extension_strategy_policy.dart';

void main() {
  group('PriceExtensionStrategyPolicy', () {
    test('1D Swing uses a medium-term volatility-normalized reference', () {
      final policy = PriceExtensionStrategyPolicy.forStrategy(
        strategy: StrategyType.swing,
        timeframe: '1d',
      );

      expect(policy, isNotNull);
      expect(policy!.referenceEmaPeriod, 20);
      expect(policy.atrPeriod, 14);
      expect(policy.minimumCandles, 30);
      expect(policy.elevatedExtensionAtr, 1.25);
      expect(policy.extendedAtr, 2.25);
      expect(policy.veryExtendedAtr, 3.25);
    });

    test('4H Swing uses a more conservative stretch threshold', () {
      final policy = PriceExtensionStrategyPolicy.forStrategy(
        strategy: StrategyType.swing,
        timeframe: '4h',
      );

      expect(policy, isNotNull);
      expect(policy!.referenceEmaPeriod, 20);
      expect(policy.minimumCandles, 40);
      expect(policy.elevatedExtensionAtr, 1.50);
      expect(policy.extendedAtr, 2.50);
      expect(policy.veryExtendedAtr, 3.50);
      expect(policy.maximumReliability, 0.84);
    });

    test('worse extension maps to lower entry-quality confidence support', () {
      const policy = PriceExtensionStrategyPolicy.swingDaily;

      expect(
        policy.normalQualityScore,
        greaterThan(policy.elevatedQualityScore),
      );

      expect(
        policy.elevatedQualityScore,
        greaterThan(policy.extendedQualityScore),
      );

      expect(
        policy.extendedQualityScore,
        greaterThan(policy.veryExtendedQualityScore),
      );
    });

    test('unsupported interval and non-Swing strategy have no policy', () {
      expect(
        PriceExtensionStrategyPolicy.forStrategy(
          strategy: StrategyType.swing,
          timeframe: '1h',
        ),
        isNull,
      );

      expect(
        PriceExtensionStrategyPolicy.forStrategy(
          strategy: StrategyType.investor,
          timeframe: '1d',
        ),
        isNull,
      );
    });
  });
}
