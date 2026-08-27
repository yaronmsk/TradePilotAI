import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/strategy/stock_dna_strategy_policy.dart';

void main() {
  group('StockDnaStrategyPolicy', () {
    test('Trader preserves fallback behavior and legacy weight range', () {
      const policy = StockDnaStrategyPolicy.trader;

      expect(policy.requiresHistoricalBaseline, isFalse);
      expect(policy.minimumDynamicWeight, 0.50);
      expect(policy.maximumDynamicWeight, 1.50);
    });

    test(
      'Swing requires daily history and uses bounded contextual influence',
      () {
        const policy = StockDnaStrategyPolicy.swing;

        expect(policy.requiresHistoricalBaseline, isTrue);
        expect(policy.minimumDynamicWeight, 0.75);
        expect(policy.maximumDynamicWeight, 1.20);

        expect(policy.persistentTrend20, 0.55);
        expect(policy.persistentTrend60, 0.45);
        expect(policy.highVolatilityPercentile, 85);
        expect(policy.stableVolumeVariability, 0.25);
        expect(policy.erraticVolumeVariability, 0.50);
      },
    );

    test('Investor Stock DNA remains deferred to v0.12', () {
      expect(StockDnaStrategyPolicy.forStrategy(StrategyType.investor), isNull);
    });
  });
}
