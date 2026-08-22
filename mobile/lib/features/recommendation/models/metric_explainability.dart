enum MetricSemanticRole {
  directionalEvaluative,
  confidenceRiskOnly,
  contextConfiguration,
}

extension MetricSemanticRolePresentation on MetricSemanticRole {
  String get label {
    return switch (this) {
      MetricSemanticRole.directionalEvaluative => 'Directional / evaluative',
      MetricSemanticRole.confidenceRiskOnly => 'Confidence / risk only',
      MetricSemanticRole.contextConfiguration => 'Context / configuration',
    };
  }

  bool get allowsDirectionalInfluence =>
      this == MetricSemanticRole.directionalEvaluative;
}

class MetricExplainability {
  const MetricExplainability({
    required this.semanticRole,
    required this.whatItIs,
    required this.calculation,
    required this.whyItMatters,
    required this.recommendationImpact,
    required this.limitations,
    this.supportiveInterpretation,
    this.opposingInterpretation,
    this.neutralInterpretation,
    this.boundedImpact,
  });

  final MetricSemanticRole semanticRole;

  /// Plain-language description of what the metric represents.
  final String whatItIs;

  /// How the metric is calculated or derived.
  final String calculation;

  /// Why the metric is relevant to the analysis.
  final String whyItMatters;

  /// Meaning of a supportive result, when directional interpretation applies.
  final String? supportiveInterpretation;

  /// Meaning of an opposing result, when directional interpretation applies.
  final String? opposingInterpretation;

  /// Meaning of a neutral/unknown result, when useful for the metric.
  final String? neutralInterpretation;

  /// How the metric may affect direction, confidence and/or risk.
  final String recommendationImpact;

  /// Important limitations and cases where the metric can mislead.
  final String limitations;

  /// Explicit impact boundary for confidence/risk-only metrics.
  ///
  /// Example:
  /// "Can reduce confidence by at most 12 points and cannot create
  /// Buy/Sell direction."
  final String? boundedImpact;

  bool get isComplete {
    if (!_hasText(whatItIs) ||
        !_hasText(calculation) ||
        !_hasText(whyItMatters) ||
        !_hasText(recommendationImpact) ||
        !_hasText(limitations)) {
      return false;
    }

    return switch (semanticRole) {
      MetricSemanticRole.directionalEvaluative =>
        _hasText(supportiveInterpretation) && _hasText(opposingInterpretation),
      MetricSemanticRole.confidenceRiskOnly => _hasText(boundedImpact),
      MetricSemanticRole.contextConfiguration => true,
    };
  }

  bool get allowsDirectionalInfluence =>
      semanticRole.allowsDirectionalInfluence;

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
