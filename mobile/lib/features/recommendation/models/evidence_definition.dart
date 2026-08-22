import 'evidence_family.dart';

enum EvidenceKind {
  generic,
  candleTrend,
  rsi,
  relativeVolume,
  emaStructure,
  macdMomentum,
  vwapPosition,
  supportResistance,
  volumeConfirmation,
  priceExtension,
  multiTimeframeTrend,
  marketContext,
  marketBreadth,
  newsSentiment,
}

class EvidenceDefinition {
  const EvidenceDefinition({
    this.kind = EvidenceKind.generic,
    this.family = EvidenceFamily.generic,
    required this.name,
    required this.description,
    required this.whyItMatters,
    required this.calculation,
  });

  final EvidenceKind kind;

  /// Independent evidence family used by the consensus engine to avoid
  /// double-counting highly related signals.
  final EvidenceFamily family;

  final String name;
  final String description;
  final String whyItMatters;
  final String calculation;
}
