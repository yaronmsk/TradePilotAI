import '../models/strategy_recommendation.dart';
import '../models/strategy_summary.dart';
import '../strategy/strategy_analysis_policy_catalog.dart';
import '../utils/recommendation_formatter.dart';

class StrategySummaryService {
  const StrategySummaryService();

  List<StrategySummary> build({
    required List<StrategyRecommendation> recommendations,
    Set<StrategyType> dedicatedAvailableStrategies = const {},
  }) {
    final byStrategy = <StrategyType, StrategyRecommendation>{
      for (final recommendation in recommendations)
        recommendation.strategy: recommendation,
    };

    return StrategyType.values
        .map((type) {
          final strategyRecommendation = byStrategy[type];

          if (strategyRecommendation != null) {
            return StrategySummary(
              type: type,
              title: type.title,
              status: StrategyStatus.active,
              recommendation: RecommendationFormatter.label(
                strategyRecommendation.recommendation.type,
              ),
              confidence: strategyRecommendation.confidence,
              horizon: type.horizon,
            );
          }

          final policy = StrategyAnalysisPolicyCatalog.forStrategy(type);

          if (policy.isRecommendationActive ||
              dedicatedAvailableStrategies.contains(type)) {
            return StrategySummary(
              type: type,
              title: type.title,
              status: StrategyStatus.active,
              recommendation: 'Ready to analyze',
              confidence: null,
              horizon: type.horizon,
            );
          }

          return StrategySummary(
            type: type,
            title: type.title,
            status: StrategyStatus.comingSoon,
            recommendation: null,
            confidence: null,
            horizon: type.horizon,
          );
        })
        .toList(growable: false);
  }
}
