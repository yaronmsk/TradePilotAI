import 'evidence_definition.dart';

enum EvidenceStatus { available, unavailable, insufficientData, error }

enum EvidenceDirection { bullish, bearish, neutral, unknown }

enum EvidenceStrength { veryWeak, weak, moderate, strong, exceptional }

class EvidenceResult {
  const EvidenceResult({
    required this.providerName,
    required this.definition,
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

  final String providerName;

  /// Deterministic information explaining what this evidence represents.
  final EvidenceDefinition definition;

  final EvidenceStatus status;
  final EvidenceDirection direction;
  final EvidenceStrength strength;

  /// Evidence strength from 0 to 100.
  final double score;

  /// Default importance assigned to this evidence provider.
  final double baseWeight;

  /// Runtime adjustment based on stock and market context.
  final double dynamicWeight;

  /// Data reliability from 0 to 1.
  final double reliability;

  /// Human-readable values displayed in the UI.
  final String currentValue;
  final String baselineValue;
  final String relativeValue;

  final String explanation;
  final String? unavailableReason;

  bool get isAvailable => status == EvidenceStatus.available;

  double get effectiveWeight =>
      isAvailable ? baseWeight * dynamicWeight * reliability : 0;

  EvidenceResult copyWith({
    String? providerName,
    EvidenceDefinition? definition,
    EvidenceStatus? status,
    EvidenceDirection? direction,
    EvidenceStrength? strength,
    double? score,
    double? baseWeight,
    double? dynamicWeight,
    double? reliability,
    String? currentValue,
    String? baselineValue,
    String? relativeValue,
    String? explanation,
    String? unavailableReason,
    bool clearUnavailableReason = false,
  }) {
    return EvidenceResult(
      providerName: providerName ?? this.providerName,
      definition: definition ?? this.definition,
      status: status ?? this.status,
      direction: direction ?? this.direction,
      strength: strength ?? this.strength,
      score: score ?? this.score,
      baseWeight: baseWeight ?? this.baseWeight,
      dynamicWeight: dynamicWeight ?? this.dynamicWeight,
      reliability: reliability ?? this.reliability,
      currentValue: currentValue ?? this.currentValue,
      baselineValue: baselineValue ?? this.baselineValue,
      relativeValue: relativeValue ?? this.relativeValue,
      explanation: explanation ?? this.explanation,
      unavailableReason: clearUnavailableReason
          ? null
          : unavailableReason ?? this.unavailableReason,
    );
  }
}
