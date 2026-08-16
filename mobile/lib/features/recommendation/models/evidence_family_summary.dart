import 'evidence_family.dart';
import 'evidence_result.dart';

class EvidenceFamilySummary {
  const EvidenceFamilySummary({
    required this.family,
    required this.direction,
    required this.directionScore,
    required this.strengthScore,
    required this.effectiveWeight,
    required this.reliability,
    required this.agreement,
    required this.evidenceCount,
  });

  final EvidenceFamily family;
  final EvidenceDirection direction;

  /// Signed score from -100 (fully bearish) to +100 (fully bullish).
  final double directionScore;

  /// Average evidence strength inside the family, from 0 to 100.
  final double strengthScore;

  /// Capped family influence. Adding another correlated indicator in the same
  /// family does not linearly increase this value.
  final double effectiveWeight;

  /// Average reliability of the usable evidence in this family, from 0 to 1.
  final double reliability;

  /// Internal directional agreement inside the family, from 0 to 1.
  final double agreement;

  final int evidenceCount;
}
