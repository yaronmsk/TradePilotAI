import '../models/strategy_summary.dart';

enum CandleTrendCalibrationMode {
  traderLegacyFixedPercent,
  swingVolatilityNormalized,
}

class CandleTrendStrategyPolicy {
  const CandleTrendStrategyPolicy({
    required this.strategy,
    required this.calibrationMode,
    required this.targetCandleCount,
    required this.minimumCandleCount,
    required this.directionalThreshold,
    required this.strongThreshold,
    required this.exceptionalThreshold,
    required this.atrNoiseFactor,
    required this.volatilityFloorPercent,
  });

  /// Preserves the validated Trader behavior exactly.
  static const trader = CandleTrendStrategyPolicy(
    strategy: StrategyType.trader,
    calibrationMode: CandleTrendCalibrationMode.traderLegacyFixedPercent,
    targetCandleCount: 48,
    minimumCandleCount: 2,
    directionalThreshold: 2,
    strongThreshold: 2,
    exceptionalThreshold: 5,
    atrNoiseFactor: 0,
    volatilityFloorPercent: 0,
  );

  /// Initial deterministic Swing policy for the default 1D primary interval.
  ///
  /// Twenty daily candles represent approximately one trading month of recent
  /// structure without allowing much older price movement to dominate the
  /// current Swing setup.
  static const swingDaily = CandleTrendStrategyPolicy(
    strategy: StrategyType.swing,
    calibrationMode: CandleTrendCalibrationMode.swingVolatilityNormalized,
    targetCandleCount: 20,
    minimumCandleCount: 12,
    directionalThreshold: 0.90,
    strongThreshold: 1.50,
    exceptionalThreshold: 2.50,
    atrNoiseFactor: 0.60,
    volatilityFloorPercent: 0.25,
  );

  /// Initial deterministic Swing policy for the alternate 4H primary interval.
  static const swingFourHour = CandleTrendStrategyPolicy(
    strategy: StrategyType.swing,
    calibrationMode: CandleTrendCalibrationMode.swingVolatilityNormalized,
    targetCandleCount: 30,
    minimumCandleCount: 18,
    directionalThreshold: 0.90,
    strongThreshold: 1.50,
    exceptionalThreshold: 2.50,
    atrNoiseFactor: 0.60,
    volatilityFloorPercent: 0.25,
  );

  final StrategyType strategy;
  final CandleTrendCalibrationMode calibrationMode;

  final int targetCandleCount;
  final int minimumCandleCount;

  /// Trader values are raw percent thresholds.
  /// Swing values are volatility-normalized movement thresholds.
  final double directionalThreshold;
  final double strongThreshold;
  final double exceptionalThreshold;

  /// Converts average true-range percentage into the one-candle noise estimate
  /// used by Swing normalization.
  final double atrNoiseFactor;

  /// Prevents unrealistically small volatility estimates from making a tiny
  /// move look statistically exceptional.
  final double volatilityFloorPercent;

  static CandleTrendStrategyPolicy? forStrategy({
    required StrategyType strategy,
    required String timeframe,
  }) {
    return switch (strategy) {
      StrategyType.trader => trader,
      StrategyType.swing => switch (timeframe.toLowerCase()) {
        '1d' => swingDaily,
        '4h' => swingFourHour,
        _ => null,
      },
      StrategyType.investor => null,
    };
  }
}
