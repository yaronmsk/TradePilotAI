import 'dart:math' as math;

import '../models/evidence_family.dart';
import '../models/evidence_family_summary.dart';
import '../models/evidence_report.dart';
import '../models/evidence_result.dart';
import '../models/scoring_result.dart';

/// Combines evidence at the family level rather than treating every indicator
/// as an independent vote.
///
/// The strongest effective evidence weight caps each family. Additional
/// indicators in the same family can change that family's direction,
/// reliability, strength and internal agreement, but they cannot linearly
/// multiply the family's influence. This protects the recommendation from
/// false confidence created by several correlated indicators measuring the
/// same underlying behavior.
class ConsensusEngine {
  const ConsensusEngine();

  ScoringResult calculate(EvidenceReport report) {
    final usableResults = report.availableResults
        .where((result) => result.effectiveWeight > 0)
        .toList(growable: false);

    if (usableResults.isEmpty) {
      return ScoringResult(
        score: 0,
        coverage: report.coverage,
        bullishWeight: 0,
        bearishWeight: 0,
        neutralWeight: 0,
        warnings: const ['No usable evidence is available.'],
      );
    }

    final expectedFamilies = report.results
        .map((result) => result.definition.family)
        .toSet();

    final grouped = <EvidenceFamily, List<EvidenceResult>>{};

    for (final evidence in usableResults) {
      grouped
          .putIfAbsent(evidence.definition.family, () => <EvidenceResult>[])
          .add(evidence);
    }

    final familySummaries = grouped.entries
        .map(
          (entry) => _summarizeFamily(family: entry.key, evidence: entry.value),
        )
        .toList(growable: false);

    final totalFamilyWeight = familySummaries.fold<double>(
      0,
      (sum, family) => sum + family.effectiveWeight,
    );

    if (totalFamilyWeight <= 0) {
      return ScoringResult(
        score: 0,
        coverage: report.coverage,
        bullishWeight: 0,
        bearishWeight: 0,
        neutralWeight: 0,
        warnings: const ['Available evidence has no effective family weight.'],
        independentFamilyCount: familySummaries.length,
        familySummaries: List.unmodifiable(familySummaries),
      );
    }

    double bullishWeight = 0;
    double bearishWeight = 0;
    double neutralWeight = 0;
    double weightedStrength = 0;
    double weightedReliability = 0;

    for (final family in familySummaries) {
      final normalizedDirection = (family.directionScore / 100).clamp(
        -1.0,
        1.0,
      );
      final directionalMagnitude = normalizedDirection.abs();

      if (normalizedDirection > 0) {
        bullishWeight += family.effectiveWeight * directionalMagnitude;
      } else if (normalizedDirection < 0) {
        bearishWeight += family.effectiveWeight * directionalMagnitude;
      }

      neutralWeight += family.effectiveWeight * (1 - directionalMagnitude);
      weightedStrength += family.strengthScore * family.effectiveWeight;
      weightedReliability += family.reliability * family.effectiveWeight;
    }

    final directionalSupport = bullishWeight + bearishWeight;

    final bullishSupportPercent = directionalSupport == 0
        ? 0.0
        : (bullishWeight / directionalSupport) * 100;

    final bearishSupportPercent = directionalSupport == 0
        ? 0.0
        : (bearishWeight / directionalSupport) * 100;

    final agreement = directionalSupport == 0
        ? 0.5
        : (math.max(bullishWeight, bearishWeight) / directionalSupport).clamp(
            0.0,
            1.0,
          );

    final conflict = directionalSupport == 0
        ? 0.0
        : ((2 * math.min(bullishWeight, bearishWeight)) / directionalSupport)
              .clamp(0.0, 1.0);

    final directionScore =
        (((bullishWeight - bearishWeight) / totalFamilyWeight) * 100).clamp(
          -100.0,
          100.0,
        );

    final averageStrength = weightedStrength / totalFamilyWeight;
    final averageReliability = weightedReliability / totalFamilyWeight;

    final familyCoverage = expectedFamilies.isEmpty
        ? 0.0
        : (familySummaries.length / expectedFamilies.length).clamp(0.0, 1.0);

    final providerCoverageFactor = 0.60 + (report.coverage * 0.40);
    final familyCoverageFactor = 0.70 + (familyCoverage * 0.30);
    final agreementFactor = 0.70 + (agreement * 0.30);
    final reliabilityFactor = 0.85 + (averageReliability * 0.15);

    final confidence =
        (averageStrength *
                providerCoverageFactor *
                familyCoverageFactor *
                agreementFactor *
                reliabilityFactor)
            .clamp(0.0, 100.0);

    final warnings = <String>[];

    if (!report.hasSufficientCoverage) {
      warnings.add('Evidence coverage is below the required minimum.');
    }

    if (familySummaries.length == 1) {
      warnings.add(
        'Only one independent evidence family is available; cross-family confirmation is limited.',
      );
    }

    if (conflict >= 0.60) {
      warnings.add('Independent evidence families are materially conflicted.');
    }

    if (directionalSupport == 0) {
      warnings.add(
        'No evidence family currently provides directional support.',
      );
    }

    return ScoringResult(
      score: confidence,
      coverage: report.coverage,
      bullishWeight: bullishWeight,
      bearishWeight: bearishWeight,
      neutralWeight: neutralWeight,
      warnings: List.unmodifiable(warnings),
      directionScore: directionScore,
      familyCoverage: familyCoverage,
      agreement: agreement,
      conflict: conflict,
      bullishSupportPercent: bullishSupportPercent,
      bearishSupportPercent: bearishSupportPercent,
      independentFamilyCount: familySummaries.length,
      familySummaries: List.unmodifiable(familySummaries),
    );
  }

  EvidenceFamilySummary _summarizeFamily({
    required EvidenceFamily family,
    required List<EvidenceResult> evidence,
  }) {
    double totalEvidenceWeight = 0;
    double signedStrengthTotal = 0;
    double strengthTotal = 0;
    double reliabilityTotal = 0;
    double bullishMass = 0;
    double bearishMass = 0;
    double cappedFamilyWeight = 0;

    for (final result in evidence) {
      final weight = result.effectiveWeight;

      totalEvidenceWeight += weight;
      cappedFamilyWeight = math.max(cappedFamilyWeight, weight);
      strengthTotal += result.score * weight;
      reliabilityTotal += result.reliability * weight;

      final normalizedStrength = (result.score / 100).clamp(0.0, 1.0);

      switch (result.direction) {
        case EvidenceDirection.bullish:
          signedStrengthTotal += result.score * weight;
          bullishMass += normalizedStrength * weight;
          break;
        case EvidenceDirection.bearish:
          signedStrengthTotal -= result.score * weight;
          bearishMass += normalizedStrength * weight;
          break;
        case EvidenceDirection.neutral:
        case EvidenceDirection.unknown:
          break;
      }
    }

    final directionScore = totalEvidenceWeight == 0
        ? 0.0
        : (signedStrengthTotal / totalEvidenceWeight).clamp(-100.0, 100.0);

    final strengthScore = totalEvidenceWeight == 0
        ? 0.0
        : (strengthTotal / totalEvidenceWeight).clamp(0.0, 100.0);

    final reliability = totalEvidenceWeight == 0
        ? 0.0
        : (reliabilityTotal / totalEvidenceWeight).clamp(0.0, 1.0);

    final directionalMass = bullishMass + bearishMass;
    final agreement = directionalMass == 0
        ? 1.0
        : (math.max(bullishMass, bearishMass) / directionalMass).clamp(
            0.0,
            1.0,
          );

    final direction = directionScore > 5
        ? EvidenceDirection.bullish
        : directionScore < -5
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    return EvidenceFamilySummary(
      family: family,
      direction: direction,
      directionScore: directionScore,
      strengthScore: strengthScore,
      effectiveWeight: cappedFamilyWeight,
      reliability: reliability,
      agreement: agreement,
      evidenceCount: evidence.length,
    );
  }
}
