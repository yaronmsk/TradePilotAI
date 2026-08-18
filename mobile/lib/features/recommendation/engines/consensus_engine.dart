import 'dart:math' as math;

import '../models/evidence_contribution.dart';
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

    final confidenceScale =
        providerCoverageFactor *
        familyCoverageFactor *
        agreementFactor *
        reliabilityFactor;

    final confidence = (averageStrength * confidenceScale).clamp(0.0, 100.0);

    final confidenceModifiers = _buildConfidenceModifiers(
      baseEvidenceStrength: averageStrength,
      providerCoverageFactor: providerCoverageFactor,
      familyCoverageFactor: familyCoverageFactor,
      agreementFactor: agreementFactor,
      reliabilityFactor: reliabilityFactor,
    );

    final attribution = _buildAttribution(
      grouped: grouped,
      familySummaries: familySummaries,
      totalFamilyWeight: totalFamilyWeight,
      finalConfidence: confidence,
      confidenceScale: confidenceScale,
    );

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
      baseEvidenceStrength: averageStrength,
      familyContributions: attribution.familyContributions,
      providerContributions: attribution.providerContributions,
      confidenceModifiers: List.unmodifiable(confidenceModifiers),
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

  List<ConfidenceModifierImpact> _buildConfidenceModifiers({
    required double baseEvidenceStrength,
    required double providerCoverageFactor,
    required double familyCoverageFactor,
    required double agreementFactor,
    required double reliabilityFactor,
  }) {
    final modifiers = <ConfidenceModifierImpact>[];
    var current = baseEvidenceStrength;

    void add(String label, double factor) {
      final after = current * factor;
      modifiers.add(
        ConfidenceModifierImpact(
          label: label,
          factor: factor,
          before: current,
          after: after,
        ),
      );
      current = after;
    }

    add('Provider coverage', providerCoverageFactor);
    add('Evidence-group coverage', familyCoverageFactor);
    add('Signal alignment', agreementFactor);
    add('Data reliability', reliabilityFactor);

    return modifiers;
  }

  _AttributionResult _buildAttribution({
    required Map<EvidenceFamily, List<EvidenceResult>> grouped,
    required List<EvidenceFamilySummary> familySummaries,
    required double totalFamilyWeight,
    required double finalConfidence,
    required double confidenceScale,
  }) {
    final rawFamilies = <_RawFamilyContribution>[];

    for (final familySummary in familySummaries) {
      final evidence =
          grouped[familySummary.family] ?? const <EvidenceResult>[];
      final totalEvidenceWeight = evidence.fold<double>(
        0,
        (sum, result) => sum + result.effectiveWeight,
      );

      if (totalEvidenceWeight <= 0) {
        continue;
      }

      final familyWeightShare =
          familySummary.effectiveWeight / totalFamilyWeight;
      final rawProviders = <_RawProviderContribution>[];

      for (final result in evidence) {
        final evidenceWeightShare =
            result.effectiveWeight / totalEvidenceWeight;
        final signedScore = _signedScore(result);

        final directionImpactPoints =
            familyWeightShare * evidenceWeightShare * signedScore;

        final confidenceContributionPoints =
            familyWeightShare *
            evidenceWeightShare *
            result.score *
            confidenceScale;

        rawProviders.add(
          _RawProviderContribution(
            result: result,
            directionImpactPoints: directionImpactPoints,
            confidenceContributionPoints: confidenceContributionPoints,
          ),
        );
      }

      final familyDirectionImpact = rawProviders.fold<double>(
        0,
        (sum, provider) => sum + provider.directionImpactPoints,
      );
      final familyConfidenceContribution = rawProviders.fold<double>(
        0,
        (sum, provider) => sum + provider.confidenceContributionPoints,
      );

      rawFamilies.add(
        _RawFamilyContribution(
          summary: familySummary,
          directionImpactPoints: familyDirectionImpact,
          confidenceContributionPoints: familyConfidenceContribution,
          providers: rawProviders,
        ),
      );
    }

    final totalAbsoluteFamilyDirection = rawFamilies.fold<double>(
      0,
      (sum, family) => sum + family.directionImpactPoints.abs(),
    );

    final familyContributions = <EvidenceFamilyContribution>[];
    final providerContributions = <EvidenceContribution>[];

    for (final rawFamily in rawFamilies) {
      final totalAbsoluteProviderDirection = rawFamily.providers.fold<double>(
        0,
        (sum, provider) => sum + provider.directionImpactPoints.abs(),
      );

      final providers = rawFamily.providers
          .map((rawProvider) {
            final provider = EvidenceContribution(
              providerName: rawProvider.result.providerName,
              family: rawFamily.summary.family,
              direction: rawProvider.result.direction,
              directionImpactPoints: rawProvider.directionImpactPoints,
              directionShareWithinFamily: totalAbsoluteProviderDirection == 0
                  ? 0
                  : rawProvider.directionImpactPoints.abs() /
                        totalAbsoluteProviderDirection,
              confidenceContributionPoints:
                  rawProvider.confidenceContributionPoints,
              confidenceShare: finalConfidence <= 0
                  ? 0
                  : rawProvider.confidenceContributionPoints / finalConfidence,
            );

            providerContributions.add(provider);
            return provider;
          })
          .toList(growable: false);

      familyContributions.add(
        EvidenceFamilyContribution(
          family: rawFamily.summary.family,
          direction: rawFamily.summary.direction,
          directionImpactPoints: rawFamily.directionImpactPoints,
          directionShare: totalAbsoluteFamilyDirection == 0
              ? 0
              : rawFamily.directionImpactPoints.abs() /
                    totalAbsoluteFamilyDirection,
          confidenceContributionPoints: rawFamily.confidenceContributionPoints,
          confidenceShare: finalConfidence <= 0
              ? 0
              : rawFamily.confidenceContributionPoints / finalConfidence,
          providers: List.unmodifiable(providers),
        ),
      );
    }

    return _AttributionResult(
      familyContributions: List.unmodifiable(familyContributions),
      providerContributions: List.unmodifiable(providerContributions),
    );
  }

  double _signedScore(EvidenceResult result) {
    switch (result.direction) {
      case EvidenceDirection.bullish:
        return result.score;
      case EvidenceDirection.bearish:
        return -result.score;
      case EvidenceDirection.neutral:
      case EvidenceDirection.unknown:
        return 0;
    }
  }
}

class _RawProviderContribution {
  const _RawProviderContribution({
    required this.result,
    required this.directionImpactPoints,
    required this.confidenceContributionPoints,
  });

  final EvidenceResult result;
  final double directionImpactPoints;
  final double confidenceContributionPoints;
}

class _RawFamilyContribution {
  const _RawFamilyContribution({
    required this.summary,
    required this.directionImpactPoints,
    required this.confidenceContributionPoints,
    required this.providers,
  });

  final EvidenceFamilySummary summary;
  final double directionImpactPoints;
  final double confidenceContributionPoints;
  final List<_RawProviderContribution> providers;
}

class _AttributionResult {
  const _AttributionResult({
    required this.familyContributions,
    required this.providerContributions,
  });

  final List<EvidenceFamilyContribution> familyContributions;
  final List<EvidenceContribution> providerContributions;
}
