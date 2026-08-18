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
    this.familyContributions = const [],
    this.providerContributions = const [],
    this.confidenceModifiers = const [],
  });

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

  /// Family-level attribution after correlated providers have been grouped.
  final List<EvidenceFamilyContribution> familyContributions;

  /// Provider-level attribution that reconciles exactly to the family and
  /// overall scores without bypassing evidence-family caps.
  final List<EvidenceContribution> providerContributions;

  /// Exact steps that transform [baseEvidenceStrength] into final confidence.
  final List<ConfidenceModifierImpact> confidenceModifiers;

  double get confidence => score;

  bool get hasSufficientCoverage => coverage >= 0.60;
}
