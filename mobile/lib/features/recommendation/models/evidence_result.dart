enum EvidenceStatus {
  available,
  unavailable,
  insufficientData,
  error,
}

enum EvidenceDirection {
  bullish,
  bearish,
  neutral,
  unknown,
}

enum EvidenceStrength {
  veryWeak,
  weak,
  moderate,
  strong,
  exceptional,
}

class EvidenceResult {
  final String providerName;
  final EvidenceStatus status;
  final EvidenceDirection direction;
  final EvidenceStrength strength;

  /// Evidence strength from 0 to 100.
  final double score;

  /// Default importance assigned to this evidence provider.
  final double baseWeight;

  /// Runtime adjustment based on the wider market context.
  final double dynamicWeight;

  /// Data reliability from 0 to 1.
  final double reliability;

  /// Human-readable values displayed in the UI.
  final String currentValue;
  final String baselineValue;
  final String relativeValue;

  final String explanation;
  final String? unavailableReason;

  const EvidenceResult({
    required this.providerName,
    required this.status,
    required this.direction,
    required this.strength,
    required this.score,
    required this.baseWeight,
    required this.dynamicWeight,
    required this.reliability,
    required this.currentValue,
    required this.baselineValue,
    required this.relativeValue,
    required this.explanation,
    this.unavailableReason,
  });

  bool get isAvailable => status == EvidenceStatus.available;

  double get effectiveWeight =>
      isAvailable ? baseWeight * dynamicWeight * reliability : 0;
}