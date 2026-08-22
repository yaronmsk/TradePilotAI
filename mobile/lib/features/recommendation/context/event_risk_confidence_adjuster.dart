import '../models/evidence_contribution.dart';
import '../models/scoring_result.dart';
import 'external_context_profile.dart';

class EventRiskConfidenceAdjuster {
  const EventRiskConfidenceAdjuster({this.maximumPenaltyPoints = 12});

  final double maximumPenaltyPoints;

  ScoringResult apply({
    required ScoringResult scoringResult,
    required EventRiskProfile eventRisk,
  }) {
    if (!eventRisk.isAvailable || eventRisk.confidencePenaltyPoints <= 0) {
      return scoringResult;
    }

    final penalty = eventRisk.confidencePenaltyPoints
        .clamp(0.0, maximumPenaltyPoints)
        .toDouble();
    final before = scoringResult.confidence;
    final after = (before - penalty).clamp(0.0, 100.0).toDouble();
    final factor = before <= 0 ? 1.0 : after / before;

    return scoringResult.copyWith(
      score: after,
      evidenceConfidence: scoringResult.evidenceConfidence,
      confidenceModifiers: [
        ...scoringResult.confidenceModifiers,
        ConfidenceModifierImpact(
          label: 'Upcoming event risk',
          factor: factor,
          before: before,
          after: after,
        ),
      ],
    );
  }
}
