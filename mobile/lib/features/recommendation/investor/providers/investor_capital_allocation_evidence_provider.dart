import '../../models/evidence_definition.dart';
import '../../models/evidence_family.dart';
import '../../models/evidence_result.dart';
import '../models/investor_data_contracts.dart';
import '../models/investor_metric_assessment.dart';
import '../models/investor_metric_explainability_catalog.dart';
import 'investor_evidence_math.dart';
import 'investor_evidence_provider.dart';

class InvestorCapitalAllocationEvidenceProvider
    implements InvestorEvidenceProvider {
  const InvestorCapitalAllocationEvidenceProvider();

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    family: EvidenceFamily.capitalAllocation,
    name: 'Investor Capital Allocation & Dilution',
    description:
        'Evaluates whether financing and shareholder-return choices are preserving per-share ownership and staying reasonably funded by business cash generation.',
    whyItMatters:
        'A growing company can still destroy per-share value through persistent dilution or cash returns that are not supported by free cash flow.',
    calculation:
        'Combines net share-count change, stock-based-compensation burden and cash-return funding into one de-duplicated Capital Allocation family result. Gross buybacks are never treated as automatically good because actual share-count change captures issuance and dilution.',
    explainability: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'A long-term assessment of dilution discipline and how shareholder cash returns relate to internally generated free cash flow.',
      calculation:
          'Net share-count change receives the greatest weight, followed by SBC burden and cash-return funding. The result is one family assessment, not three independent votes.',
      whyItMatters:
          'Long-term shareholders benefit when business progress translates into per-share value rather than being offset by issuance, excessive compensation dilution or unfunded distributions.',
      supportiveInterpretation:
          'Net share reduction, contained SBC and cash returns funded within free cash flow can support bullish Investor evidence.',
      opposingInterpretation:
          'Persistent dilution, heavy SBC or distributions materially exceeding free cash flow can oppose the investment thesis.',
      neutralInterpretation:
          'Stable share count, moderate SBC or no cash-return program can remain neutral.',
      recommendationImpact:
          'Capital Allocation & Dilution is one independent core Investor family, but Investor recommendation generation remains disabled in Batch 3.',
      limitations:
          'Buybacks can destroy value when executed at excessive prices, while retaining cash can be rational when reinvestment opportunities are attractive. Batch 3 therefore gives cash-return funding only modest positive influence and does not equate larger payouts with better capital allocation.',
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
        'The snapshot contains data that was not yet public at the analysis time.',
      );
    }

    final metrics = [
      _shareCountChange(snapshot),
      _stockBasedCompensationBurden(snapshot),
      _cashReturnFunding(snapshot),
    ];

    final available = metrics.where((metric) => metric.isAvailable).toList();

    if (available.length < 2) {
      return _insufficient(
        metrics,
        'Capital Allocation & Dilution requires at least two valid measures.',
      );
    }

    final aggregate = InvestorEvidenceMath.aggregate([
      InvestorWeightedMetric(metric: metrics[0], weight: 0.45),
      InvestorWeightedMetric(metric: metrics[1], weight: 0.30),
      InvestorWeightedMetric(metric: metrics[2], weight: 0.25),
    ]);

    final directionText = switch (aggregate.direction) {
      EvidenceDirection.bullish => 'Shareholder-friendly discipline',
      EvidenceDirection.bearish => 'Dilution / funding concern',
      EvidenceDirection.neutral => 'Mixed capital allocation',
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
        baselineValue: '${available.length} capital-allocation measures',
        relativeValue:
            'Signed family signal ${aggregate.signedScore.toStringAsFixed(0)}',
        explanation:
            '$directionText. Net dilution, SBC burden and cash-return funding are combined inside one Capital Allocation & Dilution family assessment. '
            'Gross repurchase spending cannot hide rising share count. '
            'Current family reliability is ${(aggregate.reliability * 100).toStringAsFixed(0)}%.',
      ),
      metrics: metrics,
    );
  }

  InvestorMetricAssessment _shareCountChange(
    InvestorPointInTimeSnapshot snapshot,
  ) {
    final kind = InvestorMetricKind.netShareCountChange;
    final points = _series(
      snapshot,
      InvestorFundamentalMetric.sharesOutstanding,
    );

    if (points.length < 3 || points.first.value <= 0) {
      return _metricUnavailable(
        kind,
        'At least three valid positive share-count observations are required.',
      );
    }

    final changePercent =
        ((points.last.value - points.first.value) / points.first.value) * 100;

    final signedScore = InvestorEvidenceMath.symmetricNormalize(
      -changePercent,
      fullScaleMagnitude: 15,
    );

    final prefix = changePercent > 0 ? '+' : '';

    return _availableMetric(
      kind: kind,
      signedScore: signedScore,
      currentValue: '$prefix${changePercent.toStringAsFixed(1)}%',
      baselineValue:
          '${points.first.value.toStringAsFixed(1)} → ${points.last.value.toStringAsFixed(1)} shares',
      explanation:
          'Outstanding shares changed by $prefix${changePercent.toStringAsFixed(1)}% across the available multi-year history. This net result captures buybacks after issuance/dilution.',
      synthetic: points.any((point) => point.metadata.isSynthetic),
    );
  }

  InvestorMetricAssessment _stockBasedCompensationBurden(
    InvestorPointInTimeSnapshot snapshot,
  ) {
    final kind = InvestorMetricKind.stockBasedCompensationBurden;
    final sbc = _latest(
      snapshot,
      InvestorFundamentalMetric.stockBasedCompensation,
    );
    final revenue = _latest(snapshot, InvestorFundamentalMetric.revenue);

    if (sbc == null || revenue == null || revenue.value <= 0) {
      return _metricUnavailable(kind, 'SBC and positive revenue are required.');
    }

    final burden = (sbc.value / revenue.value) * 100;

    final signedScore = burden <= 1
        ? 70.0
        : burden <= 3
        ? 30.0
        : burden <= 5
        ? 0.0
        : burden <= 8
        ? -35.0
        : burden <= 12
        ? -65.0
        : -100.0;

    return _availableMetric(
      kind: kind,
      signedScore: signedScore,
      currentValue: '${burden.toStringAsFixed(1)}% of revenue',
      baselineValue:
          'SBC ${sbc.value.toStringAsFixed(1)} · Revenue ${revenue.value.toStringAsFixed(1)}',
      explanation:
          'Stock-based compensation consumes ${burden.toStringAsFixed(1)}% of current revenue. Batch 3 thresholds are provisional and not peer-relative.',
      synthetic: sbc.metadata.isSynthetic || revenue.metadata.isSynthetic,
    );
  }

  InvestorMetricAssessment _cashReturnFunding(
    InvestorPointInTimeSnapshot snapshot,
  ) {
    final kind = InvestorMetricKind.cashReturnFunding;
    final dividends = _latest(
      snapshot,
      InvestorFundamentalMetric.dividendsPaid,
    );
    final repurchases = _latest(
      snapshot,
      InvestorFundamentalMetric.shareRepurchases,
    );
    final fcf = _latest(snapshot, InvestorFundamentalMetric.freeCashFlow);

    if (dividends == null || repurchases == null || fcf == null) {
      return _metricUnavailable(
        kind,
        'Dividends, share repurchases and free cash flow are required.',
      );
    }

    final cashReturns = dividends.value + repurchases.value;

    if (cashReturns <= 0) {
      return _availableMetric(
        kind: kind,
        signedScore: 0,
        currentValue: 'No material cash returns',
        baselineValue: 'No dividend/buyback funding pressure',
        explanation:
            'The company is not making material cash distributions in this synthetic period. Absence of a payout is treated as neutral rather than bad.',
        synthetic:
            dividends.metadata.isSynthetic ||
            repurchases.metadata.isSynthetic ||
            fcf.metadata.isSynthetic,
      );
    }

    if (fcf.value <= 0) {
      return _availableMetric(
        kind: kind,
        signedScore: -100,
        currentValue: 'Returns exceed cash generation',
        baselineValue:
            'Cash returns ${cashReturns.toStringAsFixed(1)} · FCF ${fcf.value.toStringAsFixed(1)}',
        explanation:
            'Positive dividends/buybacks are being made while free cash flow is non-positive, creating a funding concern.',
        synthetic:
            dividends.metadata.isSynthetic ||
            repurchases.metadata.isSynthetic ||
            fcf.metadata.isSynthetic,
      );
    }

    final fundingRatio = cashReturns / fcf.value;

    final signedScore = fundingRatio <= 0.75
        ? 30.0
        : fundingRatio <= 1.0
        ? 15.0
        : fundingRatio <= 1.25
        ? -20.0
        : fundingRatio <= 1.50
        ? -50.0
        : -80.0;

    return _availableMetric(
      kind: kind,
      signedScore: signedScore,
      currentValue: '${(fundingRatio * 100).toStringAsFixed(0)}% of FCF',
      baselineValue:
          'Cash returns ${cashReturns.toStringAsFixed(1)} · FCF ${fcf.value.toStringAsFixed(1)}',
      explanation:
          'Dividends plus gross share repurchases consume ${(fundingRatio * 100).toStringAsFixed(0)}% of current free cash flow. Positive influence is intentionally modest because larger payouts are not automatically better.',
      synthetic:
          dividends.metadata.isSynthetic ||
          repurchases.metadata.isSynthetic ||
          fcf.metadata.isSynthetic,
    );
  }

  List<InvestorMetricPoint<InvestorFundamentalMetric>> _series(
    InvestorPointInTimeSnapshot snapshot,
    InvestorFundamentalMetric metric,
  ) {
    final points = snapshot.fundamentals
        .where((point) => point.metric == metric)
        .toList(growable: false);

    points.sort(
      (a, b) => a.metadata.observedAt.compareTo(b.metadata.observedAt),
    );
    return points;
  }

  InvestorMetricPoint<InvestorFundamentalMetric>? _latest(
    InvestorPointInTimeSnapshot snapshot,
    InvestorFundamentalMetric metric,
  ) {
    final points = _series(snapshot, metric);
    return points.isEmpty ? null : points.last;
  }

  InvestorMetricAssessment _availableMetric({
    required InvestorMetricKind kind,
    required double signedScore,
    required String currentValue,
    required String baselineValue,
    required String explanation,
    required bool synthetic,
  }) {
    final direction = signedScore > 10
        ? EvidenceDirection.bullish
        : signedScore < -10
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    return InvestorMetricAssessment(
      kind: kind,
      status: InvestorMetricAssessmentStatus.available,
      direction: direction,
      signedScore: signedScore.clamp(-100.0, 100.0),
      reliability: synthetic ? 0.75 : 0.95,
      currentValue: currentValue,
      baselineValue: baselineValue,
      explanation: explanation,
      explainability: InvestorMetricExplainabilityCatalog.forKind(kind),
    );
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
      baselineValue: 'Insufficient valid data',
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
        currentValue: 'Not enough capital-allocation data',
        baselineValue: 'At least two valid measures required',
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
        baselineValue: 'Point-in-time-safe data required',
        relativeValue: 'Not available',
        explanation: reason,
        unavailableReason: reason,
      ),
      metrics: const [],
    );
  }
}
