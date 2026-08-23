import '../models/evidence_family.dart';
import '../models/evidence_kind.dart';
import '../models/strategy_summary.dart';

enum StrategyEvidenceApplicability {
  reuseCurrentBehavior,
  recalibrateForStrategy,
  conditionalOnDataQuality,
  excluded,
  deferred,
}

extension StrategyEvidenceApplicabilityBehavior
    on StrategyEvidenceApplicability {
  bool get isEligibleForEvaluation {
    return switch (this) {
      StrategyEvidenceApplicability.reuseCurrentBehavior => true,
      StrategyEvidenceApplicability.recalibrateForStrategy => true,
      StrategyEvidenceApplicability.conditionalOnDataQuality => true,
      StrategyEvidenceApplicability.excluded => false,
      StrategyEvidenceApplicability.deferred => false,
    };
  }

  bool get requiresStrategyCalibration {
    return switch (this) {
      StrategyEvidenceApplicability.recalibrateForStrategy => true,
      StrategyEvidenceApplicability.conditionalOnDataQuality => true,
      StrategyEvidenceApplicability.reuseCurrentBehavior => false,
      StrategyEvidenceApplicability.excluded => false,
      StrategyEvidenceApplicability.deferred => false,
    };
  }
}

/// Strategy-specific decision describing whether and how an existing evidence
/// capability is allowed to participate in a recommendation.
///
/// This object deliberately does not contain numeric provider weights or
/// thresholds yet. Those values must be justified during the provider-specific
/// Swing calibration batches rather than invented in the architecture layer.
class StrategyEvidencePolicy {
  const StrategyEvidencePolicy({
    required this.strategy,
    required this.kind,
    required this.family,
    required this.applicability,
    required this.affectsDirection,
    required this.affectsConfidence,
    required this.affectsRiskOrEntryQuality,
    required this.rationale,
    this.calibrationNotes,
    this.dataQualityRequirement,
  }) : assert(kind != EvidenceKind.generic),
       assert(family != EvidenceFamily.generic),
       assert(
         applicability != StrategyEvidenceApplicability.excluded &&
                 applicability != StrategyEvidenceApplicability.deferred ||
             !affectsDirection &&
                 !affectsConfidence &&
                 !affectsRiskOrEntryQuality,
         'Excluded or deferred evidence cannot influence a recommendation.',
       );

  final StrategyType strategy;
  final EvidenceKind kind;
  final EvidenceFamily family;

  /// Whether the existing capability is usable for this strategy and whether
  /// strategy-specific calibration or data-quality gating is required.
  final StrategyEvidenceApplicability applicability;

  /// Whether the capability may contribute signed bullish/bearish influence.
  final bool affectsDirection;

  /// Whether the capability may participate in evidence-derived confidence.
  final bool affectsConfidence;

  /// Whether the capability may describe risk, stretch or entry quality.
  ///
  /// This is intentionally separate from direction. A capability such as
  /// Swing Price Extension may reduce entry quality without claiming that the
  /// opposite trend has started.
  final bool affectsRiskOrEntryQuality;

  /// Human-readable architectural reason for this strategy decision.
  final String rationale;

  /// Required strategy-specific behavior that later implementation batches
  /// must provide before this evidence is considered calibrated.
  final String? calibrationNotes;

  /// Explicit data-quality requirement for conditionally usable evidence.
  final String? dataQualityRequirement;

  bool get isEligibleForEvaluation => applicability.isEligibleForEvaluation;

  bool get requiresStrategyCalibration =>
      applicability.requiresStrategyCalibration;

  bool get isComplete {
    if (rationale.trim().isEmpty) {
      return false;
    }

    if (requiresStrategyCalibration &&
        (calibrationNotes == null || calibrationNotes!.trim().isEmpty)) {
      return false;
    }

    if (applicability ==
            StrategyEvidenceApplicability.conditionalOnDataQuality &&
        (dataQualityRequirement == null ||
            dataQualityRequirement!.trim().isEmpty)) {
      return false;
    }

    if (!isEligibleForEvaluation &&
        (affectsDirection || affectsConfidence || affectsRiskOrEntryQuality)) {
      return false;
    }

    return true;
  }
}
