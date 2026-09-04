import 'dart:math' as math;

import '../../engines/consensus_engine.dart';
import '../../models/evidence_contribution.dart';
import '../../models/evidence_definition.dart';
import '../../models/evidence_family.dart';
import '../../models/evidence_report.dart';
import '../../models/evidence_result.dart';
import '../../models/recommendation.dart';
import '../../models/scoring_result.dart';
import '../models/investor_metric_assessment.dart';
import '../strategy/investor_recommendation_policy.dart';

class InvestorRecommendationAnalysis {
  InvestorRecommendationAnalysis({
    required this.recommendation,
    required this.coreFamilyCount,
    required this.coreCoverage,
    required this.requiredCoreFamiliesAvailable,
    required this.contextDirectionScale,
    required this.contextDirectionShare,
    required List<EvidenceFamily> excludedRecommendationFamilies,
  }) : excludedRecommendationFamilies = List.unmodifiable(
         excludedRecommendationFamilies,
       );

  final Recommendation recommendation;

  /// Available unique breadth-eligible fundamental families.
  final int coreFamilyCount;

  /// Core-family coverage against the six expected breadth-eligible families.
  final double coreCoverage;

  final bool requiredCoreFamiliesAvailable;

  /// Multiplicative scale applied to all directional context evidence before
  /// the shared ConsensusEngine is called.
  final double contextDirectionScale;

  /// Actual post-cap Market Context + Ownership direction-attribution share.
  final double contextDirectionShare;

  /// Families that remain visible analysis but intentionally receive zero
  /// recommendation weight.
  final List<EvidenceFamily> excludedRecommendationFamilies;
}

class InvestorRecommendationEngine {
  const InvestorRecommendationEngine({
    this.consensusEngine = const ConsensusEngine(),
  });

  final ConsensusEngine consensusEngine;

  InvestorRecommendationAnalysis create({
    required Iterable<InvestorEvidenceAssessment> assessments,
    required DateTime analysisTime,
  }) {
    final input = assessments.toList(growable: false);
    final originalResults = input
        .map((assessment) => assessment.evidence)
        .toList(growable: false);

    final coreResults = _withMissingFamilyPlaceholders(
      originalResults.where(
        (result) => InvestorRecommendationPolicy.isBreadthEligibleCore(
          result.definition.family,
        ),
      ),
      InvestorRecommendationPolicy.breadthEligibleCoreFamilies,
    );

    final availableCoreFamilies = coreResults
        .where((result) => result.isAvailable)
        .map((result) => result.definition.family)
        .toSet();

    final coreFamilyCount = availableCoreFamilies.length;
    final coreCoverage =
        coreFamilyCount / InvestorRecommendationPolicy.expectedCoreFamilyCount;
    final requiredCoreFamiliesAvailable =
        InvestorRecommendationPolicy.hasRequiredCoreFamilies(
          availableCoreFamilies,
        );

    final coreReport = EvidenceReport.fromResults(
      results: coreResults,
      expectedProviderCount:
          InvestorRecommendationPolicy.expectedCoreFamilyCount,
    );
    final coreConsensus = consensusEngine.calculate(coreReport);

    final coreDirectionalMass = _directionalMassByFamily(
      originalResults,
      InvestorRecommendationPolicy.breadthEligibleCoreFamilies,
    );
    final contextDirectionalMass = _directionalMassByFamily(
      originalResults,
      InvestorRecommendationPolicy.directionalContextFamilies,
    );

    final contextScale = _contextScale(
      coreDirectionalMass: coreDirectionalMass,
      contextDirectionalMass: contextDirectionalMass,
    );

    final adjustedResults = originalResults
        .map(
          (result) =>
              _adjustForRecommendation(result, contextScale: contextScale),
        )
        .toList(growable: false);

    final directionalFamilies = {
      ...InvestorRecommendationPolicy.breadthEligibleCoreFamilies,
      ...InvestorRecommendationPolicy.directionalContextFamilies,
    };

    final directionResults = _withMissingFamilyPlaceholders(
      adjustedResults.where(
        (result) => directionalFamilies.contains(result.definition.family),
      ),
      directionalFamilies,
    );

    final directionReport = EvidenceReport.fromResults(
      results: directionResults,
      expectedProviderCount: directionalFamilies.length,
    );
    final directionConsensus = consensusEngine.calculate(directionReport);

    final finalConsensus = _mergeDirectionWithCoreConfidence(
      directionConsensus: directionConsensus,
      coreConsensus: coreConsensus,
      coreCoverage: coreCoverage,
    );

    final contextDirectionShare = finalConsensus.familyContributions
        .where(
          (contribution) => InvestorRecommendationPolicy
              .directionalContextFamilies
              .contains(contribution.family),
        )
        .fold<double>(
          0,
          (sum, contribution) => sum + contribution.directionShare,
        );

    final displayResults = adjustedResults
        .where((result) {
          final family = result.definition.family;
          return InvestorRecommendationPolicy.breadthEligibleCoreFamilies
                  .contains(family) ||
              InvestorRecommendationPolicy.directionalContextFamilies.contains(
                family,
              ) ||
              InvestorRecommendationPolicy.zeroRecommendationWeightFamilies
                  .contains(family);
        })
        .toList(growable: false);

    final displayReport = EvidenceReport.fromResults(
      results: displayResults,
      expectedProviderCount:
          InvestorRecommendationPolicy.breadthEligibleCoreFamilies.length +
          InvestorRecommendationPolicy.directionalContextFamilies.length +
          InvestorRecommendationPolicy.zeroRecommendationWeightFamilies.length,
    );

    final recommendation = _decide(
      scoring: finalConsensus,
      evidenceReport: displayReport,
      analysisTime: analysisTime,
      coreFamilyCount: coreFamilyCount,
      coreCoverage: coreCoverage,
      requiredCoreFamiliesAvailable: requiredCoreFamiliesAvailable,
      coreConflict: coreConsensus.conflict,
    );

    return InvestorRecommendationAnalysis(
      recommendation: recommendation,
      coreFamilyCount: coreFamilyCount,
      coreCoverage: coreCoverage,
      requiredCoreFamiliesAvailable: requiredCoreFamiliesAvailable,
      contextDirectionScale: contextScale,
      contextDirectionShare: contextDirectionShare,
      excludedRecommendationFamilies: const [
        EvidenceFamily.competitiveDurability,
      ],
    );
  }

  Recommendation _decide({
    required ScoringResult scoring,
    required EvidenceReport evidenceReport,
    required DateTime analysisTime,
    required int coreFamilyCount,
    required double coreCoverage,
    required bool requiredCoreFamiliesAvailable,
    required double coreConflict,
  }) {
    final directionScore = (scoring.directionScore ?? 0).clamp(-100.0, 100.0);
    final confidence = scoring.confidence;

    final hasBreadth =
        coreFamilyCount >=
            InvestorRecommendationPolicy.minimumCoreFamiliesForAction &&
        coreCoverage >= InvestorRecommendationPolicy.minimumCoreCoverage &&
        requiredCoreFamiliesAvailable;

    if (!hasBreadth) {
      final blockers = <String>[
        if (coreFamilyCount <
            InvestorRecommendationPolicy.minimumCoreFamiliesForAction)
          'fewer than ${InvestorRecommendationPolicy.minimumCoreFamiliesForAction} independent core fundamental families are available',
        if (coreCoverage < InvestorRecommendationPolicy.minimumCoreCoverage)
          'core-fundamental coverage is below the required level',
        if (!requiredCoreFamiliesAvailable) 'Valuation is not available',
      ];

      return _build(
        type: RecommendationType.wait,
        scoring: scoring,
        evidenceReport: evidenceReport,
        analysisTime: analysisTime,
        reasons: const [
          RecommendationDecisionReason.insufficientCoverage,
          RecommendationDecisionReason.insufficientFamilyBreadth,
        ],
        explanation:
            'The long-term thesis is not actionable yet because ${_joinWithAnd(blockers)}.',
      );
    }

    if (coreConflict >=
        InvestorRecommendationPolicy.materialConflictThreshold) {
      return _build(
        type: RecommendationType.hold,
        scoring: scoring,
        evidenceReport: evidenceReport,
        analysisTime: analysisTime,
        reasons: const [RecommendationDecisionReason.materialConflict],
        explanation:
            'Core long-term fundamentals materially conflict, so there is no clear Investor direction.',
      );
    }

    if (directionScore >=
            InvestorRecommendationPolicy.strongDirectionThreshold &&
        confidence >= InvestorRecommendationPolicy.strongActionConfidence) {
      return _build(
        type: RecommendationType.strongBuy,
        scoring: scoring,
        evidenceReport: evidenceReport,
        analysisTime: analysisTime,
        reasons: const [RecommendationDecisionReason.strongBullishAction],
        explanation:
            'Core fundamentals strongly support the long-term thesis with high confidence; contextual evidence remains capped and secondary.',
      );
    }

    if (directionScore >=
            InvestorRecommendationPolicy.actionDirectionThreshold &&
        confidence >= InvestorRecommendationPolicy.minimumActionConfidence) {
      return _build(
        type: RecommendationType.buy,
        scoring: scoring,
        evidenceReport: evidenceReport,
        analysisTime: analysisTime,
        reasons: const [RecommendationDecisionReason.bullishAction],
        explanation:
            'Core fundamentals support the long-term thesis with sufficient breadth and confidence; contextual evidence remains capped and secondary.',
      );
    }

    if (directionScore <=
            -InvestorRecommendationPolicy.strongDirectionThreshold &&
        confidence >= InvestorRecommendationPolicy.strongActionConfidence) {
      return _build(
        type: RecommendationType.strongSell,
        scoring: scoring,
        evidenceReport: evidenceReport,
        analysisTime: analysisTime,
        reasons: const [RecommendationDecisionReason.strongBearishAction],
        explanation:
            'Core fundamentals strongly oppose the long-term thesis with high confidence; contextual evidence remains capped and secondary.',
      );
    }

    if (directionScore <=
            -InvestorRecommendationPolicy.actionDirectionThreshold &&
        confidence >= InvestorRecommendationPolicy.minimumActionConfidence) {
      return _build(
        type: RecommendationType.sell,
        scoring: scoring,
        evidenceReport: evidenceReport,
        analysisTime: analysisTime,
        reasons: const [RecommendationDecisionReason.bearishAction],
        explanation:
            'Core fundamentals oppose the long-term thesis with sufficient breadth and confidence; contextual evidence remains capped and secondary.',
      );
    }

    if (directionScore.abs() <=
        InvestorRecommendationPolicy.holdDirectionThreshold) {
      return _build(
        type: RecommendationType.hold,
        scoring: scoring,
        evidenceReport: evidenceReport,
        analysisTime: analysisTime,
        reasons: const [RecommendationDecisionReason.neutralEvidence],
        explanation:
            'Core long-term evidence is broadly balanced, so there is no meaningful Investor directional advantage.',
      );
    }

    final reasons = <RecommendationDecisionReason>[
      if (directionScore.abs() <
          InvestorRecommendationPolicy.actionDirectionThreshold)
        RecommendationDecisionReason.insufficientDirectionalStrength,
      if (confidence < InvestorRecommendationPolicy.minimumActionConfidence)
        RecommendationDecisionReason.insufficientConfidence,
    ];

    return _build(
      type: RecommendationType.wait,
      scoring: scoring,
      evidenceReport: evidenceReport,
      analysisTime: analysisTime,
      reasons: reasons,
      explanation:
          'A long-term direction is forming, but direction and/or confidence has not yet reached the Investor action threshold.',
    );
  }

  Recommendation _build({
    required RecommendationType type,
    required ScoringResult scoring,
    required EvidenceReport evidenceReport,
    required DateTime analysisTime,
    required List<RecommendationDecisionReason> reasons,
    required String explanation,
  }) {
    return Recommendation(
      type: type,
      evidenceScore: scoring.confidence,
      consensus: scoring,
      oneLineExplanation: explanation,
      timeframe: 'Months to years',
      candleCount: 0,
      analysisTime: analysisTime,
      evidenceReport: evidenceReport,
      decisionReasons: List.unmodifiable(reasons),
    );
  }

  EvidenceResult _adjustForRecommendation(
    EvidenceResult result, {
    required double contextScale,
  }) {
    final family = result.definition.family;

    if (InvestorRecommendationPolicy.zeroRecommendationWeightFamilies.contains(
      family,
    )) {
      return result.copyWith(dynamicWeight: 0);
    }

    if (InvestorRecommendationPolicy.directionalContextFamilies.contains(
      family,
    )) {
      return result.copyWith(
        dynamicWeight: result.dynamicWeight * contextScale,
      );
    }

    if (InvestorRecommendationPolicy.breadthEligibleCoreFamilies.contains(
      family,
    )) {
      return result;
    }

    return result.copyWith(dynamicWeight: 0);
  }

  List<EvidenceResult> _withMissingFamilyPlaceholders(
    Iterable<EvidenceResult> results,
    Set<EvidenceFamily> expectedFamilies,
  ) {
    final list = results.toList(growable: true);
    final presentFamilies = list
        .map((result) => result.definition.family)
        .toSet();

    for (final family in expectedFamilies) {
      if (!presentFamilies.contains(family)) {
        list.add(_unavailablePlaceholder(family));
      }
    }

    return List.unmodifiable(list);
  }

  EvidenceResult _unavailablePlaceholder(EvidenceFamily family) {
    return EvidenceResult(
      providerName: 'Investor ${family.name} coverage placeholder',
      definition: EvidenceDefinition(
        family: family,
        name: family.name,
        description: 'Coverage placeholder for missing Investor evidence.',
        whyItMatters:
            'Missing Investor evidence must reduce coverage rather than disappear from the denominator.',
        calculation:
            'This placeholder contributes zero weight and exists only to preserve the expected-family coverage denominator.',
      ),
      status: EvidenceStatus.unavailable,
      direction: EvidenceDirection.unknown,
      strength: EvidenceStrength.veryWeak,
      score: 0,
      baseWeight: 0,
      dynamicWeight: 0,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'Expected Investor family',
      relativeValue: 'No contribution',
      explanation: 'Required coverage family is unavailable.',
      unavailableReason: 'Expected Investor family is unavailable.',
    );
  }

  double _directionalMassByFamily(
    Iterable<EvidenceResult> results,
    Set<EvidenceFamily> families,
  ) {
    final grouped = <EvidenceFamily, List<EvidenceResult>>{};

    for (final result in results) {
      if (!families.contains(result.definition.family) ||
          !result.isAvailable ||
          result.effectiveWeight <= 0) {
        continue;
      }

      grouped
          .putIfAbsent(result.definition.family, () => <EvidenceResult>[])
          .add(result);
    }

    return grouped.values.fold<double>(
      0,
      (sum, evidence) => sum + _familyDirectionalMass(evidence),
    );
  }

  double _familyDirectionalMass(List<EvidenceResult> evidence) {
    var totalWeight = 0.0;
    var signedStrength = 0.0;
    var cappedWeight = 0.0;

    for (final result in evidence) {
      final weight = result.effectiveWeight;
      totalWeight += weight;
      cappedWeight = math.max(cappedWeight, weight);

      final signedScore = switch (result.direction) {
        EvidenceDirection.bullish => result.score,
        EvidenceDirection.bearish => -result.score,
        EvidenceDirection.neutral || EvidenceDirection.unknown => 0,
      };

      signedStrength += signedScore * weight;
    }

    if (totalWeight <= 0 || cappedWeight <= 0) {
      return 0;
    }

    final directionScore = (signedStrength / totalWeight)
        .clamp(-100.0, 100.0)
        .toDouble();

    return cappedWeight * (directionScore.abs() / 100);
  }

  double _contextScale({
    required double coreDirectionalMass,
    required double contextDirectionalMass,
  }) {
    if (coreDirectionalMass <= 0 || contextDirectionalMass <= 0) {
      return 0;
    }

    final maxShare = InvestorRecommendationPolicy.maximumContextDirectionShare;
    final maximumContextMass =
        (maxShare / (1 - maxShare)) * coreDirectionalMass;

    return math.min(1.0, maximumContextMass / contextDirectionalMass);
  }

  ScoringResult _mergeDirectionWithCoreConfidence({
    required ScoringResult directionConsensus,
    required ScoringResult coreConsensus,
    required double coreCoverage,
  }) {
    final coreFamilies = {
      for (final contribution in coreConsensus.familyContributions)
        contribution.family: contribution,
    };

    final mergedFamilies = <EvidenceFamilyContribution>[];
    final mergedProviders = <EvidenceContribution>[];

    for (final directionFamily in directionConsensus.familyContributions) {
      final coreFamily = coreFamilies[directionFamily.family];
      final coreProviders = {
        for (final provider
            in coreFamily?.providers ?? const <EvidenceContribution>[])
          provider.providerName: provider,
      };

      final providers = <EvidenceContribution>[];

      for (final directionProvider in directionFamily.providers) {
        final coreProvider = coreProviders[directionProvider.providerName];

        final merged = EvidenceContribution(
          providerName: directionProvider.providerName,
          family: directionProvider.family,
          direction: directionProvider.direction,
          directionImpactPoints: directionProvider.directionImpactPoints,
          directionShareWithinFamily:
              directionProvider.directionShareWithinFamily,
          confidenceContributionPoints:
              coreProvider?.confidenceContributionPoints ?? 0,
          confidenceShare: coreProvider?.confidenceShare ?? 0,
        );

        providers.add(merged);
        mergedProviders.add(merged);
      }

      mergedFamilies.add(
        EvidenceFamilyContribution(
          family: directionFamily.family,
          direction: directionFamily.direction,
          directionImpactPoints: directionFamily.directionImpactPoints,
          directionShare: directionFamily.directionShare,
          confidenceContributionPoints:
              coreFamily?.confidenceContributionPoints ?? 0,
          confidenceShare: coreFamily?.confidenceShare ?? 0,
          providers: List.unmodifiable(providers),
        ),
      );
    }

    return directionConsensus.copyWith(
      score: coreConsensus.confidence,
      coverage: coreCoverage,
      familyCoverage: coreCoverage,
      agreement: coreConsensus.agreement,
      conflict: coreConsensus.conflict,
      baseEvidenceStrength: coreConsensus.baseEvidenceStrength,
      evidenceConfidence: coreConsensus.evidenceConfidence,
      familyContributions: List.unmodifiable(mergedFamilies),
      providerContributions: List.unmodifiable(mergedProviders),
      confidenceModifiers: coreConsensus.confidenceModifiers,
      warnings: List.unmodifiable({
        ...directionConsensus.warnings,
        ...coreConsensus.warnings,
      }),
    );
  }

  String _joinWithAnd(List<String> parts) {
    if (parts.isEmpty) {
      return 'required core evidence is unavailable';
    }
    if (parts.length == 1) {
      return parts.single;
    }
    if (parts.length == 2) {
      return '${parts[0]} and ${parts[1]}';
    }
    return '${parts.sublist(0, parts.length - 1).join(', ')}, and ${parts.last}';
  }
}
