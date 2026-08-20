import '../context/recommendation_analysis_context.dart';
import '../context/stock_behavior_profile.dart';
import '../models/recommendation.dart';
import '../models/strategy_summary.dart';
import 'historical_comparison_selector.dart';
import 'historical_setup_case.dart';
import 'historical_setup_match.dart';
import 'historical_setup_matcher.dart';
import 'historical_setup_provider.dart';
import 'historical_setup_validation.dart';
import 'historical_validation_scoring_policy.dart';
import 'setup_fingerprint_builder.dart';

class HistoricalSetupValidationService {
  const HistoricalSetupValidationService({
    required this.provider,
    this.fingerprintBuilder = const SetupFingerprintBuilder(),
    this.matcher = const HistoricalSetupMatcher(),
    this.comparisonSelector = const HistoricalComparisonSelector(),
    this.scoringPolicy = const HistoricalValidationScoringPolicy(),
    this.maximumConfidenceImpact = 8,
  });

  final HistoricalSetupProvider provider;
  final SetupFingerprintBuilder fingerprintBuilder;
  final HistoricalSetupMatcher matcher;
  final HistoricalComparisonSelector comparisonSelector;
  final HistoricalValidationScoringPolicy scoringPolicy;
  final double maximumConfidenceImpact;

  Future<HistoricalSetupValidation> validate({
    required String symbol,
    required StrategyType strategy,
    required Recommendation recommendation,
    required StockBehaviorProfile stockBehaviorProfile,
    RecommendationAnalysisContext? analysisContext,
  }) async {
    final fingerprint = fingerprintBuilder.build(
      recommendation: recommendation,
      strategy: strategy,
      stockBehaviorProfile: stockBehaviorProfile,
      analysisContext: analysisContext,
    );

    final horizon = _outcomeHorizonFor(
      strategy: strategy,
      primaryTimeframe: recommendation.timeframe,
    );

    final dataset = await provider.loadDataset(
      symbol: symbol,
      strategy: strategy,
      primaryTimeframe: recommendation.timeframe,
      currentFingerprint: fingerprint,
      forwardBars: horizon.bars,
    );

    final matches = matcher.match(
      currentSymbol: symbol,
      current: fingerprint,
      candidates: dataset.cases,
    );

    final comparisonObservations = comparisonSelector.select(
      currentSymbol: symbol,
      current: fingerprint,
      observations: dataset.comparisonObservations,
    );

    final directionSign = _directionSign(recommendation.directionScore);
    final stockProfileLabel = _stockProfileLabel(
      stockBehaviorProfile.behaviorType,
    );

    if (matches.length < 8) {
      return HistoricalSetupValidation(
        status: HistoricalValidationStatus.insufficientData,
        reliability: HistoricalValidationReliability.unavailable,
        verdict: HistoricalValidationVerdict.unavailable,
        matchedCases: matches.length,
        effectiveSampleSize: _effectiveSampleSize(matches),
        averageSimilarity: _weightedAverageSimilarity(matches),
        alignedOutcomeRate: 0,
        controlAlignedOutcomeRate: 0,
        edgeVsControlPercentagePoints: 0,
        medianForwardReturnPercent: _weightedMedian(
          matches,
          (match) => match.setupCase.forwardReturnPercent,
        ),
        medianDirectionalReturnPercent: 0,
        medianFavorableExcursionPercent: _weightedMedian(
          matches,
          (match) => match.setupCase.maxFavorableExcursionPercent,
        ),
        medianAdverseExcursionPercent: _weightedMedian(
          matches,
          (match) => match.setupCase.maxAdverseExcursionPercent,
        ),
        confidenceImpactPoints: 0,
        outcomeWindowLabel: horizon.label,
        summary:
            'Too few sufficiently similar historical cases are available to influence confidence.',
        isSynthetic: dataset.isSynthetic,
        sourceLabel: dataset.sourceLabel,
        topMatches: List.unmodifiable(matches.take(5)),
        symbol: symbol.toUpperCase(),
        stockProfileLabel: stockProfileLabel,
        comparisonCases: comparisonObservations.length,
        outcomeWindowShortLabel: horizon.shortLabel,
      );
    }

    final effectiveSampleSize = _effectiveSampleSize(matches);
    final averageSimilarity = _weightedAverageSimilarity(matches);
    final reliability = _reliabilityFor(
      effectiveSampleSize: effectiveSampleSize,
      averageSimilarity: averageSimilarity,
    );

    if (directionSign == 0) {
      return HistoricalSetupValidation(
        status: HistoricalValidationStatus.neutralSignal,
        reliability: reliability,
        verdict: HistoricalValidationVerdict.mixed,
        matchedCases: matches.length,
        effectiveSampleSize: effectiveSampleSize,
        averageSimilarity: averageSimilarity,
        alignedOutcomeRate: 0,
        controlAlignedOutcomeRate: 0,
        edgeVsControlPercentagePoints: 0,
        medianForwardReturnPercent: _weightedMedian(
          matches,
          (match) => match.setupCase.forwardReturnPercent,
        ),
        medianDirectionalReturnPercent: 0,
        medianFavorableExcursionPercent: _weightedMedian(
          matches,
          (match) => match.setupCase.maxFavorableExcursionPercent,
        ),
        medianAdverseExcursionPercent: _weightedMedian(
          matches,
          (match) => match.setupCase.maxAdverseExcursionPercent,
        ),
        confidenceImpactPoints: 0,
        outcomeWindowLabel: horizon.label,
        summary:
            'The current signal is too balanced for historical outcomes to strengthen either direction.',
        isSynthetic: dataset.isSynthetic,
        sourceLabel: dataset.sourceLabel,
        topMatches: List.unmodifiable(matches.take(5)),
        symbol: symbol.toUpperCase(),
        stockProfileLabel: stockProfileLabel,
        comparisonCases: comparisonObservations.length,
        outcomeWindowShortLabel: horizon.shortLabel,
      );
    }

    final alignedOutcomeRate = _weightedAlignedRate(matches, directionSign);
    if (comparisonObservations.length < 12) {
      return HistoricalSetupValidation(
        status: HistoricalValidationStatus.insufficientData,
        reliability: HistoricalValidationReliability.unavailable,
        verdict: HistoricalValidationVerdict.unavailable,
        matchedCases: matches.length,
        effectiveSampleSize: effectiveSampleSize,
        averageSimilarity: averageSimilarity,
        alignedOutcomeRate: alignedOutcomeRate,
        controlAlignedOutcomeRate: 0,
        edgeVsControlPercentagePoints: 0,
        medianForwardReturnPercent: _weightedMedian(
          matches,
          (match) => match.setupCase.forwardReturnPercent,
        ),
        medianDirectionalReturnPercent: 0,
        medianFavorableExcursionPercent: _weightedMedian(
          matches,
          (match) => match.setupCase.maxFavorableExcursionPercent,
        ),
        medianAdverseExcursionPercent: _weightedMedian(
          matches,
          (match) => match.setupCase.maxAdverseExcursionPercent,
        ),
        confidenceImpactPoints: 0,
        outcomeWindowLabel: horizon.label,
        summary:
            'Too few context-matched ${symbol.toUpperCase()} observations are available to build a reliable historical comparison baseline.',
        isSynthetic: dataset.isSynthetic,
        sourceLabel: dataset.sourceLabel,
        topMatches: List.unmodifiable(matches.take(5)),
        symbol: symbol.toUpperCase(),
        stockProfileLabel: stockProfileLabel,
        comparisonCases: comparisonObservations.length,
        outcomeWindowShortLabel: horizon.shortLabel,
      );
    }

    final controlAlignedOutcomeRate = _comparisonAlignedRate(
      comparisonObservations,
      directionSign,
    );
    final edgeVsControl =
        (alignedOutcomeRate - controlAlignedOutcomeRate) * 100;

    final medianForwardReturn = _weightedMedian(
      matches,
      (match) => match.setupCase.forwardReturnPercent,
    );
    final medianDirectionalReturn = medianForwardReturn * directionSign;
    final medianFavorableExcursion = _weightedMedian(
      matches,
      (match) => directionSign > 0
          ? match.setupCase.maxFavorableExcursionPercent
          : -match.setupCase.maxAdverseExcursionPercent,
    );
    final medianAdverseExcursion = _weightedMedian(
      matches,
      (match) => directionSign > 0
          ? match.setupCase.maxAdverseExcursionPercent
          : -match.setupCase.maxFavorableExcursionPercent,
    );

    final scoringBreakdown = scoringPolicy.evaluate(
      alignedOutcomeRate: alignedOutcomeRate,
      controlAlignedOutcomeRate: controlAlignedOutcomeRate,
      medianDirectionalReturnPercent: medianDirectionalReturn,
      medianFavorableExcursionPercent: medianFavorableExcursion,
      medianAdverseExcursionPercent: medianAdverseExcursion,
      effectiveSampleSize: effectiveSampleSize,
      averageSimilarity: averageSimilarity,
      stockBehaviorProfile: stockBehaviorProfile,
    );

    final confidenceImpact = scoringPolicy.confidenceImpact(
      breakdown: scoringBreakdown,
      maximumConfidenceImpact: maximumConfidenceImpact,
    );

    final verdict = confidenceImpact >= 1.25
        ? HistoricalValidationVerdict.supports
        : confidenceImpact <= -1.25
        ? HistoricalValidationVerdict.opposes
        : HistoricalValidationVerdict.mixed;

    return HistoricalSetupValidation(
      status: HistoricalValidationStatus.available,
      reliability: reliability,
      verdict: verdict,
      matchedCases: matches.length,
      effectiveSampleSize: effectiveSampleSize,
      averageSimilarity: averageSimilarity,
      alignedOutcomeRate: alignedOutcomeRate,
      controlAlignedOutcomeRate: controlAlignedOutcomeRate,
      edgeVsControlPercentagePoints: edgeVsControl,
      medianForwardReturnPercent: medianForwardReturn,
      medianDirectionalReturnPercent: medianDirectionalReturn,
      medianFavorableExcursionPercent: medianFavorableExcursion,
      medianAdverseExcursionPercent: medianAdverseExcursion,
      confidenceImpactPoints: confidenceImpact,
      outcomeWindowLabel: horizon.label,
      summary: _summaryFor(
        verdict: verdict,
        alignedOutcomeRate: alignedOutcomeRate,
        controlAlignedOutcomeRate: controlAlignedOutcomeRate,
      ),
      isSynthetic: dataset.isSynthetic,
      sourceLabel: dataset.sourceLabel,
      topMatches: List.unmodifiable(matches.take(5)),
      symbol: symbol.toUpperCase(),
      stockProfileLabel: stockProfileLabel,
      comparisonCases: comparisonObservations.length,
      outcomeWindowShortLabel: horizon.shortLabel,
      scoringBreakdown: scoringBreakdown,
    );
  }

  double _weightedAlignedRate(
    List<HistoricalSetupMatch> matches,
    double directionSign,
  ) {
    double alignedWeight = 0;
    double totalWeight = 0;

    for (final match in matches) {
      totalWeight += match.weight;
      if ((match.setupCase.forwardReturnPercent * directionSign) > 0) {
        alignedWeight += match.weight;
      }
    }

    return totalWeight == 0 ? 0 : (alignedWeight / totalWeight).clamp(0.0, 1.0);
  }

  double _comparisonAlignedRate(
    List<HistoricalComparisonObservation> observations,
    double directionSign,
  ) {
    if (observations.isEmpty) {
      return 0.5;
    }

    final aligned = observations
        .where(
          (observation) =>
              (observation.forwardReturnPercent * directionSign) > 0,
        )
        .length;
    return aligned / observations.length;
  }

  double _effectiveSampleSize(List<HistoricalSetupMatch> matches) {
    if (matches.isEmpty) {
      return 0;
    }

    final sumWeights = matches.fold<double>(
      0,
      (sum, match) => sum + match.weight,
    );
    final sumSquaredWeights = matches.fold<double>(
      0,
      (sum, match) => sum + (match.weight * match.weight),
    );

    if (sumSquaredWeights == 0) {
      return 0;
    }

    return (sumWeights * sumWeights) / sumSquaredWeights;
  }

  double _weightedAverageSimilarity(List<HistoricalSetupMatch> matches) {
    if (matches.isEmpty) {
      return 0;
    }

    final totalWeight = matches.fold<double>(
      0,
      (sum, match) => sum + match.weight,
    );

    if (totalWeight == 0) {
      return 0;
    }

    return matches.fold<double>(
          0,
          (sum, match) => sum + (match.similarity * match.weight),
        ) /
        totalWeight;
  }

  double _weightedMedian(
    List<HistoricalSetupMatch> matches,
    double Function(HistoricalSetupMatch match) valueOf,
  ) {
    if (matches.isEmpty) {
      return 0;
    }

    final sorted = [...matches]
      ..sort((a, b) => valueOf(a).compareTo(valueOf(b)));
    final totalWeight = sorted.fold<double>(
      0,
      (sum, match) => sum + match.weight,
    );
    final midpoint = totalWeight / 2;
    double runningWeight = 0;

    for (final match in sorted) {
      runningWeight += match.weight;
      if (runningWeight >= midpoint) {
        return valueOf(match);
      }
    }

    return valueOf(sorted.last);
  }

  HistoricalValidationReliability _reliabilityFor({
    required double effectiveSampleSize,
    required double averageSimilarity,
  }) {
    final appliedReliability = scoringPolicy.appliedReliabilityFor(
      effectiveSampleSize: effectiveSampleSize,
      averageSimilarity: averageSimilarity,
    );

    if (appliedReliability <= 0) {
      return HistoricalValidationReliability.unavailable;
    }
    if (appliedReliability < 0.40) {
      return HistoricalValidationReliability.low;
    }
    if (appliedReliability < 0.75) {
      return HistoricalValidationReliability.moderate;
    }
    return HistoricalValidationReliability.high;
  }

  String _summaryFor({
    required HistoricalValidationVerdict verdict,
    required double alignedOutcomeRate,
    required double controlAlignedOutcomeRate,
  }) {
    final aligned = (alignedOutcomeRate * 100).toStringAsFixed(0);
    final baseline = (controlAlignedOutcomeRate * 100).toStringAsFixed(0);
    final difference = ((alignedOutcomeRate - controlAlignedOutcomeRate) * 100)
        .toStringAsFixed(0);
    final signedDifference = difference.startsWith('-')
        ? difference
        : '+$difference';

    return switch (verdict) {
      HistoricalValidationVerdict.supports =>
        'Similar historical setups show stronger follow-through than this stock usually showed under comparable surrounding conditions ($aligned% vs $baseline%, $signedDifference% points).',
      HistoricalValidationVerdict.opposes =>
        'Similar historical setups show weaker follow-through than this stock usually showed under comparable surrounding conditions ($aligned% vs $baseline%, $signedDifference% points).',
      HistoricalValidationVerdict.mixed =>
        'Historical setup follow-through is close to this stock\'s usual behavior under comparable surrounding conditions ($aligned% vs $baseline%).',
      HistoricalValidationVerdict.unavailable =>
        'Historical validation is not available.',
    };
  }

  String _stockProfileLabel(StockBehaviorType type) {
    return switch (type) {
      StockBehaviorType.steady => 'Steady',
      StockBehaviorType.balanced => 'Balanced',
      StockBehaviorType.volatile => 'Volatile',
      StockBehaviorType.unknown => 'Unknown',
    };
  }

  double _directionSign(double directionScore) {
    if (directionScore > 20) {
      return 1;
    }
    if (directionScore < -20) {
      return -1;
    }
    return 0;
  }

  _OutcomeHorizon _outcomeHorizonFor({
    required StrategyType strategy,
    required String primaryTimeframe,
  }) {
    if (strategy == StrategyType.trader) {
      return switch (primaryTimeframe) {
        '1m' => const _OutcomeHorizon(
          30,
          'Next 30 × 1m bars (~30 minutes)',
          '~30 minutes',
        ),
        '5m' => const _OutcomeHorizon(
          24,
          'Next 24 × 5m bars (~2 hours)',
          '~2 hours',
        ),
        '15m' => const _OutcomeHorizon(
          16,
          'Next 16 × 15m bars (~4 hours)',
          '~4 hours',
        ),
        '30m' => const _OutcomeHorizon(
          12,
          'Next 12 × 30m bars (~6 hours)',
          '~6 hours',
        ),
        '1h' => const _OutcomeHorizon(
          8,
          'Next 8 × 1h bars (~8 hours)',
          '~8 hours',
        ),
        _ => const _OutcomeHorizon(
          12,
          'Next 12 primary bars',
          'the following 12 bars',
        ),
      };
    }

    if (strategy == StrategyType.swing) {
      return switch (primaryTimeframe) {
        '4h' => const _OutcomeHorizon(
          15,
          'Next 15 × 4h bars',
          'the following 15 × 4h bars',
        ),
        '1d' => const _OutcomeHorizon(
          10,
          'Next 10 trading-day bars',
          'the following 10 trading days',
        ),
        _ => const _OutcomeHorizon(
          10,
          'Next 10 primary bars',
          'the following 10 bars',
        ),
      };
    }

    return switch (primaryTimeframe) {
      '1d' => const _OutcomeHorizon(
        60,
        'Next 60 trading-day bars',
        'the following 60 trading days',
      ),
      '1w' => const _OutcomeHorizon(
        12,
        'Next 12 weekly bars',
        'the following 12 weeks',
      ),
      _ => const _OutcomeHorizon(
        12,
        'Next 12 primary bars',
        'the following 12 bars',
      ),
    };
  }
}

class _OutcomeHorizon {
  const _OutcomeHorizon(this.bars, this.label, this.shortLabel);

  final int bars;
  final String label;
  final String shortLabel;
}
