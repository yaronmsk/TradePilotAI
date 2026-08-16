enum StrategyType { trader, swing, investor }

enum StrategyStatus { active, comingSoon }

extension StrategyTypeMetadata on StrategyType {
  String get title {
    switch (this) {
      case StrategyType.trader:
        return 'Trader';
      case StrategyType.swing:
        return 'Swing';
      case StrategyType.investor:
        return 'Investor';
    }
  }

  String get horizon {
    switch (this) {
      case StrategyType.trader:
        return 'Hours–Days';
      case StrategyType.swing:
        return 'Days–Weeks';
      case StrategyType.investor:
        return 'Months–Years';
    }
  }

  String get icon {
    switch (this) {
      case StrategyType.trader:
        return '⚡';
      case StrategyType.swing:
        return '📈';
      case StrategyType.investor:
        return '🏛';
    }
  }
}

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
  final String? recommendation;
  final double? confidence;
  final String horizon;

  bool get isAvailable => status == StrategyStatus.active;
}
