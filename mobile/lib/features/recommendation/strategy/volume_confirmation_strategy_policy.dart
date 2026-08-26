import '../models/strategy_summary.dart';

class VolumeConfirmationStrategyPolicy {
  const VolumeConfirmationStrategyPolicy({
    required this.strategy,
    required this.timeframe,
    required this.lookback,
    required this.minimumCandles,
    required this.targetCandles,
    required this.atrPeriod,
    required this.minimumDirectionalMoveAtr,
    required this.strongDirectionalMoveAtr,
    required this.expandingVolumeRatio,
    required this.strongExpandingVolumeRatio,
    required this.fadingVolumeRatio,
    required this.strongFadingVolumeRatio,
    required this.maximumReliability,
  });

  static const swingDaily = VolumeConfirmationStrategyPolicy(
    strategy: StrategyType.swing,
    timeframe: '1d',
    lookback: 20,
    minimumCandles: 14,
    targetCandles: 20,
    atrPeriod: 14,
    minimumDirectionalMoveAtr: 1.25,
    strongDirectionalMoveAtr: 2.50,
    expandingVolumeRatio: 1.20,
    strongExpandingVolumeRatio: 1.50,
    fadingVolumeRatio: 0.80,
    strongFadingVolumeRatio: 0.60,
    maximumReliability: 0.88,
  );

  static const swingFourHour = VolumeConfirmationStrategyPolicy(
    strategy: StrategyType.swing,
    timeframe: '4h',
    lookback: 30,
    minimumCandles: 18,
    targetCandles: 30,
    atrPeriod: 14,
    minimumDirectionalMoveAtr: 1.50,
    strongDirectionalMoveAtr: 3.00,
    expandingVolumeRatio: 1.20,
    strongExpandingVolumeRatio: 1.50,
    fadingVolumeRatio: 0.80,
    strongFadingVolumeRatio: 0.60,
    maximumReliability: 0.82,
  );

  final StrategyType strategy;
  final String timeframe;

  final int lookback;
  final int minimumCandles;
  final int targetCandles;
  final int atrPeriod;

  final double minimumDirectionalMoveAtr;
  final double strongDirectionalMoveAtr;

  final double expandingVolumeRatio;
  final double strongExpandingVolumeRatio;
  final double fadingVolumeRatio;
  final double strongFadingVolumeRatio;

  final double maximumReliability;

  static VolumeConfirmationStrategyPolicy? forStrategy({
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
