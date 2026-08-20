import 'historical_setup_fingerprint.dart';

class HistoricalSetupCase {
  const HistoricalSetupCase({
    required this.symbol,
    required this.occurredAt,
    required this.fingerprint,
    required this.forwardReturnPercent,
    required this.maxFavorableExcursionPercent,
    required this.maxAdverseExcursionPercent,
  });

  final String symbol;
  final DateTime occurredAt;
  final HistoricalSetupFingerprint fingerprint;

  /// Raw price return over the validation horizon.
  final double forwardReturnPercent;

  /// Best move after the setup during the validation horizon.
  final double maxFavorableExcursionPercent;

  /// Worst move after the setup during the validation horizon. This is stored
  /// as a negative percentage when price moved against the long direction.
  final double maxAdverseExcursionPercent;
}

/// A historical observation used only as the current stock's comparison
/// baseline. It intentionally keeps the surrounding context fingerprint but
/// does not need to resemble the current evidence combination.
class HistoricalComparisonObservation {
  const HistoricalComparisonObservation({
    required this.symbol,
    required this.occurredAt,
    required this.fingerprint,
    required this.forwardReturnPercent,
  });

  final String symbol;
  final DateTime occurredAt;
  final HistoricalSetupFingerprint fingerprint;
  final double forwardReturnPercent;
}

class HistoricalSetupDataset {
  const HistoricalSetupDataset({
    required this.cases,
    required this.comparisonObservations,
    required this.isSynthetic,
    required this.sourceLabel,
  });

  /// Candidate setup analogs. The matcher applies strategy, interval, Stock
  /// Profile and setup-similarity rules before these can affect validation.
  final List<HistoricalSetupCase> cases;

  /// General observations from the current stock. The comparison selector
  /// keeps only observations with the same strategy, interval and Stock
  /// Profile plus comparable volatility and market environment. Evidence-family
  /// similarity is deliberately NOT required here; this baseline answers what
  /// the stock usually did under comparable surrounding conditions without
  /// requiring today's specific setup.
  final List<HistoricalComparisonObservation> comparisonObservations;

  final bool isSynthetic;
  final String sourceLabel;
}
