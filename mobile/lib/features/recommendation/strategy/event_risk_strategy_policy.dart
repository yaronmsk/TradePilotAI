import '../models/strategy_summary.dart';

class EventRiskStrategyPolicy {
  const EventRiskStrategyPolicy({
    required this.strategy,
    required this.useExistingProfilePenalty,
    required this.maximumRelevantEarningsHours,
    required this.maximumRelevantMacroHours,
  });

  static const double maximumPenaltyPoints = 12;

  static const trader = EventRiskStrategyPolicy(
    strategy: StrategyType.trader,
    useExistingProfilePenalty: true,
    maximumRelevantEarningsHours: 168,
    maximumRelevantMacroHours: 48,
  );

  static const swing = EventRiskStrategyPolicy(
    strategy: StrategyType.swing,
    useExistingProfilePenalty: false,
    maximumRelevantEarningsHours: 336,
    maximumRelevantMacroHours: 168,
  );

  final StrategyType strategy;

  /// Trader keeps its already validated upstream penalty behavior.
  ///
  /// Swing deliberately re-derives the penalty from scheduled-event timing
  /// so an upstream Trader-shaped penalty cannot silently leak into Swing.
  final bool useExistingProfilePenalty;

  final int maximumRelevantEarningsHours;
  final int maximumRelevantMacroHours;

  double penaltyFor({
    required int? earningsHoursAway,
    required int? macroEventHoursAway,
  }) {
    final penalty =
        _earningsPenalty(earningsHoursAway) +
        _macroPenalty(macroEventHoursAway);

    return penalty.clamp(0.0, maximumPenaltyPoints).toDouble();
  }

  double _earningsPenalty(int? hoursAway) {
    if (hoursAway == null || hoursAway < 0) {
      return 0;
    }

    return switch (strategy) {
      StrategyType.trader =>
        hoursAway <= 24
            ? 8
            : hoursAway <= 48
            ? 6
            : hoursAway <= 96
            ? 3.5
            : hoursAway <= 168
            ? 1.5
            : 0,
      StrategyType.swing =>
        hoursAway <= 24
            ? 9
            : hoursAway <= 72
            ? 8
            : hoursAway <= 168
            ? 6
            : hoursAway <= 336
            ? 3
            : 0,
      StrategyType.investor => 0,
    };
  }

  double _macroPenalty(int? hoursAway) {
    if (hoursAway == null || hoursAway < 0) {
      return 0;
    }

    return switch (strategy) {
      StrategyType.trader =>
        hoursAway <= 12
            ? 4
            : hoursAway <= 24
            ? 2.5
            : hoursAway <= 48
            ? 1
            : 0,
      StrategyType.swing =>
        hoursAway <= 24
            ? 4
            : hoursAway <= 72
            ? 3
            : hoursAway <= 168
            ? 1.5
            : 0,
      StrategyType.investor => 0,
    };
  }

  static EventRiskStrategyPolicy? forStrategy(StrategyType strategy) {
    return switch (strategy) {
      StrategyType.trader => trader,
      StrategyType.swing => swing,
      StrategyType.investor => null,
    };
  }
}
