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

class StrategyEvidencePolicy {
  const StrategyEvidencePolicy({
    required this.strategy,
    required this.kind,
    required this.family,
    required this.applicability,
    required this.implementationReady,
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

  final StrategyEvidenceApplicability applicability;

  /// True only when the current production implementation has been explicitly
  /// validated as safe for this strategy.
  ///
  /// Applicability and implementation readiness are deliberately separate.
  /// A capability may belong in Swing scope while its current Trader-oriented
  /// implementation remains blocked until Swing calibration is complete.
  final bool implementationReady;

  /// Whether this capability may contribute bullish/bearish direction.
  final bool affectsDirection;

  /// Whether this capability may participate in evidence-derived confidence.
  final bool affectsConfidence;

  /// Whether this capability may affect risk, stretch or entry quality.
  ///
  /// This is separate from direction. For example, Swing Price Extension can
  /// reduce entry quality without claiming that the opposite trend has begun.
  final bool affectsRiskOrEntryQuality;

  final String rationale;
  final String? calibrationNotes;
  final String? dataQualityRequirement;

  bool get isEligibleForEvaluation => applicability.isEligibleForEvaluation;

  bool get canUseCurrentImplementation =>
      implementationReady && isEligibleForEvaluation;

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
