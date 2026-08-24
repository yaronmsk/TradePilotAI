import '../models/strategy_summary.dart';

class EmaStructureStrategyPolicy {
  const EmaStructureStrategyPolicy({
    required this.strategy,
    required this.fastPeriod,
    required this.slowPeriod,
    required this.slopeLookback,
    required this.persistenceLookback,
    required this.minimumCandleCount,
    required this.targetCandleCount,
    required this.atrPeriod,
    required this.minimumPersistence,
    required this.strongSeparationAtr,
    required this.exceptionalSeparationAtr,
  });

  static const swingDaily = EmaStructureStrategyPolicy(
    strategy: StrategyType.swing,
    fastPeriod: 20,
    slowPeriod: 50,
    slopeLookback: 5,
    persistenceLookback: 5,
    minimumCandleCount: 55,
    targetCandleCount: 80,
    atrPeriod: 14,
    minimumPersistence: 0.60,
    strongSeparationAtr: 0.75,
    exceptionalSeparationAtr: 1.50,
  );

  static const swingFourHour = EmaStructureStrategyPolicy(
    strategy: StrategyType.swing,
    fastPeriod: 20,
    slowPeriod: 50,
    slopeLookback: 3,
    persistenceLookback: 5,
    minimumCandleCount: 53,
    targetCandleCount: 60,
    atrPeriod: 14,
    minimumPersistence: 0.60,
    strongSeparationAtr: 0.75,
    exceptionalSeparationAtr: 1.50,
  );

  final StrategyType strategy;
  final int fastPeriod;
  final int slowPeriod;
  final int slopeLookback;
  final int persistenceLookback;
  final int minimumCandleCount;
  final int targetCandleCount;
  final int atrPeriod;
  final double minimumPersistence;
  final double strongSeparationAtr;
  final double exceptionalSeparationAtr;

  static EmaStructureStrategyPolicy? forStrategy({
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
