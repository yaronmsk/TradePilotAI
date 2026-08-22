import 'evidence_explainability_catalog.dart';
import 'evidence_family.dart';
import 'evidence_kind.dart';
import 'metric_explainability.dart';

export 'evidence_kind.dart';
export 'metric_explainability.dart';

class EvidenceDefinition {
  const EvidenceDefinition({
    this.kind = EvidenceKind.generic,
    this.family = EvidenceFamily.generic,
    required this.name,
    required this.description,
    required this.whyItMatters,
    required this.calculation,
    MetricExplainability? explainability,
  }) : _explainabilityOverride = explainability;

  final EvidenceKind kind;

  /// Independent evidence family used by the consensus engine to avoid
  /// double-counting highly related signals.
  final EvidenceFamily family;

  final String name;
  final String description;
  final String whyItMatters;
  final String calculation;

  /// Optional explicit override, mainly useful for special definitions and
  /// isolated tests. Production evidence kinds normally resolve their
  /// explainability metadata from [EvidenceExplainabilityCatalog].
  final MetricExplainability? _explainabilityOverride;

  /// Reusable explainability contract introduced in v0.10.1.
  ///
  /// Production evidence receives its metadata from one central catalog keyed
  /// by [EvidenceKind], preventing explanation text and semantic-role rules
  /// from being duplicated across provider implementations.
  MetricExplainability? get explainability =>
      _explainabilityOverride ?? EvidenceExplainabilityCatalog.forKind(kind);

  bool get hasCompleteExplainability => explainability?.isComplete ?? false;
}
