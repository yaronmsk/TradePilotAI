import '../models/strategy_summary.dart';

class RelativeVolumeStrategyPolicy {
  const RelativeVolumeStrategyPolicy({
    required this.strategy,
    required this.timeframe,
    required this.lookback,
    required this.minimumHistoricalCandles,
    required this.targetHistoricalCandles,
    required this.moderateRatio,
    required this.strongRatio,
    required this.exceptionalRatio,
    required this.weakParticipationRatio,
    required this.requiresComparableSessionPositionHistory,
  });

  static const swingDaily = RelativeVolumeStrategyPolicy(
    strategy: StrategyType.swing,
    timeframe: '1d',
    lookback: 20,
    minimumHistoricalCandles: 10,
    targetHistoricalCandles: 20,
    moderateRatio: 1.20,
    strongRatio: 1.50,
    exceptionalRatio: 2.00,
    weakParticipationRatio: 0.70,
    requiresComparableSessionPositionHistory: false,
  );

  static const swingFourHour = RelativeVolumeStrategyPolicy(
    strategy: StrategyType.swing,
    timeframe: '4h',
    lookback: 20,
    minimumHistoricalCandles: 10,
    targetHistoricalCandles: 20,
    moderateRatio: 1.20,
    strongRatio: 1.50,
    exceptionalRatio: 2.00,
    weakParticipationRatio: 0.70,
    requiresComparableSessionPositionHistory: true,
  );

  final StrategyType strategy;
  final String timeframe;

  final int lookback;
  final int minimumHistoricalCandles;
  final int targetHistoricalCandles;

  final double moderateRatio;
  final double strongRatio;
  final double exceptionalRatio;
  final double weakParticipationRatio;

  final bool requiresComparableSessionPositionHistory;

  bool get canEvaluateFromSequentialCandles =>
      !requiresComparableSessionPositionHistory;

  static RelativeVolumeStrategyPolicy? forStrategy({
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
