import '../models/evidence_report.dart';
import '../models/evidence_result.dart';
import '../models/scoring_result.dart';

class ScoringEngine {
  const ScoringEngine();

  ScoringResult calculate(EvidenceReport report) {
    final availableResults = report.availableResults;

    if (availableResults.isEmpty) {
      return ScoringResult(
        score: 0,
        coverage: report.coverage,
        bullishWeight: 0,
        bearishWeight: 0,
        neutralWeight: 0,
        warnings: const ['No usable evidence is available.'],
      );
    }

    double bullishWeight = 0;
    double bearishWeight = 0;
    double neutralWeight = 0;
    double totalEffectiveWeight = 0;
    double weightedStrengthTotal = 0;

    for (final evidence in availableResults) {
      final effectiveWeight = evidence.effectiveWeight;

      if (effectiveWeight <= 0) {
        continue;
      }

      totalEffectiveWeight += effectiveWeight;
      weightedStrengthTotal += evidence.score * effectiveWeight;

      switch (evidence.direction) {
        case EvidenceDirection.bullish:
          bullishWeight += effectiveWeight;
          break;
        case EvidenceDirection.bearish:
          bearishWeight += effectiveWeight;
          break;
        case EvidenceDirection.neutral:
        case EvidenceDirection.unknown:
          neutralWeight += effectiveWeight;
          break;
      }
    }

    final warnings = <String>[];

    if (!report.hasSufficientCoverage) {
      warnings.add('Evidence coverage is below the required minimum.');
    }

    if (totalEffectiveWeight == 0) {
      warnings.add('Available evidence has no effective weight.');

      return ScoringResult(
        score: 0,
        coverage: report.coverage,
        bullishWeight: bullishWeight,
        bearishWeight: bearishWeight,
        neutralWeight: neutralWeight,
        warnings: List.unmodifiable(warnings),
      );
    }

    final weightedStrength =
        (weightedStrengthTotal / totalEffectiveWeight).clamp(0.0, 100.0);

    final directionalWeight = bullishWeight + bearishWeight;

    double directionBalance = 0;

    if (directionalWeight > 0) {
      directionBalance =
          ((bullishWeight - bearishWeight) / directionalWeight)
              .clamp(-1.0, 1.0);
    }

    final directionalScore = 50 + (directionBalance * 50);

    final finalScore =
        ((directionalScore * 0.70) + (weightedStrength * 0.30))
            .clamp(0.0, 100.0);

    return ScoringResult(
      score: finalScore,
      coverage: report.coverage,
      bullishWeight: bullishWeight,
      bearishWeight: bearishWeight,
      neutralWeight: neutralWeight,
      warnings: List.unmodifiable(warnings),
    );
  }
}