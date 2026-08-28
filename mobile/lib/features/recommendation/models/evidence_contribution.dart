import 'evidence_family.dart';
import 'evidence_result.dart';

enum ConfidenceModifierSource {
  evidenceQuality,
  eventRisk,
  historicalValidation,
}

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

  /// Diagnostic share of absolute provider-level directional mass inside this
  /// family, from 0 to 1.
  ///
  /// IMPORTANT: this is NOT a percentage of the recommendation and must not be
  /// presented as such. Opposing providers inside one family can partially
  /// cancel each other, so their absolute shares may look large even when the
  /// family's net directional contribution is small.
  ///
  /// User-facing direction attribution should therefore lead with the capped
  /// family contribution and use signed provider impact only as supporting
  /// detail.
  final double directionShareWithinFamily;

  /// Portion of evidence-derived confidence attributable to this provider
  /// after coverage, alignment, and reliability adjustments are applied.
  /// External validation layers (for example historical setup validation) are
  /// reconciled separately and are not reassigned to indicator providers.
  final double confidenceContributionPoints;

  /// Share of evidence-derived confidence attributable to this provider, from 0 to 1.
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

  /// Portion of evidence-derived confidence attributable to this family after
  /// coverage, alignment, and reliability adjustments are applied.
  final double confidenceContributionPoints;

  /// Share of evidence-derived confidence attributable to this family, from 0 to 1.
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
    this.source = ConfidenceModifierSource.evidenceQuality,
  });

  final String label;

  /// Multiplicative factor applied at this step. Evidence-quality factors are
  /// usually <= 1, while bounded external validation may be above 1.
  final double factor;

  final double before;
  final double after;

  /// Identifies which layer changed confidence.
  ///
  /// Evidence-quality modifiers belong to the evidence engine itself.
  /// Event Risk and Historical Validation are external bounded adjustments
  /// and must never be reassigned to indicator/provider attribution.
  final ConfidenceModifierSource source;

  double get impactPoints => after - before;
}
