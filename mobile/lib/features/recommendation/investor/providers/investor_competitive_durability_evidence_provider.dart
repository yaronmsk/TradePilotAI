import '../../models/evidence_definition.dart';
import '../../models/evidence_family.dart';
import '../../models/evidence_result.dart';
import '../models/investor_data_contracts.dart';
import '../models/investor_metric_assessment.dart';
import '../models/investor_metric_explainability_catalog.dart';
import 'investor_evidence_math.dart';
import 'investor_evidence_provider.dart';

class InvestorCompetitiveDurabilityEvidenceProvider
    implements InvestorEvidenceProvider {
  const InvestorCompetitiveDurabilityEvidenceProvider();

  /// Batch 5 uses historical profitability/cash-flow observations that overlap
  /// with Profitability & Quality. Until Batch 8 applies an explicit overlap
  /// rule, this family must not satisfy independent core breadth by itself.
  static const bool sharesInputsWithProfitabilityQuality = true;
  static const bool eligibleForIndependentBreadthInBatch5 = false;

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    family: EvidenceFamily.competitiveDurability,
    name: 'Investor Competitive Durability',
    description:
        'Measures observed persistence and resilience of returns, operating economics and cash generation without claiming that a structural economic moat has been identified.',
    whyItMatters:
        'Long-term investors benefit when strong business economics persist rather than disappearing quickly under competition, cyclicality or execution pressure.',
    calculation:
        'Batch 5 evaluates ROIC persistence, operating-margin persistence and free-cash-flow persistence across the available annual history. Positive economics support persistence, while severe erosion or repeated negative periods oppose it.',
    explainability: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'An observed economic-durability proxy based on whether company returns, operating profitability and cash generation remained resilient across multiple reported years.',
      calculation:
          'Each durability metric combines the share of positive observations with an erosion penalty when the latest economics have fallen materially from earlier levels. The three proxies are combined into one Competitive Durability family.',
      whyItMatters:
          'Persistent economics are more compatible with a durable long-term business than economics that repeatedly disappear or erode sharply.',
      supportiveInterpretation:
          'Consistently positive economics with limited erosion support observed durability.',
      opposingInterpretation:
          'Repeated negative economics or severe erosion oppose observed durability.',
      neutralInterpretation:
          'Mixed persistence provides limited directional evidence.',
      recommendationImpact:
          'Competitive Durability is implemented as a correlated proxy in Batch 5. Because it reuses inputs also relevant to Profitability & Quality, it is not eligible to satisfy independent core breadth until Batch 8 explicitly resolves overlap.',
      limitations:
          'This is not a moat rating and does not identify network effects, switching costs, brands, patents, cost advantages or efficient scale. It also does not compare ROIC with cost of capital. Shared raw inputs create correlation with Profitability & Quality.',
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
        'The snapshot contains fundamentals that were not yet public at the analysis time.',
      );
    }

    final metrics = [
      _percentagePersistence(
        snapshot,
        fundamental: InvestorFundamentalMetric.returnOnInvestedCapital,
        kind: InvestorMetricKind.returnOnInvestedCapitalPersistence,
      ),
      _percentagePersistence(
        snapshot,
        fundamental: InvestorFundamentalMetric.operatingMargin,
        kind: InvestorMetricKind.operatingMarginPersistence,
      ),
      _cashFlowPersistence(snapshot),
    ];

    final available = metrics.where((metric) => metric.isAvailable).toList();

    if (available.length < 2) {
      return _insufficient(
        metrics,
        'Competitive Durability requires at least two multi-year persistence measures.',
      );
    }

    final aggregate = InvestorEvidenceMath.aggregate([
      InvestorWeightedMetric(metric: metrics[0], weight: 0.35),
      InvestorWeightedMetric(metric: metrics[1], weight: 0.35),
      InvestorWeightedMetric(metric: metrics[2], weight: 0.30),
    ]);

    final directionText = switch (aggregate.direction) {
      EvidenceDirection.bullish => 'Economics look persistent',
      EvidenceDirection.bearish => 'Durability is weakening',
      EvidenceDirection.neutral => 'Mixed durability',
      EvidenceDirection.unknown => 'Not available',
    };

    // Reliability is intentionally discounted because these observations share
    // underlying inputs with Profitability & Quality.
    final overlapAdjustedReliability = (aggregate.reliability * 0.80).clamp(
      0.0,
      1.0,
    );

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
        reliability: overlapAdjustedReliability,
        currentValue: directionText,
        baselineValue: '${available.length} persistence measures',
        relativeValue:
            'Signed family signal ${aggregate.signedScore.toStringAsFixed(0)}',
        explanation:
            '$directionText. ROIC, operating-margin and FCF persistence are combined once, with an explicit reliability discount for overlap with Profitability & Quality. '
            'This is observed durability evidence, not a structural moat claim.',
      ),
      metrics: metrics,
    );
  }

  InvestorMetricAssessment _percentagePersistence(
    InvestorPointInTimeSnapshot snapshot, {
    required InvestorFundamentalMetric fundamental,
    required InvestorMetricKind kind,
  }) {
    final points = _series(snapshot, fundamental);

    if (points.length < 4) {
      return _metricUnavailable(
        kind,
        'At least four annual observations are required for durability.',
      );
    }

    final positiveShare =
        points.where((point) => point.value > 0).length / points.length;

    final first = points.first.value;
    final latest = points.last.value;
    final erosionPercent = first <= 0
        ? 0.0
        : ((first - latest).clamp(0.0, double.infinity) / first.abs()) * 100;

    final positiveSignal = ((positiveShare * 2) - 1) * 60;
    final erosionPenalty = InvestorEvidenceMath.symmetricNormalize(
      erosionPercent,
      fullScaleMagnitude: 60,
    );

    final signedScore = (positiveSignal - erosionPenalty).clamp(-100.0, 100.0);

    return _availableMetric(
      kind: kind,
      signedScore: signedScore,
      currentValue:
          '${(positiveShare * 100).toStringAsFixed(0)}% positive years',
      baselineValue:
          'Latest ${latest.toStringAsFixed(1)} · erosion ${erosionPercent.toStringAsFixed(0)}%',
      explanation:
          '${kind.label} shows ${(positiveShare * 100).toStringAsFixed(0)}% positive observations and ${erosionPercent.toStringAsFixed(0)}% erosion from the first to latest observation.',
      synthetic: points.any((point) => point.metadata.isSynthetic),
    );
  }

  InvestorMetricAssessment _cashFlowPersistence(
    InvestorPointInTimeSnapshot snapshot,
  ) {
    final kind = InvestorMetricKind.freeCashFlowPersistence;
    final points = _series(snapshot, InvestorFundamentalMetric.freeCashFlow);

    if (points.length < 4) {
      return _metricUnavailable(
        kind,
        'At least four annual free-cash-flow observations are required.',
      );
    }

    final positiveShare =
        points.where((point) => point.value > 0).length / points.length;
    final peak = points
        .map((point) => point.value)
        .reduce((a, b) => a > b ? a : b);
    final latest = points.last.value;

    final erosionPercent = peak <= 0
        ? 100.0
        : ((peak - latest).clamp(0.0, double.infinity) / peak.abs()) * 100;

    final positiveSignal = ((positiveShare * 2) - 1) * 60;
    final erosionPenalty = InvestorEvidenceMath.symmetricNormalize(
      erosionPercent,
      fullScaleMagnitude: 60,
    );

    final signedScore = (positiveSignal - erosionPenalty).clamp(-100.0, 100.0);

    return _availableMetric(
      kind: kind,
      signedScore: signedScore,
      currentValue:
          '${(positiveShare * 100).toStringAsFixed(0)}% positive years',
      baselineValue:
          'Latest ${latest.toStringAsFixed(1)} · peak erosion ${erosionPercent.toStringAsFixed(0)}%',
      explanation:
          'Free cash flow remained positive in ${(positiveShare * 100).toStringAsFixed(0)}% of observations, with ${erosionPercent.toStringAsFixed(0)}% erosion from the historical peak to the latest value.',
      synthetic: points.any((point) => point.metadata.isSynthetic),
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
      signedScore: signedScore,
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
      baselineValue: 'Four annual observations required',
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
        currentValue: 'Not enough durability history',
        baselineValue: 'At least two persistence measures required',
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
        baselineValue: 'Point-in-time-safe fundamentals required',
        relativeValue: 'Not available',
        explanation: reason,
        unavailableReason: reason,
      ),
      metrics: const [],
    );
  }
}
