import '../../models/evidence_definition.dart';
import '../../models/evidence_family.dart';
import '../../models/evidence_result.dart';
import '../models/investor_data_contracts.dart';
import '../models/investor_metric_assessment.dart';
import '../models/investor_metric_explainability_catalog.dart';
import 'investor_evidence_math.dart';
import 'investor_evidence_provider.dart';

class InvestorValuationEvidenceProvider implements InvestorEvidenceProvider {
  const InvestorValuationEvidenceProvider();

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    family: EvidenceFamily.valuation,
    name: 'Investor Valuation',
    description:
        'Compares current usable market multiples with point-in-time historical and peer valuation references.',
    whyItMatters:
        'A strong business can still be a poor long-term entry when the market price already assumes unusually demanding fundamentals.',
    calculation:
        'Calculates P/E, Price/Free Cash Flow and Enterprise Value/Operating Profit only when their denominators are positive and meaningful. Each multiple is compared with available own-history and peer medians, then the three comparisons are de-duplicated into one Valuation-family result.',
    explainability: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'A relative valuation assessment that asks whether current usable multiples look cheap, balanced or expensive versus explicit historical/peer benchmarks.',
      calculation:
          'Each usable multiple is compared separately with point-in-time-safe own-history and peer medians. Discounts support valuation; premiums oppose it. No single intrinsic fair-value price or DCF target is produced.',
      whyItMatters:
          'Investor returns depend not only on business quality but also on how much optimism or pessimism is already embedded in price.',
      supportiveInterpretation:
          'Current multiples materially below valid historical/peer benchmarks can support bullish Valuation evidence.',
      opposingInterpretation:
          'Current multiples materially above valid historical/peer benchmarks can support bearish Valuation evidence.',
      neutralInterpretation:
          'Multiples close to benchmarks, or offsetting cheap/expensive comparisons, remain neutral.',
      recommendationImpact:
          'Valuation is one independent core Investor family. Batch 4 does not activate Investor recommendations or turn relative multiple gaps into price-target upside/downside.',
      limitations:
          'Cheap multiples can reflect genuinely weaker growth, quality or risk. Peer selection and historical regime matter. Negative denominators invalidate common multiples, and specialized sectors such as banks, insurers and REITs require different valuation methods.',
    ),
  );

  @override
  String get name => kDefinition.name;

  @override
  EvidenceDefinition get definition => kDefinition;

  @override
  InvestorEvidenceAssessment evaluate(InvestorPointInTimeSnapshot snapshot) {
    if (!snapshot.isPointInTimeSafe) {
      return _unavailable(
        'The snapshot contains valuation information that was not yet available at the analysis time.',
      );
    }

    if (_requiresSpecializedValuation(snapshot.peerClassification)) {
      return _unavailable(
        'Generic P/E, Price/FCF and EV/Operating Profit are withheld for this business model until specialized valuation rules exist.',
      );
    }

    final metrics = [
      _priceToEarnings(snapshot),
      _priceToFreeCashFlow(snapshot),
      _enterpriseValueToOperatingProfit(snapshot),
    ];

    final available = metrics.where((metric) => metric.isAvailable).toList();

    if (available.length < 2) {
      return _insufficient(
        metrics,
        'Investor Valuation requires at least two meaningful multiples with valid point-in-time comparison references.',
      );
    }

    final aggregate = InvestorEvidenceMath.aggregate([
      InvestorWeightedMetric(metric: metrics[0], weight: 0.35),
      InvestorWeightedMetric(metric: metrics[1], weight: 0.35),
      InvestorWeightedMetric(metric: metrics[2], weight: 0.30),
    ]);

    final directionText = switch (aggregate.direction) {
      EvidenceDirection.bullish => 'Relatively attractive valuation',
      EvidenceDirection.bearish => 'Relatively demanding valuation',
      EvidenceDirection.neutral => 'Balanced / mixed valuation',
      EvidenceDirection.unknown => 'Not available',
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
        baselineValue: '${available.length} usable relative multiples',
        relativeValue:
            'Signed family signal ${aggregate.signedScore.toStringAsFixed(0)}',
        explanation:
            '$directionText. Current usable multiples are compared with explicit own-history and peer medians and then combined into one Valuation family. '
            'Current family reliability is ${(aggregate.reliability * 100).toStringAsFixed(0)}%. '
            'The result is relative valuation evidence, not a fair-value price target.',
      ),
      metrics: metrics,
    );
  }

  InvestorMetricAssessment _priceToEarnings(
    InvestorPointInTimeSnapshot snapshot,
  ) {
    final marketCap = _latestMarket(
      snapshot,
      InvestorMarketMetric.marketCapitalization,
    );
    final netIncome = _latestFundamental(
      snapshot,
      InvestorFundamentalMetric.netIncome,
    );

    if (marketCap == null || netIncome == null) {
      return _metricUnavailable(
        InvestorMetricKind.priceToEarningsRelative,
        'Market capitalization and net income are required.',
      );
    }

    if (marketCap.value <= 0 || netIncome.value <= 0) {
      return _metricUnavailable(
        InvestorMetricKind.priceToEarningsRelative,
        'P/E is withheld because both market capitalization and net income must be positive.',
      );
    }

    final multiple = marketCap.value / netIncome.value;

    return _relativeMultipleAssessment(
      snapshot: snapshot,
      kind: InvestorMetricKind.priceToEarningsRelative,
      multiple: InvestorValuationMultiple.priceToEarnings,
      currentMultiple: multiple,
      syntheticInput:
          marketCap.metadata.isSynthetic || netIncome.metadata.isSynthetic,
    );
  }

  InvestorMetricAssessment _priceToFreeCashFlow(
    InvestorPointInTimeSnapshot snapshot,
  ) {
    final marketCap = _latestMarket(
      snapshot,
      InvestorMarketMetric.marketCapitalization,
    );
    final fcf = _latestFundamental(
      snapshot,
      InvestorFundamentalMetric.freeCashFlow,
    );

    if (marketCap == null || fcf == null) {
      return _metricUnavailable(
        InvestorMetricKind.priceToFreeCashFlowRelative,
        'Market capitalization and free cash flow are required.',
      );
    }

    if (marketCap.value <= 0 || fcf.value <= 0) {
      return _metricUnavailable(
        InvestorMetricKind.priceToFreeCashFlowRelative,
        'Price/FCF is withheld because both market capitalization and free cash flow must be positive.',
      );
    }

    final multiple = marketCap.value / fcf.value;

    return _relativeMultipleAssessment(
      snapshot: snapshot,
      kind: InvestorMetricKind.priceToFreeCashFlowRelative,
      multiple: InvestorValuationMultiple.priceToFreeCashFlow,
      currentMultiple: multiple,
      syntheticInput:
          marketCap.metadata.isSynthetic || fcf.metadata.isSynthetic,
    );
  }

  InvestorMetricAssessment _enterpriseValueToOperatingProfit(
    InvestorPointInTimeSnapshot snapshot,
  ) {
    final enterpriseValue = _latestMarket(
      snapshot,
      InvestorMarketMetric.enterpriseValue,
    );
    final revenue = _latestFundamental(
      snapshot,
      InvestorFundamentalMetric.revenue,
    );
    final operatingMargin = _latestFundamental(
      snapshot,
      InvestorFundamentalMetric.operatingMargin,
    );

    if (enterpriseValue == null || revenue == null || operatingMargin == null) {
      return _metricUnavailable(
        InvestorMetricKind.enterpriseValueToOperatingProfitRelative,
        'Enterprise value, revenue and operating margin are required.',
      );
    }

    final operatingProfit = revenue.value * operatingMargin.value / 100;

    if (enterpriseValue.value <= 0 || operatingProfit <= 0) {
      return _metricUnavailable(
        InvestorMetricKind.enterpriseValueToOperatingProfitRelative,
        'EV/Operating Profit is withheld because both enterprise value and operating profit must be positive.',
      );
    }

    final multiple = enterpriseValue.value / operatingProfit;

    return _relativeMultipleAssessment(
      snapshot: snapshot,
      kind: InvestorMetricKind.enterpriseValueToOperatingProfitRelative,
      multiple: InvestorValuationMultiple.enterpriseValueToOperatingProfit,
      currentMultiple: multiple,
      syntheticInput:
          enterpriseValue.metadata.isSynthetic ||
          revenue.metadata.isSynthetic ||
          operatingMargin.metadata.isSynthetic,
    );
  }

  InvestorMetricAssessment _relativeMultipleAssessment({
    required InvestorPointInTimeSnapshot snapshot,
    required InvestorMetricKind kind,
    required InvestorValuationMultiple multiple,
    required double currentMultiple,
    required bool syntheticInput,
  }) {
    final reference = snapshot.valuationReferences
        .where((item) => item.multiple == multiple)
        .firstOrNull;

    if (reference == null) {
      return _metricUnavailable(
        kind,
        'No historical or peer reference is available for this multiple.',
      );
    }

    final benchmarks = <double>[
      if (reference.ownHistoryMedian case final value? when value > 0) value,
      if (reference.peerMedian case final value? when value > 0) value,
    ];

    if (benchmarks.isEmpty) {
      return _metricUnavailable(
        kind,
        'The valuation reference contains no positive historical or peer benchmark.',
      );
    }

    final comparisonScores = benchmarks
        .map((benchmark) {
          final premiumDiscountPercent =
              ((currentMultiple / benchmark) - 1) * 100;

          return InvestorEvidenceMath.symmetricNormalize(
            -premiumDiscountPercent,
            fullScaleMagnitude: 50,
          );
        })
        .toList(growable: false);

    final signedScore =
        comparisonScores.reduce((a, b) => a + b) / comparisonScores.length;

    final direction = signedScore > 10
        ? EvidenceDirection.bullish
        : signedScore < -10
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    final synthetic = syntheticInput || reference.metadata.isSynthetic;

    final referenceCoverage = benchmarks.length == 2 ? 1.0 : 0.85;
    final sourceReliability = synthetic ? 0.75 : 0.95;
    final reliability = (referenceCoverage * sourceReliability).clamp(0.0, 1.0);

    final historyText = reference.ownHistoryMedian == null
        ? 'history n/a'
        : 'history ${reference.ownHistoryMedian!.toStringAsFixed(1)}×';
    final peerText = reference.peerMedian == null
        ? 'peers n/a'
        : 'peers ${reference.peerMedian!.toStringAsFixed(1)}×';

    return InvestorMetricAssessment(
      kind: kind,
      status: InvestorMetricAssessmentStatus.available,
      direction: direction,
      signedScore: signedScore.clamp(-100.0, 100.0),
      reliability: reliability,
      currentValue: '${currentMultiple.toStringAsFixed(1)}×',
      baselineValue: '$historyText · $peerText',
      explanation:
          '${kind.label} is ${currentMultiple.toStringAsFixed(1)}× versus ${benchmarks.length} valid point-in-time comparison benchmark${benchmarks.length == 1 ? '' : 's'}. '
          'The signed score describes relative cheapness/expensiveness only and is not a price-target percentage.',
      explainability: InvestorMetricExplainabilityCatalog.forKind(kind),
    );
  }

  InvestorMetricPoint<InvestorFundamentalMetric>? _latestFundamental(
    InvestorPointInTimeSnapshot snapshot,
    InvestorFundamentalMetric metric,
  ) {
    final points = snapshot.fundamentals
        .where((point) => point.metric == metric)
        .toList(growable: false);

    if (points.isEmpty) {
      return null;
    }

    points.sort(
      (a, b) => a.metadata.observedAt.compareTo(b.metadata.observedAt),
    );
    return points.last;
  }

  InvestorMetricPoint<InvestorMarketMetric>? _latestMarket(
    InvestorPointInTimeSnapshot snapshot,
    InvestorMarketMetric metric,
  ) {
    final points = snapshot.market
        .where((point) => point.metric == metric)
        .toList(growable: false);

    if (points.isEmpty) {
      return null;
    }

    points.sort(
      (a, b) => a.metadata.observedAt.compareTo(b.metadata.observedAt),
    );
    return points.last;
  }

  bool _requiresSpecializedValuation(
    InvestorPeerClassification? classification,
  ) {
    if (classification == null) {
      return false;
    }

    final text = '${classification.sector} ${classification.industry}'
        .toLowerCase();

    return text.contains('financial') ||
        text.contains('bank') ||
        text.contains('insurance') ||
        text.contains('reit') ||
        text.contains('real estate investment trust');
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
      baselineValue: 'Meaningful relative benchmark required',
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
        currentValue: 'Not enough valuation evidence',
        baselineValue: 'At least two usable relative multiples required',
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
        baselineValue: 'Specialized or point-in-time-safe valuation required',
        relativeValue: 'Not available',
        explanation: reason,
        unavailableReason: reason,
      ),
      metrics: const [],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    for (final value in this) {
      return value;
    }
    return null;
  }
}
