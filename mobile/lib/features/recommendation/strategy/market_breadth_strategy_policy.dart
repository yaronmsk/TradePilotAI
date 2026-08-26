import '../models/strategy_summary.dart';

class MarketBreadthStrategyPolicy {
  const MarketBreadthStrategyPolicy({
    required this.strategy,
    required this.advancingWeight,
    required this.aboveMediumTermWeight,
    required this.sectorParticipationWeight,
    required this.directionThreshold,
    required this.strongThreshold,
    required this.providerBaseWeight,
    required this.highVolatilityPercentile,
    required this.extremeVolatilityPercentile,
    required this.highVolatilityDynamicWeight,
    required this.extremeVolatilityDynamicWeight,
    required this.useExistingDirectionScore,
  });

  static const trader = MarketBreadthStrategyPolicy(
    strategy: StrategyType.trader,
    advancingWeight: 0,
    aboveMediumTermWeight: 0,
    sectorParticipationWeight: 0,
    directionThreshold: 8,
    strongThreshold: 55,
    providerBaseWeight: 0.65,
    highVolatilityPercentile: 100,
    extremeVolatilityPercentile: 100,
    highVolatilityDynamicWeight: 1,
    extremeVolatilityDynamicWeight: 1,
    useExistingDirectionScore: true,
  );

  static const swing = MarketBreadthStrategyPolicy(
    strategy: StrategyType.swing,
    advancingWeight: 0.25,
    aboveMediumTermWeight: 0.45,
    sectorParticipationWeight: 0.30,
    directionThreshold: 18,
    strongThreshold: 55,
    providerBaseWeight: 0.55,
    highVolatilityPercentile: 75,
    extremeVolatilityPercentile: 90,
    highVolatilityDynamicWeight: 0.85,
    extremeVolatilityDynamicWeight: 0.70,
    useExistingDirectionScore: false,
  );

  final StrategyType strategy;

  final double advancingWeight;
  final double aboveMediumTermWeight;
  final double sectorParticipationWeight;

  final double directionThreshold;
  final double strongThreshold;

  final double providerBaseWeight;

  final double highVolatilityPercentile;
  final double extremeVolatilityPercentile;

  final double highVolatilityDynamicWeight;
  final double extremeVolatilityDynamicWeight;

  final bool useExistingDirectionScore;

  static MarketBreadthStrategyPolicy? forStrategy(StrategyType strategy) {
    return switch (strategy) {
      StrategyType.trader => trader,
      StrategyType.swing => swing,
      StrategyType.investor => null,
    };
  }
}
