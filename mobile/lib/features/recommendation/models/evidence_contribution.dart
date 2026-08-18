import 'evidence_family.dart';
import 'evidence_result.dart';

/// Exact, post-de-duplication attribution for one evidence provider.
///
/// Direction impact is expressed in signed points on the final -100..+100
/// direction scale. Providers inside the same family share that family's capped
/// influence rather than each receiving an independent full vote.
class EvidenceContribution {
  const EvidenceContribution({
    required this.providerName,
    required this.family,
    required this.direction,
    required this.directionImpactPoints,
    required this.directionShareWithinFamily,
    required this.confidenceContributionPoints,
    required this.confidenceShare,
  });

  final String providerName;
  final EvidenceFamily family;
  final EvidenceDirection direction;

  /// Signed contribution to the final direction score.
  ///
  /// All provider direction-impact points sum to the final direction score.
  final double directionImpactPoints;

  /// Share of absolute provider-level directional influence inside this family,
  /// from 0 to 1. This is intentionally family-relative because correlated
  /// providers are capped together before they influence the final result.
  final double directionShareWithinFamily;

  /// Portion of final confidence attributable to this provider after global
  /// coverage, alignment, and reliability adjustments are applied.
  ///
  /// All provider confidence-contribution points sum to final confidence.
  final double confidenceContributionPoints;

  /// Share of final confidence attributable to this provider, from 0 to 1.
  final double confidenceShare;
}

/// Attribution for an independent evidence family after correlated providers
/// have been combined and capped.
class EvidenceFamilyContribution {
  const EvidenceFamilyContribution({
    required this.family,
    required this.direction,
    required this.directionImpactPoints,
    required this.directionShare,
    required this.confidenceContributionPoints,
    required this.confidenceShare,
    required this.providers,
  });

  final EvidenceFamily family;
  final EvidenceDirection direction;

  /// Signed contribution to the final direction score.
  final double directionImpactPoints;

  /// Share of the absolute family-level directional influence, from 0 to 1.
  /// Shares across families sum to 1 when directional evidence exists.
  final double directionShare;

  /// Portion of final confidence attributable to this family after global
  /// confidence adjustments are applied.
  final double confidenceContributionPoints;

  /// Share of final confidence attributable to this family, from 0 to 1.
  final double confidenceShare;

  final List<EvidenceContribution> providers;
}

/// One multiplicative adjustment used to move from the evidence-strength
/// baseline to final confidence.
class ConfidenceModifierImpact {
  const ConfidenceModifierImpact({
    required this.label,
    required this.factor,
    required this.before,
    required this.after,
  });

  final String label;

  /// Multiplicative factor applied at this step. Current factors are <= 1.
  final double factor;

  final double before;
  final double after;

  double get impactPoints => after - before;
}
