import '../models/strategy_summary.dart';

class RsiStrategyPolicy {
  const RsiStrategyPolicy({
    required this.strategy,
    required this.rsiPeriod,
    required this.contextFastEmaPeriod,
    required this.contextSlowEmaPeriod,
    required this.contextSlopeLookback,
    required this.minimumCandleCount,
    required this.targetCandleCount,
    required this.bullishMomentumFloor,
    required this.strongBullishFloor,
    required this.bearishMomentumCeiling,
    required this.strongBearishCeiling,
    required this.extremeHigh,
    required this.extremeLow,
    required this.extremeDynamicWeight,
  });

  static const swingDaily = RsiStrategyPolicy(
    strategy: StrategyType.swing,
    rsiPeriod: 14,
    contextFastEmaPeriod: 20,
    contextSlowEmaPeriod: 50,
    contextSlopeLookback: 5,
    minimumCandleCount: 55,
    targetCandleCount: 80,
    bullishMomentumFloor: 55,
    strongBullishFloor: 62,
    bearishMomentumCeiling: 45,
    strongBearishCeiling: 38,
    extremeHigh: 80,
    extremeLow: 20,
    extremeDynamicWeight: 0.65,
  );

  static const swingFourHour = RsiStrategyPolicy(
    strategy: StrategyType.swing,
    rsiPeriod: 14,
    contextFastEmaPeriod: 20,
    contextSlowEmaPeriod: 50,
    contextSlopeLookback: 3,
    minimumCandleCount: 53,
    targetCandleCount: 60,
    bullishMomentumFloor: 55,
    strongBullishFloor: 62,
    bearishMomentumCeiling: 45,
    strongBearishCeiling: 38,
    extremeHigh: 80,
    extremeLow: 20,
    extremeDynamicWeight: 0.65,
  );

  final StrategyType strategy;
  final int rsiPeriod;
  final int contextFastEmaPeriod;
  final int contextSlowEmaPeriod;
  final int contextSlopeLookback;
  final int minimumCandleCount;
  final int targetCandleCount;

  final double bullishMomentumFloor;
  final double strongBullishFloor;
  final double bearishMomentumCeiling;
  final double strongBearishCeiling;
  final double extremeHigh;
  final double extremeLow;

  final double extremeDynamicWeight;

  static RsiStrategyPolicy? forStrategy({
    required StrategyType strategy,
    required String timeframe,
  }) {
    if (strategy != StrategyType.swing) {
      return null;
    }

    return switch (timeframe.toLowerCase()) {
      '1d' => swingDaily,
      '4h' => swingFourHour,
      _ => null,
    };
  }
}
