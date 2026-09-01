import '../../models/evidence_result.dart';
import '../../models/metric_explainability.dart';
import 'investor_metric_explainability_catalog.dart';

enum InvestorMetricAssessmentStatus { available, insufficientData, unavailable }

class InvestorMetricAssessment {
  const InvestorMetricAssessment({
    required this.kind,
    required this.status,
    required this.direction,
    required this.signedScore,
    required this.reliability,
    required this.currentValue,
    required this.baselineValue,
    required this.explanation,
    required this.explainability,
  });

  final InvestorMetricKind kind;
  final InvestorMetricAssessmentStatus status;
  final EvidenceDirection direction;

  /// Symmetric evaluative signal from -100 (strongly opposing) to
  /// +100 (strongly supportive). This is an internal family-building value,
  /// not a user-facing recommendation percentage.
  final double signedScore;

  final double reliability;
  final String currentValue;
  final String baselineValue;
  final String explanation;
  final MetricExplainability explainability;

  bool get isAvailable => status == InvestorMetricAssessmentStatus.available;
  bool get hasCompleteExplainability => explainability.isComplete;
}

class InvestorEvidenceAssessment {
  InvestorEvidenceAssessment({
    required this.evidence,
    required List<InvestorMetricAssessment> metrics,
  }) : metrics = List.unmodifiable(metrics);

  final EvidenceResult evidence;
  final List<InvestorMetricAssessment> metrics;

  bool get metricsHaveCompleteExplainability =>
      metrics.every((metric) => metric.hasCompleteExplainability);
}
