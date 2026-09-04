import '../../models/evidence_definition.dart';
import '../../models/evidence_family.dart';
import '../../models/evidence_result.dart';
import '../models/investor_data_contracts.dart';
import '../models/investor_metric_assessment.dart';
import '../models/investor_metric_explainability_catalog.dart';
import 'investor_evidence_math.dart';
import 'investor_evidence_provider.dart';

class InvestorOwnershipPositioningEvidenceProvider
    implements InvestorEvidenceProvider {
  const InvestorOwnershipPositioningEvidenceProvider();

  static const bool eligibleForCoreBreadth = false;
  static const bool canCreateRecommendation = false;
  static const bool insiderNetSharesDirectional = false;
  static const bool absoluteShortInterestDirectional = false;

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    family: EvidenceFamily.ownershipPositioning,
    name: 'Investor Ownership & Positioning',
    description:
        'Measures published institutional-ownership trends, institutional-holder breadth and changes in aggregate short-interest positioning without treating stale filings or raw insider share counts as real-time conviction.',
    whyItMatters:
        'Ownership and positioning can show whether professional participation is broadening or weakening and whether aggregate short positioning is increasing or decreasing, but these signals are slower and less fundamental than the company thesis.',
    calculation:
        'Batch 7 evaluates multi-period institutional ownership change, institutional-holder-count change and short-interest-percent-of-float change. Each input is trend-based, reliability is reduced for stale underlying observations, and all three inputs are de-duplicated into one contextual Ownership & Positioning family.',
    explainability: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'A contextual Investor assessment of published institutional ownership, institutional-holder breadth and aggregate short-interest trends.',
      calculation:
          'Institutional ownership and holder breadth compare published filing observations across multiple periods; short interest compares recent published aggregate position snapshots. Reliability is reduced as the underlying observation ages.',
      whyItMatters:
          'Broadening institutional participation or falling short positioning can support context, while weakening institutional participation or rising short positioning can oppose context.',
      supportiveInterpretation:
          'Broadening published institutional participation and/or falling aggregate short-interest positioning can support contextual direction.',
      opposingInterpretation:
          'Weakening published institutional participation and/or rising aggregate short-interest positioning can oppose contextual direction.',
      neutralInterpretation:
          'Small, conflicting, stale or insufficient positioning changes remain neutral or unavailable.',
      recommendationImpact:
          'Ownership & Positioning is contextual only. It cannot satisfy core-fundamental breadth or create an Investor BUY/SELL; exact context caps are deferred to Batch 8.',
      limitations:
          '13F-style holdings are delayed and incomplete representations of current positioning, passive flows can distort ownership changes, and short interest is a periodic aggregate position snapshot rather than daily short-sale volume. Raw insider net shares are not interpreted directionally without transaction-code-aware data.',
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
        'The snapshot contains ownership/positioning information that was not yet public at the analysis time.',
      );
    }

    final metrics = [
      _institutionalOwnershipTrend(snapshot),
      _institutionalHolderBreadthTrend(snapshot),
      _shortInterestTrend(snapshot),
      _insiderActivityContext(snapshot),
    ];

    final availableDirectional = metrics
        .take(3)
        .where((metric) => metric.isAvailable)
        .toList(growable: false);

    if (availableDirectional.length < 2) {
      return _insufficient(
        metrics,
        'Ownership & Positioning requires at least two usable published trend measures.',
      );
    }

    final aggregate = InvestorEvidenceMath.aggregate([
      InvestorWeightedMetric(metric: metrics[0], weight: 0.40),
      InvestorWeightedMetric(metric: metrics[1], weight: 0.35),
      InvestorWeightedMetric(metric: metrics[2], weight: 0.25),
    ]);

    final directionText = switch (aggregate.direction) {
      EvidenceDirection.bullish => 'Positioning trend supportive',
      EvidenceDirection.bearish => 'Positioning trend opposing',
      EvidenceDirection.neutral => 'Positioning trend mixed / neutral',
      EvidenceDirection.unknown => 'Positioning trend unavailable',
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
            '${availableDirectional.length} published directional trends',
        relativeValue:
            'Signed context signal ${aggregate.signedScore.toStringAsFixed(0)}',
        explanation:
            '$directionText. Institutional ownership, holder breadth and short-interest trends are combined once inside Ownership & Positioning. '
            'Publication lag and observation age reduce reliability. Raw insider net shares remain non-directional in Batch 7.',
      ),
      metrics: metrics,
    );
  }

  InvestorMetricAssessment _institutionalOwnershipTrend(
    InvestorPointInTimeSnapshot snapshot,
  ) {
    const kind = InvestorMetricKind.institutionalOwnershipTrend;
    final points = _series(
      snapshot,
      InvestorPositioningMetric.institutionalOwnershipPercent,
    );

    if (points.length < 3) {
      return _metricUnavailable(
        kind,
        'At least three published institutional-ownership observations are required.',
      );
    }

    final selected = points.sublist(points.length - 3);
    final changePoints = selected.last.value - selected.first.value;
    final signedScore = InvestorEvidenceMath.symmetricNormalize(
      changePoints,
      fullScaleMagnitude: 6,
    );

    return _availableDirectionalMetric(
      snapshot: snapshot,
      kind: kind,
      points: selected,
      signedScore: signedScore,
      currentValue:
          '${selected.last.value.toStringAsFixed(1)}% institutional ownership',
      baselineValue:
          '${selected.first.value.toStringAsFixed(1)}% · ${_signed(changePoints)} pp',
      explanation:
          'Published institutional ownership changed ${_signed(changePoints)} percentage points across the latest three available observations. The absolute ownership level itself is not scored.',
      institutionalCadence: true,
    );
  }

  InvestorMetricAssessment _institutionalHolderBreadthTrend(
    InvestorPointInTimeSnapshot snapshot,
  ) {
    const kind = InvestorMetricKind.institutionalHolderBreadthTrend;
    final points = _series(
      snapshot,
      InvestorPositioningMetric.institutionalHolderCount,
    );

    if (points.length < 3 || points[points.length - 3].value <= 0) {
      return _metricUnavailable(
        kind,
        'At least three positive published institutional-holder observations are required.',
      );
    }

    final selected = points.sublist(points.length - 3);
    final first = selected.first.value;
    final latest = selected.last.value;
    final percentChange = ((latest - first) / first.abs()) * 100;
    final signedScore = InvestorEvidenceMath.symmetricNormalize(
      percentChange,
      fullScaleMagnitude: 15,
    );

    return _availableDirectionalMetric(
      snapshot: snapshot,
      kind: kind,
      points: selected,
      signedScore: signedScore,
      currentValue: '${latest.toStringAsFixed(0)} institutional holders',
      baselineValue: '${first.toStringAsFixed(0)} · ${_signed(percentChange)}%',
      explanation:
          'Published institutional-holder count changed ${_signed(percentChange)}% across the latest three available observations.',
      institutionalCadence: true,
    );
  }

  InvestorMetricAssessment _shortInterestTrend(
    InvestorPointInTimeSnapshot snapshot,
  ) {
    const kind = InvestorMetricKind.shortInterestTrend;
    final points = _series(
      snapshot,
      InvestorPositioningMetric.shortInterestPercentFloat,
    );

    if (points.length < 3) {
      return _metricUnavailable(
        kind,
        'At least three published short-interest position observations are required.',
      );
    }

    final selected = points.sublist(points.length - 3);
    final changePoints = selected.last.value - selected.first.value;

    // Rising short interest is opposing context; falling short interest is
    // supportive context. The absolute level is deliberately not scored.
    final signedScore = InvestorEvidenceMath.symmetricNormalize(
      -changePoints,
      fullScaleMagnitude: 4,
    );

    return _availableDirectionalMetric(
      snapshot: snapshot,
      kind: kind,
      points: selected,
      signedScore: signedScore,
      currentValue: '${selected.last.value.toStringAsFixed(1)}% of float short',
      baselineValue:
          '${selected.first.value.toStringAsFixed(1)}% · ${_signed(changePoints)} pp',
      explanation:
          'Published aggregate short interest changed ${_signed(changePoints)} percentage points of float across the latest three position snapshots. The absolute short-interest level is not assigned bullish or bearish direction.',
      institutionalCadence: false,
    );
  }

  InvestorMetricAssessment _insiderActivityContext(
    InvestorPointInTimeSnapshot snapshot,
  ) {
    const kind = InvestorMetricKind.insiderTransactionContext;
    final points = _series(
      snapshot,
      InvestorPositioningMetric.insiderNetShares,
    );

    final latest = points.isEmpty ? null : points.last;

    return InvestorMetricAssessment(
      kind: kind,
      status: InvestorMetricAssessmentStatus.unavailable,
      direction: EvidenceDirection.unknown,
      signedScore: 0,
      reliability: 0,
      currentValue: latest == null
          ? 'Not available'
          : '${latest.value.toStringAsFixed(0)} raw net shares',
      baselineValue: 'Transaction-code-aware Form 4 data required',
      explanation:
          'Batch 7 does not interpret raw insider net shares directionally because grants, option exercises, tax withholding, gifts and open-market transactions have different meanings.',
      explainability: InvestorMetricExplainabilityCatalog.forKind(kind),
    );
  }

  InvestorMetricAssessment _availableDirectionalMetric({
    required InvestorPointInTimeSnapshot snapshot,
    required InvestorMetricKind kind,
    required List<InvestorMetricPoint<InvestorPositioningMetric>> points,
    required double signedScore,
    required String currentValue,
    required String baselineValue,
    required String explanation,
    required bool institutionalCadence,
  }) {
    final latest = points.last;
    final sourceReliability = points.any((point) => point.metadata.isSynthetic)
        ? 0.75
        : 0.95;

    final ageDays = snapshot.analysisTime
        .difference(latest.metadata.observedAt)
        .inDays
        .clamp(0, 10000);

    final stalenessFactor = institutionalCadence
        ? ageDays <= 60
              ? 1.0
              : ageDays <= 120
              ? 0.85
              : ageDays <= 180
              ? 0.70
              : 0.55
        : ageDays <= 20
        ? 1.0
        : ageDays <= 45
        ? 0.90
        : 0.75;

    final reliability = (sourceReliability * stalenessFactor)
        .clamp(0.0, 1.0)
        .toDouble();

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
      currentValue: currentValue,
      baselineValue: baselineValue,
      explanation:
          '$explanation Underlying observation age is $ageDays days; reliability is reduced as positioning data becomes stale.',
      explainability: InvestorMetricExplainabilityCatalog.forKind(kind),
    );
  }

  List<InvestorMetricPoint<InvestorPositioningMetric>> _series(
    InvestorPointInTimeSnapshot snapshot,
    InvestorPositioningMetric metric,
  ) {
    final points = snapshot.positioning
        .where((point) => point.metric == metric)
        .toList(growable: false);

    points.sort(
      (a, b) => a.metadata.observedAt.compareTo(b.metadata.observedAt),
    );
    return points;
  }

  String _signed(double value) =>
      '${value > 0 ? '+' : ''}${value.toStringAsFixed(1)}';

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
      baselineValue: 'Published trend history required',
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
        currentValue: 'Not enough positioning history',
        baselineValue: 'At least two usable published trends required',
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
        baselineValue: 'Point-in-time-safe published positioning required',
        relativeValue: 'Not available',
        explanation: reason,
        unavailableReason: reason,
      ),
      metrics: const [],
    );
  }
}
