import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/strategy/recommendation_strategy_policy.dart';

void main() {
  group('RecommendationStrategyPolicy', () {
    test('Trader preserves established recommendation thresholds', () {
      const policy = RecommendationStrategyPolicy.trader;

      expect(policy.minimumProviderCoverage, 0.60);
      expect(policy.actionDirectionThreshold, 30);
      expect(policy.strongDirectionThreshold, 65);
      expect(policy.holdDirectionThreshold, 20);
      expect(policy.minimumActionConfidence, 55);
      expect(policy.strongActionConfidence, 80);
      expect(policy.minimumIndependentFamiliesForAction, 0);
      expect(policy.holdOnMaterialConflict, isFalse);
    });

    test('Swing uses stricter deterministic action thresholds', () {
      const policy = RecommendationStrategyPolicy.swing;

      expect(policy.minimumProviderCoverage, 0.65);
      expect(policy.actionDirectionThreshold, 35);
      expect(policy.strongDirectionThreshold, 70);
      expect(policy.holdDirectionThreshold, 25);
      expect(policy.minimumActionConfidence, 60);
      expect(policy.strongActionConfidence, 80);
      expect(policy.minimumIndependentFamiliesForAction, 3);
      expect(policy.holdOnMaterialConflict, isTrue);
      expect(policy.materialConflictThreshold, 0.55);
    });

    test('BUY and SELL use the same absolute Swing thresholds', () {
      const policy = RecommendationStrategyPolicy.swing;

      expect(policy.actionDirectionThreshold, greaterThan(0));
      expect(policy.strongDirectionThreshold, greaterThan(0));

      // Direction sign is applied by RecommendationEngine; one absolute
      // threshold is deliberately shared by BUY and SELL.
      expect(
        policy.strongDirectionThreshold,
        greaterThan(policy.actionDirectionThreshold),
      );
    });

    test('Investor recommendation policy remains deferred', () {
      expect(
        RecommendationStrategyPolicy.forStrategy(StrategyType.investor),
        isNull,
      );
    });
  });
}
