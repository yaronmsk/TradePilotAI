import 'historical_setup_match.dart';
import 'historical_validation_scoring_breakdown.dart';

enum HistoricalValidationStatus {
  unavailable,
  insufficientData,
  neutralSignal,
  available,
}

enum HistoricalValidationReliability { unavailable, low, moderate, high }

enum HistoricalValidationVerdict { unavailable, supports, mixed, opposes }

class HistoricalSetupValidation {
  const HistoricalSetupValidation({
    required this.status,
    required this.reliability,
    required this.verdict,
    required this.matchedCases,
    required this.effectiveSampleSize,
    required this.averageSimilarity,
    required this.alignedOutcomeRate,
    required this.controlAlignedOutcomeRate,
    required this.edgeVsControlPercentagePoints,
    required this.medianForwardReturnPercent,
    required this.medianDirectionalReturnPercent,
    required this.medianFavorableExcursionPercent,
    required this.medianAdverseExcursionPercent,
    required this.confidenceImpactPoints,
    required this.outcomeWindowLabel,
    required this.summary,
    required this.isSynthetic,
    required this.sourceLabel,
    required this.topMatches,
    this.symbol = '',
    this.stockProfileLabel = 'Unknown',
    this.comparisonCases = 0,
    this.outcomeWindowShortLabel = '',
    this.scoringBreakdown = const HistoricalValidationScoringBreakdown.empty(),
  });

  const HistoricalSetupValidation.unavailable({
    this.summary = 'Historical setup validation is not available yet.',
  }) : status = HistoricalValidationStatus.unavailable,
       reliability = HistoricalValidationReliability.unavailable,
       verdict = HistoricalValidationVerdict.unavailable,
       matchedCases = 0,
       effectiveSampleSize = 0,
       averageSimilarity = 0,
       alignedOutcomeRate = 0,
       controlAlignedOutcomeRate = 0,
       edgeVsControlPercentagePoints = 0,
       medianForwardReturnPercent = 0,
       medianDirectionalReturnPercent = 0,
       medianFavorableExcursionPercent = 0,
       medianAdverseExcursionPercent = 0,
       confidenceImpactPoints = 0,
       outcomeWindowLabel = '',
       isSynthetic = false,
       sourceLabel = '',
       topMatches = const [],
       symbol = '',
       stockProfileLabel = 'Unknown',
       comparisonCases = 0,
       outcomeWindowShortLabel = '',
       scoringBreakdown = const HistoricalValidationScoringBreakdown.empty();

  final HistoricalValidationStatus status;
  final HistoricalValidationReliability reliability;
  final HistoricalValidationVerdict verdict;
  final int matchedCases;

  /// Kish effective sample size after similarity weighting.
  final double effectiveSampleSize;
  final double averageSimilarity;

  /// Share of matched setup outcomes that moved in the same direction as the
  /// current directional signal over the configured forward horizon.
  final double alignedOutcomeRate;

  /// Same-direction rate from the current stock's context-matched comparison
  /// observations. These observations share strategy, interval, Stock Profile,
  /// volatility regime and market environment, but do not need today's
  /// evidence-family setup.
  ///
  /// The legacy field name is kept in v0.9 to minimize migration risk; it now
  /// represents a context-matched stock baseline rather than an unconditional
  /// control sample.
  final double controlAlignedOutcomeRate;

  /// Matched setup rate minus the context-matched stock baseline rate, in
  /// percentage points.
  final double edgeVsControlPercentagePoints;

  /// Raw median move after similar setups.
  final double medianForwardReturnPercent;

  /// Median move transformed so positive means it agreed with the current
  /// directional signal and negative means it moved against it.
  final double medianDirectionalReturnPercent;

  /// Median best move in the current signal direction during the outcome window.
  final double medianFavorableExcursionPercent;

  /// Median worst move against the current signal direction during the outcome window.
  final double medianAdverseExcursionPercent;

  /// Bounded contribution to confidence. Historical validation does not alter
  /// recommendation direction in this release.
  final double confidenceImpactPoints;

  final String outcomeWindowLabel;
  final String outcomeWindowShortLabel;
  final String summary;
  final bool isSynthetic;
  final String sourceLabel;
  final List<HistoricalSetupMatch> topMatches;

  /// Symbol whose own context-matched history forms the comparison baseline.
  final String symbol;

  /// User-facing Stock Profile label for the hard analog-matching gate.
  final String stockProfileLabel;

  /// Number of same-stock observations that survived the context baseline
  /// selector (same profile, volatility regime and market environment).
  final int comparisonCases;

  /// Transparent weighted historical-scoring decomposition. Outcome dimensions
  /// have unequal weights; reliability is applied separately as a gate.
  final HistoricalValidationScoringBreakdown scoringBreakdown;

  bool get isAvailable => status == HistoricalValidationStatus.available;

  bool get canInfluenceConfidence =>
      status == HistoricalValidationStatus.available &&
      reliability != HistoricalValidationReliability.unavailable;
}
