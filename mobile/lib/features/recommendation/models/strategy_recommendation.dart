import 'recommendation.dart';
import 'strategy_summary.dart';

class StrategyRecommendation {
  const StrategyRecommendation({
    required this.strategy,
    required this.recommendation,
  });

  final StrategyType strategy;
  final Recommendation recommendation;

  String get title => strategy.title;

  String get horizon => strategy.horizon;

  double get confidence => recommendation.confidenceScore;
}
