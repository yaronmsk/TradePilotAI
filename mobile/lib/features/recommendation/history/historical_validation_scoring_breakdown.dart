class HistoricalValidationScoringBreakdown {
  const HistoricalValidationScoringBreakdown({
    required this.edgeVsControlWeight,
    required this.followThroughWeight,
    required this.outcomeMagnitudeWeight,
    required this.excursionQualityWeight,
    required this.edgeVsControlScore,
    required this.followThroughScore,
    required this.outcomeMagnitudeScore,
    required this.excursionQualityScore,
    required this.weightedOutcomeScore,
    required this.confidenceEligibleScore,
    required this.effectiveSampleReliability,
    required this.matchQualityReliability,
    required this.appliedReliability,
  });

  const HistoricalValidationScoringBreakdown.empty()
    : edgeVsControlWeight = 0.40,
      followThroughWeight = 0.20,
      outcomeMagnitudeWeight = 0.20,
      excursionQualityWeight = 0.20,
      edgeVsControlScore = 0,
      followThroughScore = 0,
      outcomeMagnitudeScore = 0,
      excursionQualityScore = 0,
      weightedOutcomeScore = 0,
      confidenceEligibleScore = 0,
      effectiveSampleReliability = 0,
      matchQualityReliability = 0,
      appliedReliability = 0;

  /// Relative importance of each historical outcome dimension. These four
  /// weights intentionally sum to 1.0.
  final double edgeVsControlWeight;
  final double followThroughWeight;
  final double outcomeMagnitudeWeight;
  final double excursionQualityWeight;

  /// Normalized component scores on a -1..+1 scale. Positive values support
  /// the current recommendation direction; negative values oppose it.
  final double edgeVsControlScore;
  final double followThroughScore;
  final double outcomeMagnitudeScore;
  final double excursionQualityScore;

  /// Weighted sum of the four normalized outcome dimensions.
  final double weightedOutcomeScore;

  /// Score allowed to influence confidence after the anti-drift support gate.
  /// A setup cannot earn positive confidence merely by moving with a generally
  /// rising/falling context-matched stock baseline.
  final double confidenceEligibleScore;

  /// Reliability gates are intentionally not extra votes. The weakest of
  /// sample depth and match quality limits how much historical scoring can
  /// influence confidence.
  final double effectiveSampleReliability;
  final double matchQualityReliability;
  final double appliedReliability;
}
