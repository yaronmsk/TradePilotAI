class ScoringResult {
  final double score;
  final double coverage;
  final double bullishWeight;
  final double bearishWeight;
  final double neutralWeight;
  final List<String> warnings;

  const ScoringResult({
    required this.score,
    required this.coverage,
    required this.bullishWeight,
    required this.bearishWeight,
    required this.neutralWeight,
    required this.warnings,
  });

  bool get hasSufficientCoverage => coverage >= 0.60;
}