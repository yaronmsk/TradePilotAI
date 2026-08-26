import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/strategy/market_context_strategy_policy.dart';

void main() {
  group('MarketContextStrategyPolicy', () {
    test('Trader preserves validated context calibration', () {
      const policy = MarketContextStrategyPolicy.trader;

      expect(policy.confirmationWeight, 0.55);
      expect(policy.regimeWeight, 0.45);
      expect(policy.directionThreshold, 8);
      expect(policy.providerBaseWeight, 0.85);
      expect(policy.preserveMissingSectorDuplication, isTrue);
    });

    test('Swing uses a confirmation-led conservative context policy', () {
      const policy = MarketContextStrategyPolicy.swing;

      expect(policy.confirmationWeight, 0.65);
      expect(policy.regimeWeight, 0.35);
      expect(policy.directionThreshold, 12);
      expect(policy.conflictDirectionThreshold, 35);
      expect(policy.providerBaseWeight, 0.75);
      expect(policy.conflictDynamicWeight, 0.70);
      expect(policy.preserveMissingSectorDuplication, isFalse);
    });

    test('Investor remains deliberately uncalibrated in v0.11', () {
      expect(
        MarketContextStrategyPolicy.forStrategy(StrategyType.investor),
        isNull,
      );
    });
  });
}
