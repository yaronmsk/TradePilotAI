import '../models/strategy_recommendation.dart';
import '../models/strategy_summary.dart';

class StrategySummaryService {
  const StrategySummaryService();

  List<StrategySummary> build({
    required StrategyRecommendation traderRecommendation,
  }) {
    return [
      StrategySummary(
        type: StrategyType.trader,
        title: traderRecommendation.title,
        status: StrategyStatus.active,
        recommendation: traderRecommendation.recommendation.type.name,
        confidence: traderRecommendation.confidence,
        horizon: traderRecommendation.horizon,
      ),
      const StrategySummary(
        type: StrategyType.swing,
        title: 'Swing',
        status: StrategyStatus.comingSoon,
        recommendation: null,
        confidence: null,
        horizon: 'Days–Weeks',
      ),
      const StrategySummary(
        type: StrategyType.investor,
        title: 'Investor',
        status: StrategyStatus.comingSoon,
        recommendation: null,
        confidence: null,
        horizon: 'Months–Years',
      ),
    ];
  }
}
