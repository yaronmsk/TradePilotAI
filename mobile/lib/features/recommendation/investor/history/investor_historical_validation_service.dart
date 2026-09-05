import 'dart:math' as math;

import '../../history/historical_setup_validation.dart';
import '../../models/evidence_family.dart';
import '../../models/evidence_result.dart';
import '../engines/investor_recommendation_engine.dart';
import '../models/investor_historical_validation_case.dart';
import '../providers/investor_data_providers.dart';
import '../strategy/investor_recommendation_policy.dart';

class InvestorHistoricalValidationResult {
  InvestorHistoricalValidationResult({
    required this.validation,
    required List<InvestorHistoricalHorizonSummary> horizons,
  }) : horizons = List.unmodifiable(horizons);

  final HistoricalSetupValidation validation;
  final List<InvestorHistoricalHorizonSummary> horizons;

  InvestorHistoricalHorizonSummary? summaryFor(
    InvestorHistoricalHorizon horizon,
  ) {
    for (final summary in horizons) {
      if (summary.horizon == horizon) {
        return summary;
      }
    }
    return null;
  }
}

class InvestorHistoricalValidationService {
  const InvestorHistoricalValidationService({required this.provider});

  final InvestorHistoricalDataProvider provider;

  static const int minimumMatchedCases = 8;
  static const int minimumControlCases = 12;
  static const double minimumSimilarity = 0.75;
  static const double fullSimilarity = 0.88;
  static const double effectiveSampleFloor = 6;
  static const double effectiveSampleFull = 20;
  static const int minimumSetupSpacingDays = 90;
  static const double edgeFullScalePercentagePoints = 20;

  static const bool affectsDirection = false;
  static const bool affectsCoreBreadth = false;
  static const bool addsEvidenceVote = false;
  static const double maximumConfidenceImpactPoints =
      HistoricalSetupValidation.maximumConfidenceImpactPoints;

  Future<InvestorHistoricalValidationResult> validate({
    required String symbol,
    required InvestorRecommendationAnalysis analysis,
  }) async {
    final recommendation = analysis.recommendation;
    final analysisTime = recommendation.analysisTime;

    if (analysisTime == null) {
      return _unavailable(
        summary: 'Investor Historical Validation requires an analysis time.',
      );
    }

    final directionSign = _directionSign(recommendation.directionScore);
    if (directionSign == 0) {
      return InvestorHistoricalValidationResult(
        validation: HistoricalSetupValidation(
          status: HistoricalValidationStatus.neutralSignal,
          reliability: HistoricalValidationReliability.unavailable,
          verdict: HistoricalValidationVerdict.mixed,
          matchedCases: 0,
          effectiveSampleSize: 0,
          averageSimilarity: 0,
          alignedOutcomeRate: 0,
          controlAlignedOutcomeRate: 0,
          edgeVsControlPercentagePoints: 0,
          medianForwardReturnPercent: 0,
          medianDirectionalReturnPercent: 0,
          medianFavorableExcursionPercent: 0,
          medianAdverseExcursionPercent: 0,
          confidenceImpactPoints: 0,
          outcomeWindowLabel: '6m / 12m / 24m mature Investor outcomes',
          outcomeWindowShortLabel: '6m / 12m / 24m',
          summary:
              'The current Investor direction is too balanced for historical outcomes to strengthen either side.',
          isSynthetic: false,
          sourceLabel: '',
          topMatches: const [],
          symbol: symbol.toUpperCase(),
          stockProfileLabel: 'Investor core-family fingerprint',
          comparisonCases: 0,
        ),
        horizons: const [],
      );
    }

    final currentFingerprint = _currentFamilyFingerprint(analysis);
    if (currentFingerprint.length <
            InvestorRecommendationPolicy.minimumCoreFamiliesForAction ||
        !currentFingerprint.containsKey(EvidenceFamily.valuation)) {
      return _unavailable(
        summary:
            'Investor Historical Validation requires the same minimum core-family breadth and Valuation availability used by the recommendation policy.',
        symbol: symbol,
      );
    }

    final rawCases = await provider.loadValidationCases(
      symbol: symbol,
      asOf: analysisTime,
    );

    final safeCases = rawCases
        .where(
          (historicalCase) =>
              historicalCase.symbol.toUpperCase() == symbol.toUpperCase() &&
              historicalCase.isPointInTimeSafe &&
              historicalCase.setupTime.isBefore(analysisTime),
        )
        .toList(growable: false);

    final controls = safeCases
        .where(
          (historicalCase) =>
              _directionSign(historicalCase.directionScore) == directionSign &&
              historicalCase.coreFamilyCount >=
                  InvestorRecommendationPolicy.minimumCoreFamiliesForAction &&
              historicalCase.familySignedScores.containsKey(
                EvidenceFamily.valuation,
              ),
        )
        .toList(growable: false);

    final matchedWithSimilarity = <_MatchedInvestorCase>[];
    for (final historicalCase in controls) {
      final similarity = _similarity(
        currentFingerprint,
        historicalCase.familySignedScores,
      );

      if (similarity != null && similarity >= minimumSimilarity) {
        matchedWithSimilarity.add(
          _MatchedInvestorCase(
            historicalCase: historicalCase,
            similarity: similarity,
          ),
        );
      }
    }

    final matches = _deOverlap(matchedWithSimilarity);

    if (matches.length < minimumMatchedCases) {
      return _insufficient(
        symbol: symbol,
        cases: rawCases,
        matches: matches,
        controls: controls,
        summary:
            'Too few de-overlapped, sufficiently similar point-in-time Investor setups are available to influence confidence.',
      );
    }

    final summaries = <InvestorHistoricalHorizonSummary>[];

    for (final horizon in InvestorHistoricalHorizon.values) {
      final summary = _evaluateHorizon(
        horizon: horizon,
        matches: matches,
        controls: controls,
        analysisTime: analysisTime,
        directionSign: directionSign,
      );

      if (summary != null) {
        summaries.add(summary);
      }
    }

    final twelveMonth = summaries
        .where(
          (summary) =>
              summary.horizon == InvestorHistoricalHorizon.twelveMonths,
        )
        .toList(growable: false);

    if (summaries.length < 2 || twelveMonth.isEmpty) {
      return _insufficient(
        symbol: symbol,
        cases: rawCases,
        matches: matches,
        controls: controls,
        summaries: summaries,
        summary:
            'Investor Historical Validation requires at least two usable mature horizons, including 12-month evidence.',
      );
    }

    final totalPolicyWeight = summaries.fold<double>(
      0,
      (sum, summary) => sum + summary.horizon.policyWeight,
    );

    final combinedSupportScore =
        summaries.fold<double>(
          0,
          (sum, summary) =>
              sum +
              (summary.normalizedSupportScore * summary.horizon.policyWeight),
        ) /
        totalPolicyWeight;

    final combinedReliability =
        summaries.fold<double>(
          0,
          (sum, summary) =>
              sum + (summary.reliability * summary.horizon.policyWeight),
        ) /
        totalPolicyWeight;

    final confidenceImpact =
        ((combinedSupportScore / 100) *
                HistoricalSetupValidation.maximumConfidenceImpactPoints)
            .clamp(
              -HistoricalSetupValidation.maximumConfidenceImpactPoints,
              HistoricalSetupValidation.maximumConfidenceImpactPoints,
            )
            .toDouble();

    final verdict = confidenceImpact >= 1.25
        ? HistoricalValidationVerdict.supports
        : confidenceImpact <= -1.25
        ? HistoricalValidationVerdict.opposes
        : HistoricalValidationVerdict.mixed;

    final reliability = _reliabilityLabel(combinedReliability);

    final twelve = twelveMonth.single;

    final validation = HistoricalSetupValidation(
      status: HistoricalValidationStatus.available,
      reliability: reliability,
      verdict: verdict,
      matchedCases: matches.length,
      effectiveSampleSize: twelve.effectiveSampleSize,
      averageSimilarity: twelve.averageSimilarity,
      alignedOutcomeRate: twelve.matchedAlignedRate,
      controlAlignedOutcomeRate: twelve.controlAlignedRate,
      edgeVsControlPercentagePoints: twelve.absoluteEdgePercentagePoints,
      medianForwardReturnPercent:
          twelve.medianDirectionalReturnPercent * directionSign,
      medianDirectionalReturnPercent: twelve.medianDirectionalReturnPercent,
      medianFavorableExcursionPercent: 0,
      medianAdverseExcursionPercent: 0,
      confidenceImpactPoints: confidenceImpact,
      outcomeWindowLabel: '6m / 12m / 24m mature Investor outcomes',
      outcomeWindowShortLabel: '6m / 12m / 24m',
      summary: _summary(
        verdict: verdict,
        impact: confidenceImpact,
        usableHorizons: summaries.length,
      ),
      isSynthetic: rawCases.any((historicalCase) => historicalCase.isSynthetic),
      sourceLabel: _sourceLabel(rawCases),
      topMatches: const [],
      symbol: symbol.toUpperCase(),
      stockProfileLabel: 'Investor core-family fingerprint',
      comparisonCases: twelve.controlCases,
    );

    return InvestorHistoricalValidationResult(
      validation: validation,
      horizons: summaries,
    );
  }

  InvestorHistoricalHorizonSummary? _evaluateHorizon({
    required InvestorHistoricalHorizon horizon,
    required List<_MatchedInvestorCase> matches,
    required List<InvestorHistoricalValidationCase> controls,
    required DateTime analysisTime,
    required double directionSign,
  }) {
    final matureMatches = matches
        .where(
          (match) =>
              match.historicalCase.matureOutcome(horizon, analysisTime) != null,
        )
        .toList(growable: false);

    final matureControls = controls
        .where(
          (historicalCase) =>
              historicalCase.matureOutcome(horizon, analysisTime) != null,
        )
        .toList(growable: false);

    if (matureMatches.length < minimumMatchedCases ||
        matureControls.length < minimumControlCases) {
      return null;
    }

    final effectiveSampleSize = _effectiveSampleSize(matureMatches);
    final averageSimilarity = _weightedAverageSimilarity(matureMatches);

    final sampleFactor =
        ((effectiveSampleSize - effectiveSampleFloor) /
                (effectiveSampleFull - effectiveSampleFloor))
            .clamp(0.0, 1.0)
            .toDouble();

    final similarityFactor =
        ((averageSimilarity - minimumSimilarity) /
                (fullSimilarity - minimumSimilarity))
            .clamp(0.0, 1.0)
            .toDouble();

    final reliability = math.min(sampleFactor, similarityFactor);

    final matchedAlignedRate = _weightedAlignedRate(
      matureMatches,
      horizon,
      analysisTime,
      directionSign,
      relative: false,
    );
    final controlAlignedRate = _controlAlignedRate(
      matureControls,
      horizon,
      analysisTime,
      directionSign,
      relative: false,
    );

    final matchedRelativeAlignedRate = _weightedAlignedRate(
      matureMatches,
      horizon,
      analysisTime,
      directionSign,
      relative: true,
    );
    final controlRelativeAlignedRate = _controlAlignedRate(
      matureControls,
      horizon,
      analysisTime,
      directionSign,
      relative: true,
    );

    final absoluteEdge = (matchedAlignedRate - controlAlignedRate) * 100;
    final relativeEdge =
        (matchedRelativeAlignedRate - controlRelativeAlignedRate) * 100;

    final meanEdge = (absoluteEdge + relativeEdge) / 2;
    final normalizedSupport =
        ((meanEdge / edgeFullScalePercentagePoints) * 100)
            .clamp(-100.0, 100.0)
            .toDouble() *
        reliability;

    final medianDirectionalReturn = _weightedMedian(matureMatches, (match) {
      final outcome = match.historicalCase.matureOutcome(
        horizon,
        analysisTime,
      )!;
      return outcome.stockReturnPercent * directionSign;
    });

    final medianDirectionalExcessReturn = _weightedMedian(matureMatches, (
      match,
    ) {
      final outcome = match.historicalCase.matureOutcome(
        horizon,
        analysisTime,
      )!;
      return (outcome.stockReturnPercent - outcome.benchmarkReturnPercent) *
          directionSign;
    });

    return InvestorHistoricalHorizonSummary(
      horizon: horizon,
      matchedCases: matureMatches.length,
      controlCases: matureControls.length,
      effectiveSampleSize: effectiveSampleSize,
      averageSimilarity: averageSimilarity,
      matchedAlignedRate: matchedAlignedRate,
      controlAlignedRate: controlAlignedRate,
      matchedRelativeAlignedRate: matchedRelativeAlignedRate,
      controlRelativeAlignedRate: controlRelativeAlignedRate,
      absoluteEdgePercentagePoints: absoluteEdge,
      relativeEdgePercentagePoints: relativeEdge,
      reliability: reliability,
      normalizedSupportScore: normalizedSupport,
      medianDirectionalReturnPercent: medianDirectionalReturn,
      medianDirectionalExcessReturnPercent: medianDirectionalExcessReturn,
    );
  }

  Map<EvidenceFamily, double> _currentFamilyFingerprint(
    InvestorRecommendationAnalysis analysis,
  ) {
    final grouped = <EvidenceFamily, List<EvidenceResult>>{};

    for (final result
        in analysis.recommendation.evidenceReport.availableResults) {
      if (!InvestorRecommendationPolicy.isBreadthEligibleCore(
        result.definition.family,
      )) {
        continue;
      }

      grouped
          .putIfAbsent(result.definition.family, () => <EvidenceResult>[])
          .add(result);
    }

    return {
      for (final entry in grouped.entries)
        entry.key: _familySignedScore(entry.value),
    };
  }

  double _familySignedScore(List<EvidenceResult> evidence) {
    var weightedSigned = 0.0;
    var totalWeight = 0.0;

    for (final result in evidence) {
      final weight = result.effectiveWeight;
      if (weight <= 0) {
        continue;
      }

      final signedScore = switch (result.direction) {
        EvidenceDirection.bullish => result.score,
        EvidenceDirection.bearish => -result.score,
        EvidenceDirection.neutral || EvidenceDirection.unknown => 0,
      };

      weightedSigned += signedScore * weight;
      totalWeight += weight;
    }

    return totalWeight <= 0
        ? 0
        : (weightedSigned / totalWeight).clamp(-100.0, 100.0).toDouble();
  }

  double? _similarity(
    Map<EvidenceFamily, double> current,
    Map<EvidenceFamily, double> candidate,
  ) {
    final commonFamilies = InvestorRecommendationPolicy
        .breadthEligibleCoreFamilies
        .where(
          (family) =>
              current.containsKey(family) && candidate.containsKey(family),
        )
        .toList(growable: false);

    if (commonFamilies.length <
            InvestorRecommendationPolicy.minimumCoreFamiliesForAction ||
        !commonFamilies.contains(EvidenceFamily.valuation)) {
      return null;
    }

    final familySimilarity =
        commonFamilies.fold<double>(
          0,
          (sum, family) =>
              sum +
              (1 - ((current[family]! - candidate[family]!).abs() / 200)).clamp(
                0.0,
                1.0,
              ),
        ) /
        commonFamilies.length;

    final coverageFactor =
        commonFamilies.length /
        InvestorRecommendationPolicy.expectedCoreFamilyCount;

    return (familySimilarity * (0.85 + (0.15 * coverageFactor)))
        .clamp(0.0, 1.0)
        .toDouble();
  }

  List<_MatchedInvestorCase> _deOverlap(List<_MatchedInvestorCase> matches) {
    final sorted = [...matches]
      ..sort(
        (a, b) =>
            a.historicalCase.setupTime.compareTo(b.historicalCase.setupTime),
      );

    final selected = <_MatchedInvestorCase>[];

    for (final match in sorted) {
      if (selected.isEmpty) {
        selected.add(match);
        continue;
      }

      final previous = selected.last;
      final spacing = match.historicalCase.setupTime
          .difference(previous.historicalCase.setupTime)
          .inDays;

      if (spacing >= minimumSetupSpacingDays) {
        selected.add(match);
      } else if (match.similarity > previous.similarity) {
        selected[selected.length - 1] = match;
      }
    }

    return List.unmodifiable(selected);
  }

  double _weightedAlignedRate(
    List<_MatchedInvestorCase> matches,
    InvestorHistoricalHorizon horizon,
    DateTime analysisTime,
    double directionSign, {
    required bool relative,
  }) {
    var alignedWeight = 0.0;
    var totalWeight = 0.0;

    for (final match in matches) {
      final outcome = match.historicalCase.matureOutcome(
        horizon,
        analysisTime,
      )!;
      final rawReturn = relative
          ? outcome.stockReturnPercent - outcome.benchmarkReturnPercent
          : outcome.stockReturnPercent;
      final weight = match.weight;

      totalWeight += weight;
      if ((rawReturn * directionSign) > 0) {
        alignedWeight += weight;
      }
    }

    return totalWeight <= 0 ? 0 : alignedWeight / totalWeight;
  }

  double _controlAlignedRate(
    List<InvestorHistoricalValidationCase> controls,
    InvestorHistoricalHorizon horizon,
    DateTime analysisTime,
    double directionSign, {
    required bool relative,
  }) {
    if (controls.isEmpty) {
      return 0.5;
    }

    var aligned = 0;

    for (final historicalCase in controls) {
      final outcome = historicalCase.matureOutcome(horizon, analysisTime)!;
      final rawReturn = relative
          ? outcome.stockReturnPercent - outcome.benchmarkReturnPercent
          : outcome.stockReturnPercent;

      if ((rawReturn * directionSign) > 0) {
        aligned += 1;
      }
    }

    return aligned / controls.length;
  }

  double _effectiveSampleSize(List<_MatchedInvestorCase> matches) {
    final sumWeights = matches.fold<double>(
      0,
      (sum, match) => sum + match.weight,
    );
    final sumSquaredWeights = matches.fold<double>(
      0,
      (sum, match) => sum + (match.weight * match.weight),
    );

    if (sumSquaredWeights <= 0) {
      return 0;
    }

    return (sumWeights * sumWeights) / sumSquaredWeights;
  }

  double _weightedAverageSimilarity(List<_MatchedInvestorCase> matches) {
    final totalWeight = matches.fold<double>(
      0,
      (sum, match) => sum + match.weight,
    );

    if (totalWeight <= 0) {
      return 0;
    }

    return matches.fold<double>(
          0,
          (sum, match) => sum + (match.similarity * match.weight),
        ) /
        totalWeight;
  }

  double _weightedMedian(
    List<_MatchedInvestorCase> matches,
    double Function(_MatchedInvestorCase match) valueOf,
  ) {
    final sorted = [...matches]
      ..sort((a, b) => valueOf(a).compareTo(valueOf(b)));

    final totalWeight = sorted.fold<double>(
      0,
      (sum, match) => sum + match.weight,
    );
    final midpoint = totalWeight / 2;

    var running = 0.0;
    for (final match in sorted) {
      running += match.weight;
      if (running >= midpoint) {
        return valueOf(match);
      }
    }

    return valueOf(sorted.last);
  }

  HistoricalValidationReliability _reliabilityLabel(double reliability) {
    if (reliability <= 0) {
      return HistoricalValidationReliability.unavailable;
    }
    if (reliability < 0.40) {
      return HistoricalValidationReliability.low;
    }
    if (reliability < 0.75) {
      return HistoricalValidationReliability.moderate;
    }
    return HistoricalValidationReliability.high;
  }

  String _summary({
    required HistoricalValidationVerdict verdict,
    required double impact,
    required int usableHorizons,
  }) {
    final signedImpact = '${impact > 0 ? '+' : ''}${impact.toStringAsFixed(1)}';

    return switch (verdict) {
      HistoricalValidationVerdict.supports =>
        'Similar point-in-time Investor setups historically showed stronger absolute and benchmark-relative follow-through than the stock’s broader same-direction baseline across $usableHorizons mature horizons. Confidence impact: $signedImpact points.',
      HistoricalValidationVerdict.opposes =>
        'Similar point-in-time Investor setups historically showed weaker absolute and benchmark-relative follow-through than the stock’s broader same-direction baseline across $usableHorizons mature horizons. Confidence impact: $signedImpact points.',
      HistoricalValidationVerdict.mixed =>
        'Historical Investor follow-through is close to the stock’s broader same-direction baseline across $usableHorizons mature horizons. Confidence impact: $signedImpact points.',
      HistoricalValidationVerdict.unavailable =>
        'Investor Historical Validation is not available.',
    };
  }

  InvestorHistoricalValidationResult _unavailable({
    required String summary,
    String symbol = '',
  }) {
    return InvestorHistoricalValidationResult(
      validation: HistoricalSetupValidation.unavailable(summary: summary),
      horizons: const [],
    );
  }

  InvestorHistoricalValidationResult _insufficient({
    required String symbol,
    required List<InvestorHistoricalValidationCase> cases,
    required List<_MatchedInvestorCase> matches,
    required List<InvestorHistoricalValidationCase> controls,
    List<InvestorHistoricalHorizonSummary> summaries = const [],
    required String summary,
  }) {
    final averageSimilarity = matches.isEmpty
        ? 0.0
        : _weightedAverageSimilarity(matches);

    return InvestorHistoricalValidationResult(
      validation: HistoricalSetupValidation(
        status: HistoricalValidationStatus.insufficientData,
        reliability: HistoricalValidationReliability.unavailable,
        verdict: HistoricalValidationVerdict.unavailable,
        matchedCases: matches.length,
        effectiveSampleSize: matches.isEmpty
            ? 0
            : _effectiveSampleSize(matches),
        averageSimilarity: averageSimilarity,
        alignedOutcomeRate: 0,
        controlAlignedOutcomeRate: 0,
        edgeVsControlPercentagePoints: 0,
        medianForwardReturnPercent: 0,
        medianDirectionalReturnPercent: 0,
        medianFavorableExcursionPercent: 0,
        medianAdverseExcursionPercent: 0,
        confidenceImpactPoints: 0,
        outcomeWindowLabel: '6m / 12m / 24m mature Investor outcomes',
        outcomeWindowShortLabel: '6m / 12m / 24m',
        summary: summary,
        isSynthetic: cases.any((historicalCase) => historicalCase.isSynthetic),
        sourceLabel: _sourceLabel(cases),
        topMatches: const [],
        symbol: symbol.toUpperCase(),
        stockProfileLabel: 'Investor core-family fingerprint',
        comparisonCases: controls.length,
      ),
      horizons: summaries,
    );
  }

  String _sourceLabel(List<InvestorHistoricalValidationCase> cases) {
    final labels = cases
        .map((historicalCase) => historicalCase.sourceLabel)
        .where((label) => label.isNotEmpty)
        .toSet();

    if (labels.isEmpty) {
      return '';
    }
    if (labels.length == 1) {
      return labels.single;
    }
    return 'Multiple point-in-time Investor historical sources';
  }

  double _directionSign(double directionScore) {
    if (directionScore > InvestorRecommendationPolicy.holdDirectionThreshold) {
      return 1;
    }
    if (directionScore < -InvestorRecommendationPolicy.holdDirectionThreshold) {
      return -1;
    }
    return 0;
  }
}

class _MatchedInvestorCase {
  const _MatchedInvestorCase({
    required this.historicalCase,
    required this.similarity,
  });

  final InvestorHistoricalValidationCase historicalCase;
  final double similarity;

  double get weight => similarity * similarity;
}
