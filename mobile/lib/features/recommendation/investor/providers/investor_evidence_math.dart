import '../../models/evidence_result.dart';
import '../models/investor_metric_assessment.dart';

class InvestorWeightedMetric {
  const InvestorWeightedMetric({required this.metric, required this.weight});

  final InvestorMetricAssessment metric;
  final double weight;
}

class InvestorEvidenceAggregate {
  const InvestorEvidenceAggregate({
    required this.direction,
    required this.strength,
    required this.signedScore,
    required this.strengthScore,
    required this.reliability,
  });

  final EvidenceDirection direction;
  final EvidenceStrength strength;
  final double signedScore;
  final double strengthScore;
  final double reliability;
}

class InvestorEvidenceMath {
  InvestorEvidenceMath._();

  static InvestorEvidenceAggregate aggregate(
    Iterable<InvestorWeightedMetric> weightedMetrics,
  ) {
    final usable = weightedMetrics
        .where((entry) => entry.metric.isAvailable && entry.weight > 0)
        .toList(growable: false);

    if (usable.isEmpty) {
      return const InvestorEvidenceAggregate(
        direction: EvidenceDirection.unknown,
        strength: EvidenceStrength.veryWeak,
        signedScore: 0,
        strengthScore: 0,
        reliability: 0,
      );
    }

    final totalWeight = usable.fold<double>(
      0,
      (sum, entry) => sum + entry.weight,
    );

    final weightedSigned = usable.fold<double>(
      0,
      (sum, entry) => sum + (entry.metric.signedScore * entry.weight),
    );

    final weightedAbsolute = usable.fold<double>(
      0,
      (sum, entry) => sum + (entry.metric.signedScore.abs() * entry.weight),
    );

    final weightedReliability = usable.fold<double>(
      0,
      (sum, entry) => sum + (entry.metric.reliability * entry.weight),
    );

    final signedScore = (weightedSigned / totalWeight).clamp(-100.0, 100.0);
    final strengthScore = (weightedAbsolute / totalWeight).clamp(0.0, 100.0);

    final agreement = weightedAbsolute == 0
        ? 1.0
        : (weightedSigned.abs() / weightedAbsolute).clamp(0.0, 1.0);

    final averageReliability = (weightedReliability / totalWeight).clamp(
      0.0,
      1.0,
    );

    final reliability = (averageReliability * (0.70 + (agreement * 0.30)))
        .clamp(0.0, 1.0);

    final direction = signedScore > 10
        ? EvidenceDirection.bullish
        : signedScore < -10
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    final strength = strengthScore >= 80
        ? EvidenceStrength.exceptional
        : strengthScore >= 60
        ? EvidenceStrength.strong
        : strengthScore >= 35
        ? EvidenceStrength.moderate
        : strengthScore >= 15
        ? EvidenceStrength.weak
        : EvidenceStrength.veryWeak;

    return InvestorEvidenceAggregate(
      direction: direction,
      strength: strength,
      signedScore: signedScore,
      strengthScore: strengthScore,
      reliability: reliability,
    );
  }

  static double symmetricNormalize(
    double value, {
    required double fullScaleMagnitude,
  }) {
    if (fullScaleMagnitude <= 0) {
      return 0;
    }

    return ((value / fullScaleMagnitude) * 100).clamp(-100.0, 100.0);
  }
}
