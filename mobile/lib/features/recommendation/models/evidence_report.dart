import 'evidence_result.dart';

class EvidenceReport {
  final List<EvidenceResult> results;

  /// Percentage of expected evidence providers that returned usable data.
  final double coverage;

  /// Number of evidence providers expected for this analysis.
  final int expectedProviderCount;

  const EvidenceReport({
    required this.results,
    required this.coverage,
    required this.expectedProviderCount,
  });

  List<EvidenceResult> get availableResults =>
      results.where((result) => result.isAvailable).toList();

  List<EvidenceResult> get unavailableResults =>
      results.where((result) => !result.isAvailable).toList();

  List<EvidenceResult> get bullishResults => availableResults
      .where((result) => result.direction == EvidenceDirection.bullish)
      .toList();

  List<EvidenceResult> get bearishResults => availableResults
      .where((result) => result.direction == EvidenceDirection.bearish)
      .toList();

  List<EvidenceResult> get neutralResults => availableResults
      .where((result) => result.direction == EvidenceDirection.neutral)
      .toList();

  int get availableProviderCount => availableResults.length;

  bool get hasSufficientCoverage => coverage >= 0.60;

  factory EvidenceReport.fromResults({
    required List<EvidenceResult> results,
    required int expectedProviderCount,
  }) {
    if (expectedProviderCount <= 0) {
      return EvidenceReport(
        results: List.unmodifiable(results),
        coverage: 0,
        expectedProviderCount: 0,
      );
    }

    final availableCount =
        results.where((result) => result.isAvailable).length;

    final calculatedCoverage =
        (availableCount / expectedProviderCount).clamp(0.0, 1.0);

    return EvidenceReport(
      results: List.unmodifiable(results),
      coverage: calculatedCoverage,
      expectedProviderCount: expectedProviderCount,
    );
  }
}