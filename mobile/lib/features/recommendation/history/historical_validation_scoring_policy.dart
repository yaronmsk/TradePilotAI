import '../context/stock_behavior_profile.dart';
import 'historical_validation_scoring_breakdown.dart';

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

    final expectedMoveScale = switch (stockBehaviorProfile.behaviorType) {
      StockBehaviorType.steady => 0.8,
      StockBehaviorType.balanced => 1.3,
      StockBehaviorType.volatile => 2.1,
      StockBehaviorType.unknown => 1.2,
    };

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
    );
    final matchQualityReliability = matchQualityReliabilityFor(
      averageSimilarity,
    );

    // Reliability is a gate, not a fifth historical vote. The weakest link
    // limits the final historical influence.
    final appliedReliability = appliedReliabilityFor(
      effectiveSampleSize: effectiveSampleSize,
      averageSimilarity: averageSimilarity,
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

  double effectiveSampleReliabilityFor(double effectiveSampleSize) {
    return ((effectiveSampleSize - 8) / 22).clamp(0.0, 1.0);
  }

  double matchQualityReliabilityFor(double averageSimilarity) {
    return ((averageSimilarity - 0.58) / 0.24).clamp(0.0, 1.0);
  }

  double appliedReliabilityFor({
    required double effectiveSampleSize,
    required double averageSimilarity,
  }) {
    final sampleReliability = effectiveSampleReliabilityFor(
      effectiveSampleSize,
    );
    final matchReliability = matchQualityReliabilityFor(averageSimilarity);
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
