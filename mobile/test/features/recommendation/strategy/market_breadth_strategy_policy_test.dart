import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/strategy/market_breadth_strategy_policy.dart';

void main() {
  group('MarketBreadthStrategyPolicy', () {
    test('Trader preserves validated Breadth calibration', () {
      const policy = MarketBreadthStrategyPolicy.trader;

      expect(policy.useExistingDirectionScore, isTrue);
      expect(policy.directionThreshold, 8);
      expect(policy.providerBaseWeight, 0.65);
    });

    test('Swing emphasizes medium-term participation', () {
      const policy = MarketBreadthStrategyPolicy.swing;

      expect(policy.useExistingDirectionScore, isFalse);
      expect(policy.advancingWeight, 0.25);
      expect(policy.aboveMediumTermWeight, 0.45);
      expect(policy.sectorParticipationWeight, 0.30);

      expect(
        policy.advancingWeight +
            policy.aboveMediumTermWeight +
            policy.sectorParticipationWeight,
        1,
      );

      expect(policy.directionThreshold, 18);
      expect(policy.providerBaseWeight, 0.55);
    });

    test('Swing volatility only reduces Breadth influence', () {
      const policy = MarketBreadthStrategyPolicy.swing;

      expect(policy.highVolatilityPercentile, 75);
      expect(policy.extremeVolatilityPercentile, 90);
      expect(policy.highVolatilityDynamicWeight, 0.85);
      expect(policy.extremeVolatilityDynamicWeight, 0.70);
    });

    test('Investor remains uncalibrated in v0.11', () {
      expect(
        MarketBreadthStrategyPolicy.forStrategy(StrategyType.investor),
        isNull,
      );
    });
  });
}
