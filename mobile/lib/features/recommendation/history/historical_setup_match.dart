import 'historical_setup_case.dart';

class HistoricalSetupMatch {
  const HistoricalSetupMatch({
    required this.setupCase,
    required this.similarity,
    required this.weight,
  });

  final HistoricalSetupCase setupCase;

  /// 0..1 similarity between setup-time characteristics only.
  final double similarity;

  /// Statistical weight used when aggregating outcomes. Same-symbol matches
  /// receive a modest preference but never bypass the similarity calculation.
  final double weight;
}
