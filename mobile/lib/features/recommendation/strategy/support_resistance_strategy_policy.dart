import '../models/strategy_summary.dart';

class SupportResistanceStrategyPolicy {
  const SupportResistanceStrategyPolicy({
    required this.strategy,
    required this.timeframe,
    required this.structureLookback,
    required this.minimumCandles,
    required this.atrPeriod,
    required this.confirmationCloses,
    required this.breakoutBufferAtr,
    required this.proximityAtr,
    required this.rejectionCloseAtr,
    required this.strongBreakDistanceAtr,
    required this.maximumReliability,
  });

  static const swingDaily = SupportResistanceStrategyPolicy(
    strategy: StrategyType.swing,
    timeframe: '1d',
    structureLookback: 40,
    minimumCandles: 24,
    atrPeriod: 14,
    confirmationCloses: 2,
    breakoutBufferAtr: 0.20,
    proximityAtr: 0.50,
    rejectionCloseAtr: 0.20,
    strongBreakDistanceAtr: 0.75,
    maximumReliability: 0.90,
  );

  static const swingFourHour = SupportResistanceStrategyPolicy(
    strategy: StrategyType.swing,
    timeframe: '4h',
    structureLookback: 60,
    minimumCandles: 30,
    atrPeriod: 14,
    confirmationCloses: 3,
    breakoutBufferAtr: 0.25,
    proximityAtr: 0.45,
    rejectionCloseAtr: 0.20,
    strongBreakDistanceAtr: 0.85,
    maximumReliability: 0.85,
  );

  final StrategyType strategy;
  final String timeframe;

  final int structureLookback;
  final int minimumCandles;
  final int atrPeriod;
  final int confirmationCloses;

  final double breakoutBufferAtr;
  final double proximityAtr;
  final double rejectionCloseAtr;
  final double strongBreakDistanceAtr;
  final double maximumReliability;

  static SupportResistanceStrategyPolicy? forStrategy({
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
