import '../models/evidence_contribution.dart';
import '../models/scoring_result.dart';
import 'historical_setup_validation.dart';

class HistoricalConfidenceAdjuster {
  const HistoricalConfidenceAdjuster();

  ScoringResult apply({
    required ScoringResult scoringResult,
    required HistoricalSetupValidation validation,
  }) {
    if (!validation.canInfluenceConfidence ||
        validation.confidenceImpactPoints.abs() < 0.001) {
      return scoringResult;
    }

    final before = scoringResult.confidence;
    final after = (before + validation.confidenceImpactPoints).clamp(
      0.0,
      100.0,
    );
    final factor = before == 0 ? 1.0 : after / before;

    return scoringResult.copyWith(
      score: after,
      evidenceConfidence: scoringResult.evidenceConfidence,
      confidenceModifiers: [
        ...scoringResult.confidenceModifiers,
        ConfidenceModifierImpact(
          label: 'Historical setup validation',
          factor: factor,
          before: before,
          after: after,
        ),
      ],
    );
  }
}
