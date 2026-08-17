enum StockBehaviorType { unknown, steady, balanced, volatile }

enum VolatilityRegime { unknown, calm, normal, elevated }

enum StockBaselineSource { shortTermSnapshot, oneYearDailyHistory }

class StockBehaviorProfile {
  const StockBehaviorProfile({
    required this.behaviorType,
    required this.volatilityRegime,
    required this.averageVolume,
    required this.relativeVolume,
    required this.atrPercent,
    required this.baselineAtrPercent,
    required this.volatilityRatio,
    required this.trendEfficiency,
    required this.sampleSize,
    this.baselineSource = StockBaselineSource.shortTermSnapshot,
    this.historicalSampleSize = 0,
    this.typicalDailyAtrPercent = 0,
    this.recentRealizedVolatilityPercent = 0,
    this.typicalRealizedVolatilityPercent = 0,
    this.volatilityPercentile = 50,
    this.averageDailyVolume20 = 0,
    this.averageDailyVolume60 = 0,
    this.volumeTrendRatio = 1,
    this.volumeVariability = 0,
    this.historicalTrendEfficiency20 = 0,
    this.historicalTrendEfficiency60 = 0,
  });

  const StockBehaviorProfile.unknown()
    : behaviorType = StockBehaviorType.unknown,
      volatilityRegime = VolatilityRegime.unknown,
      averageVolume = 0,
      relativeVolume = 1,
      atrPercent = 0,
      baselineAtrPercent = 0,
      volatilityRatio = 1,
      trendEfficiency = 0,
      sampleSize = 0,
      baselineSource = StockBaselineSource.shortTermSnapshot,
      historicalSampleSize = 0,
      typicalDailyAtrPercent = 0,
      recentRealizedVolatilityPercent = 0,
      typicalRealizedVolatilityPercent = 0,
      volatilityPercentile = 50,
      averageDailyVolume20 = 0,
      averageDailyVolume60 = 0,
      volumeTrendRatio = 1,
      volumeVariability = 0,
      historicalTrendEfficiency20 = 0,
      historicalTrendEfficiency60 = 0;

  final StockBehaviorType behaviorType;
  final VolatilityRegime volatilityRegime;

  /// Short-term average volume from the active analysis snapshot.
  final double averageVolume;

  /// Current active-analysis volume relative to its recent short-term average.
  final double relativeVolume;

  /// Short-term normalized ATR from the active analysis snapshot.
  final double atrPercent;

  /// Short-term ATR baseline from the active analysis snapshot.
  final double baselineAtrPercent;

  /// Short-term ATR versus its snapshot baseline.
  final double volatilityRatio;

  /// Current analysis-window trend efficiency.
  final double trendEfficiency;
  final int sampleSize;

  final StockBaselineSource baselineSource;
  final int historicalSampleSize;

  /// Typical daily normalized ATR from the long-term daily history.
  final double typicalDailyAtrPercent;

  /// Latest annualized 20-session realized volatility.
  final double recentRealizedVolatilityPercent;

  /// Typical historical annualized 20-session realized volatility.
  final double typicalRealizedVolatilityPercent;

  /// Current realized-volatility percentile versus the stock's own history.
  final double volatilityPercentile;

  final double averageDailyVolume20;
  final double averageDailyVolume60;
  final double volumeTrendRatio;

  /// Coefficient of variation for the latest 60 daily-volume observations.
  final double volumeVariability;

  final double historicalTrendEfficiency20;
  final double historicalTrendEfficiency60;

  bool get hasSufficientData => sampleSize >= 3;

  bool get hasHistoricalBaseline =>
      baselineSource == StockBaselineSource.oneYearDailyHistory &&
      historicalSampleSize >= 60;
}
