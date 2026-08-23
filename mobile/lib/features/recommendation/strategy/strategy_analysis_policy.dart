import '../models/evidence_kind.dart';
import '../models/strategy_summary.dart';
import 'strategy_evidence_policy.dart';

enum StrategyAnalysisPolicyStatus { active, scopeApproved, planned }

/// Strategy-level policy describing which existing evidence capabilities are
/// allowed to participate and which still require strategy calibration.
///
/// Recommendation activation is intentionally separate from scope approval.
/// Swing remains non-active until its provider semantics and orchestration have
/// been implemented and validated.
class StrategyAnalysisPolicy {
  const StrategyAnalysisPolicy({
    required this.strategy,
    required this.status,
    required this.evidencePolicies,
  });

  final StrategyType strategy;
  final StrategyAnalysisPolicyStatus status;
  final Map<EvidenceKind, StrategyEvidencePolicy> evidencePolicies;

  bool get isRecommendationActive =>
      status == StrategyAnalysisPolicyStatus.active;

  StrategyEvidencePolicy? policyFor(EvidenceKind kind) =>
      evidencePolicies[kind];

  List<EvidenceKind> get eligibleEvidenceKinds => List.unmodifiable(
    evidencePolicies.entries
        .where((entry) => entry.value.isEligibleForEvaluation)
        .map((entry) => entry.key),
  );

  bool get coversAllProductionEvidenceKinds {
    final productionKinds = EvidenceKind.values
        .where((kind) => kind != EvidenceKind.generic)
        .toSet();

    if (evidencePolicies.length != productionKinds.length) {
      return false;
    }

    if (!evidencePolicies.keys.toSet().containsAll(productionKinds)) {
      return false;
    }

    return evidencePolicies.entries.every(
      (entry) =>
          entry.value.strategy == strategy && entry.value.kind == entry.key,
    );
  }

  bool get isComplete =>
      coversAllProductionEvidenceKinds &&
      evidencePolicies.values.every((policy) => policy.isComplete);
}
