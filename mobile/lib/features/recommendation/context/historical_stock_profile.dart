class HistoricalStockProfile {
  const HistoricalStockProfile({
    required this.sampleSize,
    required this.recentAtrPercent,
    required this.typicalAtrPercent,
    required this.atrPercentile,
    required this.recentRealizedVolatilityPercent,
    required this.typicalRealizedVolatilityPercent,
    required this.volatilityPercentile,
    required this.averageDailyVolume20,
    required this.averageDailyVolume60,
    required this.volumeTrendRatio,
    required this.volumeVariability,
    required this.trendEfficiency20,
    required this.trendEfficiency60,
  });

  const HistoricalStockProfile.unknown({this.sampleSize = 0})
    : recentAtrPercent = 0,
      typicalAtrPercent = 0,
      atrPercentile = 50,
      recentRealizedVolatilityPercent = 0,
      typicalRealizedVolatilityPercent = 0,
      volatilityPercentile = 50,
      averageDailyVolume20 = 0,
      averageDailyVolume60 = 0,
      volumeTrendRatio = 1,
      volumeVariability = 0,
      trendEfficiency20 = 0,
      trendEfficiency60 = 0;

  final int sampleSize;

  /// Latest normalized 14-session ATR, expressed as a percentage of price.
  final double recentAtrPercent;

  /// Median normalized 14-session ATR across the available daily history.
  final double typicalAtrPercent;

  /// Percentile rank of recent ATR versus the stock's own historical ATR.
  final double atrPercentile;

  /// Annualized 20-session realized volatility from log returns.
  final double recentRealizedVolatilityPercent;

  /// Median annualized 20-session realized volatility across history.
  final double typicalRealizedVolatilityPercent;

  /// Percentile rank of recent realized volatility versus its own history.
  final double volatilityPercentile;

  final double averageDailyVolume20;
  final double averageDailyVolume60;

  /// Recent 20-session average volume divided by 60-session average volume.
  final double volumeTrendRatio;

  /// Coefficient of variation of daily volume over the latest 60 sessions.
  final double volumeVariability;

  final double trendEfficiency20;
  final double trendEfficiency60;

  bool get hasSufficientData => sampleSize >= 60;
}
