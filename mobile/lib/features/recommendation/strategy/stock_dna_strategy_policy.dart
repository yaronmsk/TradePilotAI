import '../models/strategy_summary.dart';

class StockDnaStrategyPolicy {
  const StockDnaStrategyPolicy({
    required this.strategy,
    required this.requiresHistoricalBaseline,
    required this.minimumDynamicWeight,
    required this.maximumDynamicWeight,
    required this.persistentTrend20,
    required this.persistentTrend60,
    required this.weakTrend20,
    required this.weakTrend60,
    required this.highVolatilityPercentile,
    required this.stableVolumeVariability,
    required this.erraticVolumeVariability,
  });

  static const trader = StockDnaStrategyPolicy(
    strategy: StrategyType.trader,
    requiresHistoricalBaseline: false,
    minimumDynamicWeight: 0.50,
    maximumDynamicWeight: 1.50,
    persistentTrend20: 0,
    persistentTrend60: 0,
    weakTrend20: 0,
    weakTrend60: 0,
    highVolatilityPercentile: 100,
    stableVolumeVariability: 0.25,
    erraticVolumeVariability: 0.50,
  );

  static const swing = StockDnaStrategyPolicy(
    strategy: StrategyType.swing,
    requiresHistoricalBaseline: true,
    minimumDynamicWeight: 0.75,
    maximumDynamicWeight: 1.20,
    persistentTrend20: 0.55,
    persistentTrend60: 0.45,
    weakTrend20: 0.35,
    weakTrend60: 0.35,
    highVolatilityPercentile: 85,
    stableVolumeVariability: 0.25,
    erraticVolumeVariability: 0.50,
  );

  final StrategyType strategy;

  final bool requiresHistoricalBaseline;

  final double minimumDynamicWeight;
  final double maximumDynamicWeight;

  final double persistentTrend20;
  final double persistentTrend60;

  final double weakTrend20;
  final double weakTrend60;

  final double highVolatilityPercentile;

  final double stableVolumeVariability;
  final double erraticVolumeVariability;

  static StockDnaStrategyPolicy? forStrategy(StrategyType strategy) {
    return switch (strategy) {
      StrategyType.trader => trader,
      StrategyType.swing => swing,
      StrategyType.investor => null,
    };
  }
}
