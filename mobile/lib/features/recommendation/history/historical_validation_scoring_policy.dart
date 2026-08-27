import '../context/stock_behavior_profile.dart';
import 'historical_validation_scoring_breakdown.dart';
import 'historical_validation_strategy_policy.dart';

class HistoricalValidationScoringPolicy {
  const HistoricalValidationScoringPolicy({
    this.edgeVsControlWeight = 0.40,
    this.followThroughWeight = 0.20,
    this.outcomeMagnitudeWeight = 0.20,
    this.excursionQualityWeight = 0.20,
  }) : assert(
         edgeVsControlWeight +
                 followThroughWeight +
                 outcomeMagnitudeWeight +
                 excursionQualityWeight >
             0.999,
       ),
       assert(
         edgeVsControlWeight +
                 followThroughWeight +
                 outcomeMagnitudeWeight +
                 excursionQualityWeight <
             1.001,
       );

  final double edgeVsControlWeight;
  final double followThroughWeight;
  final double outcomeMagnitudeWeight;
  final double excursionQualityWeight;

  HistoricalValidationScoringBreakdown evaluate({
    required double alignedOutcomeRate,
    required double controlAlignedOutcomeRate,
    required double medianDirectionalReturnPercent,
    required double medianFavorableExcursionPercent,
    required double medianAdverseExcursionPercent,
    required double effectiveSampleSize,
    required double averageSimilarity,
    required StockBehaviorProfile stockBehaviorProfile,
    HistoricalValidationStrategyPolicy strategyPolicy =
        HistoricalValidationStrategyPolicy.trader,
  }) {
    final edgeVsControlScore =
        ((alignedOutcomeRate - controlAlignedOutcomeRate) / 0.25).clamp(
          -1.0,
          1.0,
        );

    final followThroughScore = ((alignedOutcomeRate - 0.5) * 2).clamp(
      -1.0,
      1.0,
    );

    final expectedMoveScale = strategyPolicy.expectedMoveScaleFor(
      stockBehaviorProfile.behaviorType,
    );

    final outcomeMagnitudeScore =
        (medianDirectionalReturnPercent / expectedMoveScale).clamp(-1.0, 1.0);

    final favorable = medianFavorableExcursionPercent.clamp(
      0.0,
      double.infinity,
    );
    final adverse = medianAdverseExcursionPercent.abs();
    final excursionTotal = favorable + adverse;
    final excursionQualityScore = excursionTotal <= 0.0001
        ? 0.0
        : ((favorable - adverse) / excursionTotal).clamp(-1.0, 1.0);

    final weightedOutcomeScore =
        (edgeVsControlScore * edgeVsControlWeight) +
        (followThroughScore * followThroughWeight) +
        (outcomeMagnitudeScore * outcomeMagnitudeWeight) +
        (excursionQualityScore * excursionQualityWeight);

    // Historical support must beat both a 50/50 directional baseline and the
    // unconditional control. Otherwise a positive-looking raw score cannot
    // increase confidence simply because the whole market drifted that way.
    final confidenceEligibleScore =
        (alignedOutcomeRate <= 0.5 ||
            alignedOutcomeRate <= controlAlignedOutcomeRate)
        ? weightedOutcomeScore.clamp(-1.0, 0.0)
        : weightedOutcomeScore.clamp(-1.0, 1.0);

    final effectiveSampleReliability = effectiveSampleReliabilityFor(
      effectiveSampleSize,
      strategyPolicy: strategyPolicy,
    );
    final matchQualityReliability = matchQualityReliabilityFor(
      averageSimilarity,
      strategyPolicy: strategyPolicy,
    );

    // Reliability is a gate, not a fifth historical vote. The weakest link
    // limits the final historical influence.
    final appliedReliability = appliedReliabilityFor(
      effectiveSampleSize: effectiveSampleSize,
      averageSimilarity: averageSimilarity,
      strategyPolicy: strategyPolicy,
    );

    return HistoricalValidationScoringBreakdown(
      edgeVsControlWeight: edgeVsControlWeight,
      followThroughWeight: followThroughWeight,
      outcomeMagnitudeWeight: outcomeMagnitudeWeight,
      excursionQualityWeight: excursionQualityWeight,
      edgeVsControlScore: edgeVsControlScore,
      followThroughScore: followThroughScore,
      outcomeMagnitudeScore: outcomeMagnitudeScore,
      excursionQualityScore: excursionQualityScore,
      weightedOutcomeScore: weightedOutcomeScore,
      confidenceEligibleScore: confidenceEligibleScore,
      effectiveSampleReliability: effectiveSampleReliability,
      matchQualityReliability: matchQualityReliability,
      appliedReliability: appliedReliability,
    );
  }

  double effectiveSampleReliabilityFor(
    double effectiveSampleSize, {
    HistoricalValidationStrategyPolicy strategyPolicy =
        HistoricalValidationStrategyPolicy.trader,
  }) {
    final span =
        strategyPolicy.effectiveSampleFull -
        strategyPolicy.effectiveSampleFloor;

    if (span <= 0) {
      return 0;
    }

    return ((effectiveSampleSize - strategyPolicy.effectiveSampleFloor) / span)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  double matchQualityReliabilityFor(
    double averageSimilarity, {
    HistoricalValidationStrategyPolicy strategyPolicy =
        HistoricalValidationStrategyPolicy.trader,
  }) {
    final span =
        strategyPolicy.matchSimilarityFull -
        strategyPolicy.matchSimilarityFloor;

    if (span <= 0) {
      return 0;
    }

    return ((averageSimilarity - strategyPolicy.matchSimilarityFloor) / span)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  double appliedReliabilityFor({
    required double effectiveSampleSize,
    required double averageSimilarity,
    HistoricalValidationStrategyPolicy strategyPolicy =
        HistoricalValidationStrategyPolicy.trader,
  }) {
    final sampleReliability = effectiveSampleReliabilityFor(
      effectiveSampleSize,
      strategyPolicy: strategyPolicy,
    );

    final matchReliability = matchQualityReliabilityFor(
      averageSimilarity,
      strategyPolicy: strategyPolicy,
    );

    return sampleReliability < matchReliability
        ? sampleReliability
        : matchReliability;
  }

  double confidenceImpact({
    required HistoricalValidationScoringBreakdown breakdown,
    required double maximumConfidenceImpact,
  }) {
    return (breakdown.confidenceEligibleScore *
            breakdown.appliedReliability *
            maximumConfidenceImpact)
        .clamp(-maximumConfidenceImpact, maximumConfidenceImpact);
  }
}
