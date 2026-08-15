import 'recommendation.dart';
import 'strategy_summary.dart';

class StrategyRecommendation {
  const StrategyRecommendation({
    required this.strategy,
    required this.recommendation,
  });

  final StrategyType strategy;
  final Recommendation recommendation;

  String get title {
    switch (strategy) {
      case StrategyType.trader:
        return 'Trader';
      case StrategyType.swing:
        return 'Swing';
      case StrategyType.investor:
        return 'Investor';
    }
  }

  String get horizon {
    switch (strategy) {
      case StrategyType.trader:
        return 'Hours–Days';

      case StrategyType.swing:
        return 'Days–Weeks';

      case StrategyType.investor:
        return 'Months–Years';
    }
  }

  double get confidence => recommendation.evidenceScore;
}
