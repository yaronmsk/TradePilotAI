import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/strategy/news_sentiment_strategy_policy.dart';

void main() {
  group('NewsSentimentStrategyPolicy', () {
    test('Trader preserves validated sentiment behavior', () {
      const policy = NewsSentimentStrategyPolicy.trader;

      expect(policy.useExistingBehavior, isTrue);
      expect(policy.minimumArticleCount, 3);
      expect(policy.minimumSourceCount, 2);
      expect(policy.directionThreshold, 15);
      expect(policy.providerBaseWeight, 0.55);
    });

    test('Swing uses materiality and strategy-specific freshness gates', () {
      const policy = NewsSentimentStrategyPolicy.swing;

      expect(policy.useExistingBehavior, isFalse);
      expect(policy.minimumArticleCount, 3);
      expect(policy.minimumSourceCount, 2);
      expect(policy.minimumIndependentStoryCount, 2);
      expect(policy.directionThreshold, 20);
      expect(policy.minimumDirectionalMateriality, 0.45);

      expect(policy.fullFreshnessHours, 24);
      expect(policy.directionalFreshnessHours, 120);
      expect(policy.maximumFreshnessHours, 168);

      expect(policy.providerBaseWeight, 0.50);
    });

    test('Investor remains uncalibrated in v0.11', () {
      expect(
        NewsSentimentStrategyPolicy.forStrategy(StrategyType.investor),
        isNull,
      );
    });
  });
}
