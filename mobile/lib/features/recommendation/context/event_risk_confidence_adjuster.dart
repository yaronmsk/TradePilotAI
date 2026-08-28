import '../models/evidence_contribution.dart';
import '../models/scoring_result.dart';
import '../models/strategy_summary.dart';
import '../strategy/event_risk_strategy_policy.dart';
import 'external_context_profile.dart';

class EventRiskConfidenceAdjuster {
  static const double maximumAllowedPenaltyPoints =
      EventRiskStrategyPolicy.maximumPenaltyPoints;

  const EventRiskConfidenceAdjuster({
    this.maximumPenaltyPoints = maximumAllowedPenaltyPoints,
  }) : assert(maximumPenaltyPoints >= 0),
       assert(maximumPenaltyPoints <= maximumAllowedPenaltyPoints);

  final double maximumPenaltyPoints;

  ScoringResult apply({
    required ScoringResult scoringResult,
    required EventRiskProfile eventRisk,
    StrategyType strategy = StrategyType.trader,
  }) {
    final policy = EventRiskStrategyPolicy.forStrategy(strategy);

    if (policy == null || !eventRisk.isAvailable) {
      return scoringResult;
    }

    final requestedPenalty = policy.useExistingProfilePenalty
        ? eventRisk.confidencePenaltyPoints
        : policy.penaltyFor(
            earningsHoursAway: eventRisk.earningsHoursAway,
            macroEventHoursAway: eventRisk.macroEventHoursAway,
          );

    if (requestedPenalty <= 0) {
      return scoringResult;
    }

    final penalty = requestedPenalty
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
          source: ConfidenceModifierSource.eventRisk,
        ),
      ],
    );
  }
}
