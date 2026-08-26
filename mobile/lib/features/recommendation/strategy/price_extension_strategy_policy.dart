import '../models/strategy_summary.dart';

class PriceExtensionStrategyPolicy {
  const PriceExtensionStrategyPolicy({
    required this.strategy,
    required this.timeframe,
    required this.referenceEmaPeriod,
    required this.atrPeriod,
    required this.minimumCandles,
    required this.targetCandles,
    required this.elevatedExtensionAtr,
    required this.extendedAtr,
    required this.veryExtendedAtr,
    required this.normalQualityScore,
    required this.elevatedQualityScore,
    required this.extendedQualityScore,
    required this.veryExtendedQualityScore,
    required this.maximumReliability,
  });

  static const swingDaily = PriceExtensionStrategyPolicy(
    strategy: StrategyType.swing,
    timeframe: '1d',
    referenceEmaPeriod: 20,
    atrPeriod: 14,
    minimumCandles: 30,
    targetCandles: 50,
    elevatedExtensionAtr: 1.25,
    extendedAtr: 2.25,
    veryExtendedAtr: 3.25,
    normalQualityScore: 78,
    elevatedQualityScore: 62,
    extendedQualityScore: 48,
    veryExtendedQualityScore: 32,
    maximumReliability: 0.88,
  );

  static const swingFourHour = PriceExtensionStrategyPolicy(
    strategy: StrategyType.swing,
    timeframe: '4h',
    referenceEmaPeriod: 20,
    atrPeriod: 14,
    minimumCandles: 40,
    targetCandles: 60,
    elevatedExtensionAtr: 1.50,
    extendedAtr: 2.50,
    veryExtendedAtr: 3.50,
    normalQualityScore: 78,
    elevatedQualityScore: 62,
    extendedQualityScore: 48,
    veryExtendedQualityScore: 32,
    maximumReliability: 0.84,
  );

  final StrategyType strategy;
  final String timeframe;

  final int referenceEmaPeriod;
  final int atrPeriod;
  final int minimumCandles;
  final int targetCandles;

  final double elevatedExtensionAtr;
  final double extendedAtr;
  final double veryExtendedAtr;

  final double normalQualityScore;
  final double elevatedQualityScore;
  final double extendedQualityScore;
  final double veryExtendedQualityScore;

  final double maximumReliability;

  static PriceExtensionStrategyPolicy? forStrategy({
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
