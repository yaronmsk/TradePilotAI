import '../models/strategy_summary.dart';

class RecommendationStrategyPolicy {
  const RecommendationStrategyPolicy({
    required this.strategy,
    required this.minimumProviderCoverage,
    required this.actionDirectionThreshold,
    required this.strongDirectionThreshold,
    required this.holdDirectionThreshold,
    required this.minimumActionConfidence,
    required this.strongActionConfidence,
    required this.minimumIndependentFamiliesForAction,
    required this.holdOnMaterialConflict,
    required this.materialConflictThreshold,
  });

  static const trader = RecommendationStrategyPolicy(
    strategy: StrategyType.trader,
    minimumProviderCoverage: 0.60,
    actionDirectionThreshold: 30,
    strongDirectionThreshold: 65,
    holdDirectionThreshold: 20,
    minimumActionConfidence: 55,
    strongActionConfidence: 80,
    minimumIndependentFamiliesForAction: 0,
    holdOnMaterialConflict: false,
    materialConflictThreshold: 0.60,
  );

  static const swing = RecommendationStrategyPolicy(
    strategy: StrategyType.swing,
    minimumProviderCoverage: 0.65,
    actionDirectionThreshold: 35,
    strongDirectionThreshold: 70,
    holdDirectionThreshold: 25,
    minimumActionConfidence: 60,
    strongActionConfidence: 80,
    minimumIndependentFamiliesForAction: 3,
    holdOnMaterialConflict: true,
    materialConflictThreshold: 0.55,
  );

  final StrategyType strategy;

  final double minimumProviderCoverage;

  final double actionDirectionThreshold;
  final double strongDirectionThreshold;
  final double holdDirectionThreshold;

  final double minimumActionConfidence;
  final double strongActionConfidence;

  final int minimumIndependentFamiliesForAction;

  final bool holdOnMaterialConflict;
  final double materialConflictThreshold;

  static RecommendationStrategyPolicy? forStrategy(StrategyType strategy) {
    return switch (strategy) {
      StrategyType.trader => trader,
      StrategyType.swing => swing,
      StrategyType.investor => null,
    };
  }
}
