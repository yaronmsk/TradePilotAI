import '../models/strategy_summary.dart';

class MacdMomentumStrategyPolicy {
  const MacdMomentumStrategyPolicy({
    required this.strategy,
    required this.fastPeriod,
    required this.slowPeriod,
    required this.signalPeriod,
    required this.transitionLookback,
    required this.freshCrossoverBars,
    required this.minimumCandleCount,
    required this.targetCandleCount,
    required this.atrPeriod,
    required this.strongHistogramAtr,
    required this.exceptionalHistogramAtr,
    required this.transitionDynamicWeight,
    required this.weakeningDynamicWeight,
    required this.neutralDynamicWeight,
  });

  static const swingDaily = MacdMomentumStrategyPolicy(
    strategy: StrategyType.swing,
    fastPeriod: 12,
    slowPeriod: 26,
    signalPeriod: 9,
    transitionLookback: 3,
    freshCrossoverBars: 3,
    minimumCandleCount: 40,
    targetCandleCount: 60,
    atrPeriod: 14,
    strongHistogramAtr: 0.20,
    exceptionalHistogramAtr: 0.40,
    transitionDynamicWeight: 0.85,
    weakeningDynamicWeight: 0.75,
    neutralDynamicWeight: 0.75,
  );

  static const swingFourHour = MacdMomentumStrategyPolicy(
    strategy: StrategyType.swing,
    fastPeriod: 12,
    slowPeriod: 26,
    signalPeriod: 9,
    transitionLookback: 2,
    freshCrossoverBars: 3,
    minimumCandleCount: 40,
    targetCandleCount: 60,
    atrPeriod: 14,
    strongHistogramAtr: 0.20,
    exceptionalHistogramAtr: 0.40,
    transitionDynamicWeight: 0.85,
    weakeningDynamicWeight: 0.75,
    neutralDynamicWeight: 0.75,
  );

  final StrategyType strategy;

  final int fastPeriod;
  final int slowPeriod;
  final int signalPeriod;

  final int transitionLookback;
  final int freshCrossoverBars;

  final int minimumCandleCount;
  final int targetCandleCount;

  final int atrPeriod;

  final double strongHistogramAtr;
  final double exceptionalHistogramAtr;

  final double transitionDynamicWeight;
  final double weakeningDynamicWeight;
  final double neutralDynamicWeight;

  static MacdMomentumStrategyPolicy? forStrategy({
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
