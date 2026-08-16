enum StockBehaviorType { unknown, steady, balanced, volatile }

enum VolatilityRegime { unknown, calm, normal, elevated }

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
      sampleSize = 0;

  final StockBehaviorType behaviorType;
  final VolatilityRegime volatilityRegime;
  final double averageVolume;
  final double relativeVolume;
  final double atrPercent;
  final double baselineAtrPercent;
  final double volatilityRatio;
  final double trendEfficiency;
  final int sampleSize;

  bool get hasSufficientData => sampleSize >= 3;
}
