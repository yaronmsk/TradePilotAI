class StrategyTimeframePlan {
  const StrategyTimeframePlan({
    required this.primaryTimeframe,
    required this.confirmationTimeframe,
    required this.regimeTimeframe,
    required this.primaryCandleCount,
    required this.confirmationCandleCount,
    required this.regimeCandleCount,
  });

  static const trader = StrategyTimeframePlan(
    primaryTimeframe: '5m',
    confirmationTimeframe: '1h',
    regimeTimeframe: '1d',
    primaryCandleCount: 48,
    confirmationCandleCount: 48,
    regimeCandleCount: 48,
  );

  final String primaryTimeframe;
  final String confirmationTimeframe;
  final String regimeTimeframe;
  final int primaryCandleCount;
  final int confirmationCandleCount;
  final int regimeCandleCount;
}
