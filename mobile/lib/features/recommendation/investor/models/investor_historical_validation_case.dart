import '../../models/evidence_family.dart';

enum InvestorHistoricalHorizon { sixMonths, twelveMonths, twentyFourMonths }

extension InvestorHistoricalHorizonPresentation on InvestorHistoricalHorizon {
  String get label => switch (this) {
    InvestorHistoricalHorizon.sixMonths => '6 months',
    InvestorHistoricalHorizon.twelveMonths => '12 months',
    InvestorHistoricalHorizon.twentyFourMonths => '24 months',
  };

  String get shortLabel => switch (this) {
    InvestorHistoricalHorizon.sixMonths => '6m',
    InvestorHistoricalHorizon.twelveMonths => '12m',
    InvestorHistoricalHorizon.twentyFourMonths => '24m',
  };

  double get policyWeight => switch (this) {
    InvestorHistoricalHorizon.sixMonths => 0.25,
    InvestorHistoricalHorizon.twelveMonths => 0.50,
    InvestorHistoricalHorizon.twentyFourMonths => 0.25,
  };

  int get approximateCalendarDays => switch (this) {
    InvestorHistoricalHorizon.sixMonths => 183,
    InvestorHistoricalHorizon.twelveMonths => 365,
    InvestorHistoricalHorizon.twentyFourMonths => 730,
  };
}

class InvestorHistoricalOutcome {
  const InvestorHistoricalOutcome({
    required this.horizon,
    required this.stockReturnPercent,
    required this.benchmarkReturnPercent,
    required this.horizonEnd,
    required this.availableAt,
  });

  final InvestorHistoricalHorizon horizon;
  final double stockReturnPercent;
  final double benchmarkReturnPercent;

  /// End of the forward outcome window.
  final DateTime horizonEnd;

  /// Earliest time the complete outcome was knowable.
  final DateTime availableAt;

  bool isMatureAt(DateTime analysisTime) =>
      !horizonEnd.isAfter(analysisTime) && !availableAt.isAfter(analysisTime);
}

class InvestorHistoricalValidationCase {
  InvestorHistoricalValidationCase({
    required this.symbol,
    required this.setupTime,
    required this.setupAvailableAt,
    required Map<EvidenceFamily, double> familySignedScores,
    required this.directionScore,
    required this.confidence,
    required this.coreFamilyCount,
    required Map<InvestorHistoricalHorizon, InvestorHistoricalOutcome> outcomes,
    required this.isSynthetic,
    required this.sourceLabel,
  }) : familySignedScores = Map.unmodifiable(familySignedScores),
       outcomes = Map.unmodifiable(outcomes);

  final String symbol;

  /// Historical decision timestamp.
  final DateTime setupTime;

  /// When the complete historical recommendation fingerprint became knowable.
  ///
  /// This must never be later than [setupTime]. A case that violates this rule
  /// contains look-ahead information and is rejected.
  final DateTime setupAvailableAt;

  /// Point-in-time family signals from -100 to +100.
  ///
  /// Batch 9 similarity uses only breadth-eligible Investor core families.
  final Map<EvidenceFamily, double> familySignedScores;

  final double directionScore;
  final double confidence;
  final int coreFamilyCount;

  final Map<InvestorHistoricalHorizon, InvestorHistoricalOutcome> outcomes;

  final bool isSynthetic;
  final String sourceLabel;

  bool get isPointInTimeSafe => !setupAvailableAt.isAfter(setupTime);

  InvestorHistoricalOutcome? matureOutcome(
    InvestorHistoricalHorizon horizon,
    DateTime analysisTime,
  ) {
    final outcome = outcomes[horizon];
    if (outcome == null || !outcome.isMatureAt(analysisTime)) {
      return null;
    }
    return outcome;
  }
}

class InvestorHistoricalHorizonSummary {
  const InvestorHistoricalHorizonSummary({
    required this.horizon,
    required this.matchedCases,
    required this.controlCases,
    required this.effectiveSampleSize,
    required this.averageSimilarity,
    required this.matchedAlignedRate,
    required this.controlAlignedRate,
    required this.matchedRelativeAlignedRate,
    required this.controlRelativeAlignedRate,
    required this.absoluteEdgePercentagePoints,
    required this.relativeEdgePercentagePoints,
    required this.reliability,
    required this.normalizedSupportScore,
    required this.medianDirectionalReturnPercent,
    required this.medianDirectionalExcessReturnPercent,
  });

  final InvestorHistoricalHorizon horizon;
  final int matchedCases;
  final int controlCases;
  final double effectiveSampleSize;
  final double averageSimilarity;

  final double matchedAlignedRate;
  final double controlAlignedRate;

  final double matchedRelativeAlignedRate;
  final double controlRelativeAlignedRate;

  final double absoluteEdgePercentagePoints;
  final double relativeEdgePercentagePoints;

  /// 0..1 horizon reliability after sample-size and similarity gates.
  final double reliability;

  /// -100..+100 historical support before the global ±8 confidence cap.
  final double normalizedSupportScore;

  final double medianDirectionalReturnPercent;
  final double medianDirectionalExcessReturnPercent;
}
