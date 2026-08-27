import '../context/stock_behavior_profile.dart';
import '../models/strategy_summary.dart';

class HistoricalValidationStrategyPolicy {
  const HistoricalValidationStrategyPolicy({
    required this.strategy,
    required this.primaryTimeframe,
    required this.isStrategyCalibrated,
    required this.minimumMatchedCases,
    required this.effectiveSampleFloor,
    required this.effectiveSampleFull,
    required this.matchSimilarityFloor,
    required this.matchSimilarityFull,
    required this.steadyExpectedMovePercent,
    required this.balancedExpectedMovePercent,
    required this.volatileExpectedMovePercent,
    required this.unknownExpectedMovePercent,
  });

  static const trader = HistoricalValidationStrategyPolicy(
    strategy: StrategyType.trader,
    primaryTimeframe: 'legacy-trader',
    isStrategyCalibrated: true,
    minimumMatchedCases: 8,
    effectiveSampleFloor: 8,
    effectiveSampleFull: 30,
    matchSimilarityFloor: 0.58,
    matchSimilarityFull: 0.82,
    steadyExpectedMovePercent: 0.8,
    balancedExpectedMovePercent: 1.3,
    volatileExpectedMovePercent: 2.1,
    unknownExpectedMovePercent: 1.2,
  );

  static const swingFourHour = HistoricalValidationStrategyPolicy(
    strategy: StrategyType.swing,
    primaryTimeframe: '4h',
    isStrategyCalibrated: true,
    minimumMatchedCases: 10,
    effectiveSampleFloor: 10,
    effectiveSampleFull: 32,
    matchSimilarityFloor: 0.60,
    matchSimilarityFull: 0.84,
    steadyExpectedMovePercent: 2.0,
    balancedExpectedMovePercent: 3.3,
    volatileExpectedMovePercent: 5.5,
    unknownExpectedMovePercent: 3.3,
  );

  static const swingDaily = HistoricalValidationStrategyPolicy(
    strategy: StrategyType.swing,
    primaryTimeframe: '1d',
    isStrategyCalibrated: true,
    minimumMatchedCases: 10,
    effectiveSampleFloor: 10,
    effectiveSampleFull: 32,
    matchSimilarityFloor: 0.60,
    matchSimilarityFull: 0.84,
    steadyExpectedMovePercent: 2.5,
    balancedExpectedMovePercent: 4.0,
    volatileExpectedMovePercent: 6.5,
    unknownExpectedMovePercent: 4.0,
  );

  /// Preserves the pre-v0.11 universal historical scoring behavior if
  /// Historical Validation is reached through Investor before its dedicated
  /// v0.12 calibration. This is explicitly NOT Investor calibration.
  static const investorLegacyFallback = HistoricalValidationStrategyPolicy(
    strategy: StrategyType.investor,
    primaryTimeframe: 'legacy-investor-fallback',
    isStrategyCalibrated: false,
    minimumMatchedCases: 8,
    effectiveSampleFloor: 8,
    effectiveSampleFull: 30,
    matchSimilarityFloor: 0.58,
    matchSimilarityFull: 0.82,
    steadyExpectedMovePercent: 0.8,
    balancedExpectedMovePercent: 1.3,
    volatileExpectedMovePercent: 2.1,
    unknownExpectedMovePercent: 1.2,
  );

  final StrategyType strategy;
  final String primaryTimeframe;

  final bool isStrategyCalibrated;

  final int minimumMatchedCases;

  final double effectiveSampleFloor;
  final double effectiveSampleFull;

  final double matchSimilarityFloor;
  final double matchSimilarityFull;

  final double steadyExpectedMovePercent;
  final double balancedExpectedMovePercent;
  final double volatileExpectedMovePercent;
  final double unknownExpectedMovePercent;

  double expectedMoveScaleFor(StockBehaviorType behaviorType) {
    return switch (behaviorType) {
      StockBehaviorType.steady => steadyExpectedMovePercent,
      StockBehaviorType.balanced => balancedExpectedMovePercent,
      StockBehaviorType.volatile => volatileExpectedMovePercent,
      StockBehaviorType.unknown => unknownExpectedMovePercent,
    };
  }

  static HistoricalValidationStrategyPolicy forContext({
    required StrategyType strategy,
    required String primaryTimeframe,
  }) {
    return switch (strategy) {
      StrategyType.trader => trader,
      StrategyType.swing => switch (primaryTimeframe) {
        '4h' => swingFourHour,
        '1d' => swingDaily,

        // Swing production plans currently expose only 4H and 1D primary
        // intervals. Keep an explicit conservative fallback rather than
        // silently applying Trader movement scales.
        _ => swingDaily,
      },
      StrategyType.investor => investorLegacyFallback,
    };
  }
}
