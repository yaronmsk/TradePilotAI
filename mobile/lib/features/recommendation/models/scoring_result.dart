import 'evidence_contribution.dart';
import 'evidence_family_summary.dart';

class ScoringResult {
  const ScoringResult({
    required this.score,
    required this.coverage,
    required this.bullishWeight,
    required this.bearishWeight,
    required this.neutralWeight,
    required this.warnings,
    this.directionScore,
    this.familyCoverage = 0,
    this.agreement = 0,
    this.conflict = 0,
    this.bullishSupportPercent = 0,
    this.bearishSupportPercent = 0,
    this.independentFamilyCount = 0,
    this.familySummaries = const [],
    this.baseEvidenceStrength = 0,
    double? evidenceConfidence,
    this.familyContributions = const [],
    this.providerContributions = const [],
    this.confidenceModifiers = const [],
  }) : evidenceConfidence = evidenceConfidence ?? score;

  const ScoringResult.empty()
    : score = 0,
      coverage = 0,
      bullishWeight = 0,
      bearishWeight = 0,
      neutralWeight = 0,
      warnings = const [],
      directionScore = null,
      familyCoverage = 0,
      agreement = 0,
      conflict = 0,
      bullishSupportPercent = 0,
      bearishSupportPercent = 0,
      independentFamilyCount = 0,
      familySummaries = const [],
      baseEvidenceStrength = 0,
      evidenceConfidence = 0,
      familyContributions = const [],
      providerContributions = const [],
      confidenceModifiers = const [];

  /// Confidence score from 0 to 100.
  final double score;

  /// Provider coverage from 0 to 1.
  final double coverage;

  /// Family-capped directional weights. These remain available for backwards
  /// compatibility and for recommendation fallbacks.
  final double bullishWeight;
  final double bearishWeight;
  final double neutralWeight;

  final List<String> warnings;

  /// Signed directional consensus from -100 to +100. Null means an older
  /// caller supplied only directional weights.
  final double? directionScore;

  /// Percentage of expected evidence families with usable evidence.
  final double familyCoverage;

  /// Agreement between independent directional families, from 0 to 1.
  final double agreement;

  /// Opposing-family conflict, from 0 to 1.
  final double conflict;

  /// Share of directional family support that is bullish/bearish.
  final double bullishSupportPercent;
  final double bearishSupportPercent;

  final int independentFamilyCount;
  final List<EvidenceFamilySummary> familySummaries;

  /// Weighted evidence-strength baseline before coverage, alignment, and
  /// reliability adjustments reduce confidence.
  final double baseEvidenceStrength;

  /// Confidence produced strictly by the current evidence engine after
  /// coverage, alignment, and reliability adjustments, but before external
  /// validation layers such as historical setup checks.
  final double evidenceConfidence;

  /// Family-level attribution after correlated providers have been grouped.
  final List<EvidenceFamilyContribution> familyContributions;

  /// Provider-level attribution that reconciles exactly to the family and
  /// overall scores without bypassing evidence-family caps.
  final List<EvidenceContribution> providerContributions;

  /// Exact steps that transform [baseEvidenceStrength] into final confidence.
  final List<ConfidenceModifierImpact> confidenceModifiers;

  double get confidence => score;

  /// Sum of signed post-family-cap direction attribution.
  ///
  /// For a ConsensusEngine result this reconciles to [directionScore].
  double get attributedDirectionScore => familyContributions.fold<double>(
    0,
    (sum, contribution) => sum + contribution.directionImpactPoints,
  );

  /// Sum of signed provider attribution after providers have already shared
  /// their capped family influence.
  double get providerAttributedDirectionScore =>
      providerContributions.fold<double>(
        0,
        (sum, contribution) => sum + contribution.directionImpactPoints,
      );

  /// Absolute current-case family direction basis.
  ///
  /// This is the denominator used for family-level direction attribution.
  /// It reflects effective post-cap influence, not configured/raw weights.
  double get directionAttributionBasis => familyContributions.fold<double>(
    0,
    (sum, contribution) => sum + contribution.directionImpactPoints.abs(),
  );

  /// Family shares reconcile to 100% whenever directional evidence exists.
  /// Zero means there is no active directional basis.
  double get directionAttributionShareTotal => familyContributions.fold<double>(
    0,
    (sum, contribution) => sum + contribution.directionShare,
  );

  double get directionReconciliationError =>
      (directionScore ?? 0) - attributedDirectionScore;

  double get providerDirectionReconciliationError =>
      attributedDirectionScore - providerAttributedDirectionScore;

  double confidenceAdjustmentPointsFor(ConfidenceModifierSource source) {
    return confidenceModifiers
        .where((modifier) => modifier.source == source)
        .fold<double>(0, (sum, modifier) => sum + modifier.impactPoints);
  }

  /// Internal evidence-engine adjustment from raw evidence strength to
  /// evidence-derived confidence.
  double get evidenceQualityAdjustmentPoints =>
      confidenceAdjustmentPointsFor(ConfidenceModifierSource.evidenceQuality);

  /// Confidence-only Event Risk impact. This value has no directional role.
  double get eventRiskAdjustmentPoints =>
      confidenceAdjustmentPointsFor(ConfidenceModifierSource.eventRisk);

  /// Confidence-only Historical Validation impact. This value has no
  /// directional role.
  double get historicalValidationAdjustmentPoints =>
      confidenceAdjustmentPointsFor(
        ConfidenceModifierSource.historicalValidation,
      );

  double get externalConfidenceAdjustmentPoints =>
      eventRiskAdjustmentPoints + historicalValidationAdjustmentPoints;

  /// Reconstructs evidence confidence from the raw evidence-strength baseline
  /// and evidence-quality modifiers.
  double get reconciledEvidenceConfidence =>
      baseEvidenceStrength + evidenceQualityAdjustmentPoints;

  /// Final confidence reconstructed from evidence confidence plus bounded
  /// external confidence-only adjustments.
  double get reconciledFinalConfidence =>
      evidenceConfidence + externalConfidenceAdjustmentPoints;

  double get evidenceConfidenceReconciliationError =>
      evidenceConfidence - reconciledEvidenceConfidence;

  double get finalConfidenceReconciliationError =>
      confidence - reconciledFinalConfidence;
  ScoringResult copyWith({
    double? score,
    double? coverage,
    double? bullishWeight,
    double? bearishWeight,
    double? neutralWeight,
    List<String>? warnings,
    double? directionScore,
    double? familyCoverage,
    double? agreement,
    double? conflict,
    double? bullishSupportPercent,
    double? bearishSupportPercent,
    int? independentFamilyCount,
    List<EvidenceFamilySummary>? familySummaries,
    double? baseEvidenceStrength,
    double? evidenceConfidence,
    List<EvidenceFamilyContribution>? familyContributions,
    List<EvidenceContribution>? providerContributions,
    List<ConfidenceModifierImpact>? confidenceModifiers,
  }) {
    return ScoringResult(
      score: score ?? this.score,
      coverage: coverage ?? this.coverage,
      bullishWeight: bullishWeight ?? this.bullishWeight,
      bearishWeight: bearishWeight ?? this.bearishWeight,
      neutralWeight: neutralWeight ?? this.neutralWeight,
      warnings: warnings ?? this.warnings,
      directionScore: directionScore ?? this.directionScore,
      familyCoverage: familyCoverage ?? this.familyCoverage,
      agreement: agreement ?? this.agreement,
      conflict: conflict ?? this.conflict,
      bullishSupportPercent:
          bullishSupportPercent ?? this.bullishSupportPercent,
      bearishSupportPercent:
          bearishSupportPercent ?? this.bearishSupportPercent,
      independentFamilyCount:
          independentFamilyCount ?? this.independentFamilyCount,
      familySummaries: familySummaries ?? this.familySummaries,
      baseEvidenceStrength: baseEvidenceStrength ?? this.baseEvidenceStrength,
      evidenceConfidence: evidenceConfidence ?? this.evidenceConfidence,
      familyContributions: familyContributions ?? this.familyContributions,
      providerContributions:
          providerContributions ?? this.providerContributions,
      confidenceModifiers: confidenceModifiers ?? this.confidenceModifiers,
    );
  }

  bool get hasSufficientCoverage => coverage >= 0.60;
}
