import '../models/strategy_summary.dart';

class NewsSentimentStrategyPolicy {
  const NewsSentimentStrategyPolicy({
    required this.strategy,
    required this.minimumArticleCount,
    required this.minimumSourceCount,
    required this.minimumIndependentStoryCount,
    required this.directionThreshold,
    required this.minimumDirectionalMateriality,
    required this.fullFreshnessHours,
    required this.directionalFreshnessHours,
    required this.maximumFreshnessHours,
    required this.minimumFreshnessFactor,
    required this.providerBaseWeight,
    required this.useExistingBehavior,
  });

  static const trader = NewsSentimentStrategyPolicy(
    strategy: StrategyType.trader,
    minimumArticleCount: 3,
    minimumSourceCount: 2,
    minimumIndependentStoryCount: 0,
    directionThreshold: 15,
    minimumDirectionalMateriality: 0,
    fullFreshnessHours: 0,
    directionalFreshnessHours: double.infinity,
    maximumFreshnessHours: double.infinity,
    minimumFreshnessFactor: 1,
    providerBaseWeight: 0.55,
    useExistingBehavior: true,
  );

  static const swing = NewsSentimentStrategyPolicy(
    strategy: StrategyType.swing,
    minimumArticleCount: 3,
    minimumSourceCount: 2,
    minimumIndependentStoryCount: 2,
    directionThreshold: 20,
    minimumDirectionalMateriality: 0.45,
    fullFreshnessHours: 24,
    directionalFreshnessHours: 120,
    maximumFreshnessHours: 168,
    minimumFreshnessFactor: 0.35,
    providerBaseWeight: 0.50,
    useExistingBehavior: false,
  );

  final StrategyType strategy;

  final int minimumArticleCount;
  final int minimumSourceCount;
  final int minimumIndependentStoryCount;

  final double directionThreshold;
  final double minimumDirectionalMateriality;

  final double fullFreshnessHours;
  final double directionalFreshnessHours;
  final double maximumFreshnessHours;
  final double minimumFreshnessFactor;

  final double providerBaseWeight;
  final bool useExistingBehavior;

  static NewsSentimentStrategyPolicy? forStrategy(StrategyType strategy) {
    return switch (strategy) {
      StrategyType.trader => trader,
      StrategyType.swing => swing,
      StrategyType.investor => null,
    };
  }
}
