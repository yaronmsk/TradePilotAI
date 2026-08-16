enum EvidenceKind { generic, candleTrend, rsi, relativeVolume }

class EvidenceDefinition {
  const EvidenceDefinition({
    this.kind = EvidenceKind.generic,
    required this.name,
    required this.description,
    required this.whyItMatters,
    required this.calculation,
  });

  final EvidenceKind kind;
  final String name;
  final String description;
  final String whyItMatters;
  final String calculation;
}
