import 'dart:math' as math;

import '../../models/evidence_definition.dart';
import '../../models/evidence_family.dart';
import '../../models/evidence_result.dart';
import '../models/investor_data_contracts.dart';
import '../models/investor_metric_assessment.dart';
import '../models/investor_metric_explainability_catalog.dart';
import 'investor_evidence_math.dart';
import 'investor_evidence_provider.dart';

class InvestorMacroSensitivityEvidenceProvider
    implements InvestorEvidenceProvider {
  const InvestorMacroSensitivityEvidenceProvider();

  /// Historical observations used to fit sensitivity. The final observation is
  /// reserved as the current context move and is never used to fit itself.
  static const int minimumHistoricalObservations = 52;

  static const double minimumAbsoluteStockCorrelation = 0.35;
  static const double minimumHalfSampleCorrelation = 0.20;
  static const double maximumFactorCollinearity = 0.75;

  static const bool eligibleForCoreBreadth = false;
  static const bool canCreateRecommendation = false;
  static const bool marketImpliedVolatilityDirectional = false;
  static const bool directionCapDeferredToBatch8 = true;

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    family: EvidenceFamily.marketContext,
    name: 'Investor Macro & Market Sensitivity',
    description:
        'Measures whether current market, sector and macro moves align with stable stock-specific historical sensitivities.',
    whyItMatters:
        'Market, sector, rates, financial conditions and currency moves can affect companies differently. Stock-specific evidence is safer than assuming one universal macro rule.',
    calculation:
        'Batch 6 fits each sensitivity from prior aligned weekly observations only. A factor needs at least 52 historical observations, material full-sample correlation, matching-sign half-sample correlations and a non-collinear signal. The current factor move is then standardized against that prior history and combined with the validated stock sensitivity.',
    explainability: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'A contextual Investor assessment of whether the stock has historically responded in a stable way to selected market, sector and macro factors and whether the latest factor move is supportive or opposing under that measured relationship.',
      calculation:
          'Validated historical stock/factor correlations are multiplied by the latest standardized factor move. Highly collinear factors are de-duplicated so one common theme cannot create several votes. Market-implied volatility is excluded from direction.',
      whyItMatters:
          'The same market, rate, dollar or financial-condition move can help one company and hurt another depending on financing, demand, geographic exposure and business model.',
      supportiveInterpretation:
          'A current factor move that historically aligned positively with this stock can support contextual direction.',
      opposingInterpretation:
          'A current factor move that historically aligned negatively with this stock can oppose contextual direction.',
      neutralInterpretation:
          'Weak, unstable, collinear or small current factor signals remain neutral or unavailable.',
      recommendationImpact:
          'Macro & Market Sensitivity is contextual only. It cannot satisfy core-fundamental breadth or create an Investor BUY/SELL. Exact directional context caps are deferred to Batch 8.',
      limitations:
          'Correlation is not causation and historical sensitivities can change. Single-factor correlations can reflect omitted variables. Batch 6 therefore requires stability, minimum sample size and collinearity controls and still keeps context subordinate to fundamentals.',
    ),
  );

  static const Map<InvestorMetricKind, double> _directionalWeights = {
    InvestorMetricKind.broadMarketSensitivity: 0.30,
    InvestorMetricKind.sectorSensitivity: 0.30,
    InvestorMetricKind.longTermYieldSensitivity: 0.20,
    InvestorMetricKind.financialConditionsSensitivity: 0.15,
    InvestorMetricKind.usdIndexSensitivity: 0.05,
  };

  @override
  String get name => kDefinition.name;

  @override
  EvidenceDefinition get definition => kDefinition;

  @override
  InvestorEvidenceAssessment evaluate(InvestorPointInTimeSnapshot snapshot) {
    if (!snapshot.isPointInTimeSafe) {
      return _unavailable(
        'The snapshot contains sensitivity observations that were not yet available at the analysis time.',
      );
    }

    final observations = snapshot.sensitivityHistory.toList(growable: false)
      ..sort((a, b) => a.metadata.observedAt.compareTo(b.metadata.observedAt));

    final candidates = [
      _candidate(
        observations,
        factor: InvestorSensitivityFactor.broadMarket,
        kind: InvestorMetricKind.broadMarketSensitivity,
      ),
      _candidate(
        observations,
        factor: InvestorSensitivityFactor.sector,
        kind: InvestorMetricKind.sectorSensitivity,
      ),
      _candidate(
        observations,
        factor: InvestorSensitivityFactor.longTermYield,
        kind: InvestorMetricKind.longTermYieldSensitivity,
      ),
      _candidate(
        observations,
        factor: InvestorSensitivityFactor.financialConditions,
        kind: InvestorMetricKind.financialConditionsSensitivity,
      ),
      _candidate(
        observations,
        factor: InvestorSensitivityFactor.usdIndex,
        kind: InvestorMetricKind.usdIndexSensitivity,
      ),
    ];

    _applyCollinearityGuard(candidates);

    final directionalMetrics = candidates
        .map((candidate) => candidate.toAssessment())
        .toList(growable: false);
    final volatilityMetric = _volatilityContext(observations);

    final allMetrics = [...directionalMetrics, volatilityMetric];

    final availableDirectional = directionalMetrics
        .where((metric) => metric.isAvailable)
        .toList(growable: false);

    if (availableDirectional.isEmpty) {
      if (volatilityMetric.isAvailable) {
        return InvestorEvidenceAssessment(
          evidence: EvidenceResult(
            providerName: name,
            definition: definition,
            status: EvidenceStatus.available,
            direction: EvidenceDirection.neutral,
            strength: EvidenceStrength.veryWeak,
            score: 0,
            baseWeight: 1,
            dynamicWeight: 1,
            reliability: volatilityMetric.reliability,
            currentValue: 'No validated directional sensitivity',
            baselineValue: 'Volatility context available',
            relativeValue: 'Context only',
            explanation:
                'No market, sector, rate, financial-condition or USD sensitivity passed the Batch 6 stability gates. '
                'Market-implied volatility remains visible as confidence/risk context only and contributes zero direction points.',
          ),
          metrics: allMetrics,
        );
      }

      return _insufficient(
        allMetrics,
        'No factor has enough stable, non-collinear stock-specific history for directional context.',
      );
    }

    final aggregate = InvestorEvidenceMath.aggregate([
      for (final metric in availableDirectional)
        InvestorWeightedMetric(
          metric: metric,
          weight: _directionalWeights[metric.kind] ?? 0,
        ),
    ]);

    final directionText = switch (aggregate.direction) {
      EvidenceDirection.bullish => 'Context supportive',
      EvidenceDirection.bearish => 'Context opposing',
      EvidenceDirection.neutral => 'Context mixed / neutral',
      EvidenceDirection.unknown => 'Context unavailable',
    };

    return InvestorEvidenceAssessment(
      evidence: EvidenceResult(
        providerName: name,
        definition: definition,
        status: EvidenceStatus.available,
        direction: aggregate.direction,
        strength: aggregate.strength,
        score: aggregate.strengthScore,
        baseWeight: 1,
        dynamicWeight: 1,
        reliability: aggregate.reliability,
        currentValue: directionText,
        baselineValue:
            '${availableDirectional.length} validated directional sensitivities',
        relativeValue:
            'Signed context signal ${aggregate.signedScore.toStringAsFixed(0)}',
        explanation:
            '$directionText. Only stable, non-collinear stock-specific sensitivities fitted from prior weekly history contribute to direction. '
            'This remains contextual and cannot create an Investor recommendation. '
            'Market-implied volatility remains confidence/risk-only.',
      ),
      metrics: allMetrics,
    );
  }

  _SensitivityCandidate _candidate(
    List<InvestorSensitivityObservation> observations, {
    required InvestorSensitivityFactor factor,
    required InvestorMetricKind kind,
  }) {
    final usable = observations
        .where((observation) => observation.factorChanges.containsKey(factor))
        .toList(growable: false);

    if (usable.length < minimumHistoricalObservations + 1) {
      return _SensitivityCandidate.unavailable(
        factor: factor,
        kind: kind,
        reason:
            'At least $minimumHistoricalObservations prior aligned weekly observations plus one current observation are required.',
      );
    }

    final historical = usable.sublist(0, usable.length - 1);
    final current = usable.last;

    final factorHistory = historical
        .map((observation) => observation.factorChanges[factor]!)
        .toList(growable: false);
    final stockHistory = historical
        .map((observation) => observation.stockReturnPercent)
        .toList(growable: false);

    final fullCorrelation = _correlation(factorHistory, stockHistory);
    final midpoint = factorHistory.length ~/ 2;

    final firstHalfCorrelation = _correlation(
      factorHistory.sublist(0, midpoint),
      stockHistory.sublist(0, midpoint),
    );
    final secondHalfCorrelation = _correlation(
      factorHistory.sublist(midpoint),
      stockHistory.sublist(midpoint),
    );

    final stable =
        fullCorrelation.abs() >= minimumAbsoluteStockCorrelation &&
        firstHalfCorrelation.abs() >= minimumHalfSampleCorrelation &&
        secondHalfCorrelation.abs() >= minimumHalfSampleCorrelation &&
        firstHalfCorrelation.sign == secondHalfCorrelation.sign &&
        fullCorrelation.sign == firstHalfCorrelation.sign;

    if (!stable) {
      return _SensitivityCandidate.unavailable(
        factor: factor,
        kind: kind,
        factorHistory: factorHistory,
        stockCorrelation: fullCorrelation,
        reason:
            'The historical stock/factor relationship is too weak or changes sign between sample halves.',
      );
    }

    final mean = _mean(factorHistory);
    final standardDeviation = _sampleStandardDeviation(factorHistory, mean);

    if (standardDeviation <= 0.0000001) {
      return _SensitivityCandidate.unavailable(
        factor: factor,
        kind: kind,
        factorHistory: factorHistory,
        stockCorrelation: fullCorrelation,
        reason: 'Historical factor changes have insufficient variation.',
      );
    }

    final currentChange = current.factorChanges[factor]!;
    final currentZScore = ((currentChange - mean) / standardDeviation)
        .clamp(-3.0, 3.0)
        .toDouble();

    final signedScore = (fullCorrelation * currentZScore * 75)
        .clamp(-100.0, 100.0)
        .toDouble();

    final halfStability = math.min(
      firstHalfCorrelation.abs(),
      secondHalfCorrelation.abs(),
    );
    final sourceReliability =
        historical.any((observation) => observation.metadata.isSynthetic)
        ? 0.75
        : 0.95;
    final sampleCoverage = (factorHistory.length / 104)
        .clamp(0.50, 1.0)
        .toDouble();
    final stabilityFactor = (halfStability / fullCorrelation.abs())
        .clamp(0.50, 1.0)
        .toDouble();
    final reliability = (sourceReliability * sampleCoverage * stabilityFactor)
        .clamp(0.0, 1.0)
        .toDouble();

    return _SensitivityCandidate(
      factor: factor,
      kind: kind,
      factorHistory: factorHistory,
      stockCorrelation: fullCorrelation,
      firstHalfCorrelation: firstHalfCorrelation,
      secondHalfCorrelation: secondHalfCorrelation,
      currentZScore: currentZScore,
      signedScore: signedScore,
      reliability: reliability,
    );
  }

  void _applyCollinearityGuard(List<_SensitivityCandidate> candidates) {
    for (var leftIndex = 0; leftIndex < candidates.length; leftIndex++) {
      final left = candidates[leftIndex];
      if (!left.isAvailable) {
        continue;
      }

      for (
        var rightIndex = leftIndex + 1;
        rightIndex < candidates.length;
        rightIndex++
      ) {
        final right = candidates[rightIndex];
        if (!right.isAvailable) {
          continue;
        }

        if (left.factorHistory.length != right.factorHistory.length ||
            left.factorHistory.isEmpty) {
          continue;
        }

        final factorCorrelation = _correlation(
          left.factorHistory,
          right.factorHistory,
        );

        if (factorCorrelation.abs() < maximumFactorCollinearity) {
          continue;
        }

        final weaker =
            left.stockCorrelation.abs() >= right.stockCorrelation.abs()
            ? right
            : left;
        final stronger = identical(weaker, left) ? right : left;

        weaker.suppress(
          'Suppressed because ${weaker.kind.label} is highly collinear '
          '(${factorCorrelation.abs().toStringAsFixed(2)}) with '
          '${stronger.kind.label}, which has the stronger stock-specific relationship.',
        );

        if (identical(weaker, left)) {
          break;
        }
      }
    }
  }

  InvestorMetricAssessment _volatilityContext(
    List<InvestorSensitivityObservation> observations,
  ) {
    const factor = InvestorSensitivityFactor.marketImpliedVolatility;
    const kind = InvestorMetricKind.marketImpliedVolatilityContext;

    final usable = observations
        .where((observation) => observation.factorChanges.containsKey(factor))
        .toList(growable: false);

    if (usable.length < 21) {
      return _metricUnavailable(
        kind,
        'At least 20 prior weekly implied-volatility changes plus one current observation are required.',
      );
    }

    final historical = usable.sublist(0, usable.length - 1);
    final history = historical
        .map((observation) => observation.factorChanges[factor]!)
        .toList(growable: false);

    final mean = _mean(history);
    final standardDeviation = _sampleStandardDeviation(history, mean);

    if (standardDeviation <= 0.0000001) {
      return _metricUnavailable(
        kind,
        'Historical implied-volatility changes have insufficient variation.',
      );
    }

    final currentChange = usable.last.factorChanges[factor]!;
    final zScore = ((currentChange - mean) / standardDeviation)
        .clamp(-3.0, 3.0)
        .toDouble();
    final sourceReliability =
        historical.any((observation) => observation.metadata.isSynthetic)
        ? 0.75
        : 0.95;

    return InvestorMetricAssessment(
      kind: kind,
      status: InvestorMetricAssessmentStatus.available,
      direction: EvidenceDirection.neutral,
      signedScore: 0,
      reliability: sourceReliability,
      currentValue:
          '${zScore >= 0 ? '+' : ''}${zScore.toStringAsFixed(1)}σ weekly move',
      baselineValue: 'Expected-volatility context only',
      explanation:
          'The latest market-implied-volatility change is ${zScore.abs().toStringAsFixed(1)} standard deviations from prior weekly-change history. '
          'Batch 6 intentionally contributes zero direction points from market-implied volatility.',
      explainability: InvestorMetricExplainabilityCatalog.forKind(kind),
    );
  }

  double _correlation(List<double> left, List<double> right) {
    if (left.length != right.length || left.length < 2) {
      return 0;
    }

    final leftMean = _mean(left);
    final rightMean = _mean(right);

    var covariance = 0.0;
    var leftVariance = 0.0;
    var rightVariance = 0.0;

    for (var index = 0; index < left.length; index++) {
      final leftDelta = left[index] - leftMean;
      final rightDelta = right[index] - rightMean;
      covariance += leftDelta * rightDelta;
      leftVariance += leftDelta * leftDelta;
      rightVariance += rightDelta * rightDelta;
    }

    final denominator = math.sqrt(leftVariance * rightVariance);
    if (denominator <= 0.0000001) {
      return 0;
    }

    return (covariance / denominator).clamp(-1.0, 1.0).toDouble();
  }

  double _mean(List<double> values) =>
      values.reduce((a, b) => a + b) / values.length;

  double _sampleStandardDeviation(List<double> values, double mean) {
    if (values.length < 2) {
      return 0;
    }

    final sumSquares = values.fold<double>(
      0,
      (sum, value) => sum + math.pow(value - mean, 2).toDouble(),
    );

    return math.sqrt(sumSquares / (values.length - 1));
  }

  InvestorMetricAssessment _metricUnavailable(
    InvestorMetricKind kind,
    String reason,
  ) {
    return InvestorMetricAssessment(
      kind: kind,
      status: InvestorMetricAssessmentStatus.insufficientData,
      direction: EvidenceDirection.unknown,
      signedScore: 0,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'Stable stock-specific history required',
      explanation: reason,
      explainability: InvestorMetricExplainabilityCatalog.forKind(kind),
    );
  }

  InvestorEvidenceAssessment _insufficient(
    List<InvestorMetricAssessment> metrics,
    String reason,
  ) {
    return InvestorEvidenceAssessment(
      evidence: EvidenceResult(
        providerName: name,
        definition: definition,
        status: EvidenceStatus.insufficientData,
        direction: EvidenceDirection.unknown,
        strength: EvidenceStrength.veryWeak,
        score: 0,
        baseWeight: 1,
        dynamicWeight: 1,
        reliability: 0,
        currentValue: 'Not enough validated sensitivity',
        baselineValue: 'Stable non-collinear weekly history required',
        relativeValue: 'Not available',
        explanation: reason,
        unavailableReason: reason,
      ),
      metrics: metrics,
    );
  }

  InvestorEvidenceAssessment _unavailable(String reason) {
    return InvestorEvidenceAssessment(
      evidence: EvidenceResult(
        providerName: name,
        definition: definition,
        status: EvidenceStatus.unavailable,
        direction: EvidenceDirection.unknown,
        strength: EvidenceStrength.veryWeak,
        score: 0,
        baseWeight: 1,
        dynamicWeight: 1,
        reliability: 0,
        currentValue: 'Not available',
        baselineValue: 'Point-in-time-safe sensitivity history required',
        relativeValue: 'Not available',
        explanation: reason,
        unavailableReason: reason,
      ),
      metrics: const [],
    );
  }
}

class _SensitivityCandidate {
  _SensitivityCandidate({
    required this.factor,
    required this.kind,
    required this.factorHistory,
    required this.stockCorrelation,
    required this.firstHalfCorrelation,
    required this.secondHalfCorrelation,
    required this.currentZScore,
    required this.signedScore,
    required this.reliability,
  }) : reason = null;

  _SensitivityCandidate.unavailable({
    required this.factor,
    required this.kind,
    this.factorHistory = const [],
    this.stockCorrelation = 0,
    required String reason,
  }) : firstHalfCorrelation = 0,
       secondHalfCorrelation = 0,
       currentZScore = 0,
       signedScore = 0,
       reliability = 0,
       reason = reason;

  final InvestorSensitivityFactor factor;
  final InvestorMetricKind kind;
  final List<double> factorHistory;
  final double stockCorrelation;
  final double firstHalfCorrelation;
  final double secondHalfCorrelation;
  final double currentZScore;
  final double signedScore;
  final double reliability;
  String? reason;

  bool get isAvailable => reason == null;

  void suppress(String suppressionReason) {
    reason = suppressionReason;
  }

  InvestorMetricAssessment toAssessment() {
    final explainability = InvestorMetricExplainabilityCatalog.forKind(kind);

    if (!isAvailable) {
      return InvestorMetricAssessment(
        kind: kind,
        status: InvestorMetricAssessmentStatus.insufficientData,
        direction: EvidenceDirection.unknown,
        signedScore: 0,
        reliability: 0,
        currentValue: 'Not available',
        baselineValue: 'Stable non-collinear sensitivity required',
        explanation: reason ?? 'Sensitivity unavailable.',
        explainability: explainability,
      );
    }

    final direction = signedScore > 10
        ? EvidenceDirection.bullish
        : signedScore < -10
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    return InvestorMetricAssessment(
      kind: kind,
      status: InvestorMetricAssessmentStatus.available,
      direction: direction,
      signedScore: signedScore,
      reliability: reliability,
      currentValue:
          '${currentZScore >= 0 ? '+' : ''}${currentZScore.toStringAsFixed(1)}σ factor move',
      baselineValue:
          'Stock correlation ${stockCorrelation.toStringAsFixed(2)} · '
          'halves ${firstHalfCorrelation.toStringAsFixed(2)} / '
          '${secondHalfCorrelation.toStringAsFixed(2)}',
      explanation:
          '${kind.label} uses a historical stock/factor correlation of '
          '${stockCorrelation.toStringAsFixed(2)} fitted before the current observation, '
          'with a current standardized factor move of ${currentZScore.toStringAsFixed(1)}σ. '
          'The resulting contextual signed signal is ${signedScore.toStringAsFixed(0)}.',
      explainability: explainability,
    );
  }
}
