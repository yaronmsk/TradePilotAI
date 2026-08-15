enum StrategyType { trader, swing, investor }

enum StrategyStatus { active, comingSoon }

class StrategySummary {
  const StrategySummary({
    required this.type,
    required this.title,
    required this.status,
    this.recommendation,
    this.confidence,
    required this.horizon,
  });

  final StrategyType type;
  final String title;
  final StrategyStatus status;

  /// Null when the strategy is not yet implemented.
  final String? recommendation;

  /// Value from 0–100.
  final double? confidence;

  final String horizon;

  bool get isAvailable => status == StrategyStatus.active;
}
