import 'metric_explainability.dart';

class SwingDecisionHelperMetric {
  const SwingDecisionHelperMetric({
    required this.label,
    required this.value,
    required this.detail,
    required this.explainability,
  });

  final String label;
  final String value;
  final String detail;
  final MetricExplainability explainability;
}

class SwingDecisionHelperSummary {
  const SwingDecisionHelperSummary({
    required this.entryQuality,
    required this.priceStretch,
    required this.structureWatch,
  });

  final SwingDecisionHelperMetric entryQuality;
  final SwingDecisionHelperMetric priceStretch;
  final SwingDecisionHelperMetric structureWatch;
}
