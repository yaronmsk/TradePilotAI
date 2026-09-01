import '../../models/evidence_definition.dart';
import '../../models/evidence_family.dart';
import '../../models/evidence_result.dart';
import '../models/investor_data_contracts.dart';
import '../models/investor_metric_assessment.dart';
import '../models/investor_metric_explainability_catalog.dart';
import 'investor_evidence_math.dart';
import 'investor_evidence_provider.dart';

class InvestorProfitabilityQualityEvidenceProvider
    implements InvestorEvidenceProvider {
  const InvestorProfitabilityQualityEvidenceProvider();

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    family: EvidenceFamily.profitabilityQuality,
    name: 'Investor Profitability & Quality',
    description:
        'Evaluates whether margins and return on invested capital are improving, stable or deteriorating over a multi-year horizon.',
    whyItMatters:
        'Growth creates more long-term value when the business can convert revenue and invested capital into durable operating profit and cash flow.',
    calculation:
        'Combines gross-margin trajectory, operating-margin economics, free-cash-flow-margin economics and ROIC. Related profitability metrics are aggregated into one family result rather than counted as independent votes.',
    explainability: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'A de-duplicated long-term assessment of profitability trajectory and business-quality economics.',
      calculation:
          'Margin and ROIC metrics are normalized symmetrically and combined into one Profitability & Quality family result. Gross margin uses trajectory only; operating margin, FCF margin and ROIC combine trajectory with a bounded positive/negative economic level component centered on zero.',
      whyItMatters:
          'Durable profitability and efficient capital use can distinguish high-quality growth from growth that consumes capital without creating economic value.',
      supportiveInterpretation:
          'Improving and positive profitability economics support bullish Investor evidence.',
      opposingInterpretation:
          'Deteriorating and/or negative profitability economics support bearish Investor evidence.',
      neutralInterpretation:
          'Stable or materially mixed profitability measures remain neutral.',
      recommendationImpact:
          'This assessment uses the shared EvidenceResult shape but Investor recommendation generation remains disabled in Batch 2.',
      limitations:
          'Normal margins and ROIC vary materially by sector and business model. Batch 2 is trajectory-first and does not claim sector-relative level calibration before reliable peer distributions exist.',
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
      _marginMetric(
        snapshot: snapshot,
        sourceMetric: InvestorFundamentalMetric.grossMargin,
        kind: InvestorMetricKind.grossMarginTrend,
        trendFullScale: 8,
        levelWeight: 0,
      ),
      _marginMetric(
        snapshot: snapshot,
        sourceMetric: InvestorFundamentalMetric.operatingMargin,
        kind: InvestorMetricKind.operatingMarginQuality,
        trendFullScale: 8,
        levelWeight: 0.40,
        levelFullScale: 15,
      ),
      _marginMetric(
        snapshot: snapshot,
        sourceMetric: InvestorFundamentalMetric.freeCashFlowMargin,
        kind: InvestorMetricKind.freeCashFlowMarginQuality,
        trendFullScale: 8,
        levelWeight: 0.40,
        levelFullScale: 12,
      ),
      _marginMetric(
        snapshot: snapshot,
        sourceMetric: InvestorFundamentalMetric.returnOnInvestedCapital,
        kind: InvestorMetricKind.returnOnInvestedCapitalQuality,
        trendFullScale: 8,
        levelWeight: 0.50,
        levelFullScale: 15,
      ),
    ];

    final available = metrics.where((metric) => metric.isAvailable).toList();

    if (available.length < 3) {
      return _insufficient(
        metrics,
        'Profitability & Quality requires at least three valid multi-year profitability measures.',
      );
    }

    final aggregate = InvestorEvidenceMath.aggregate([
      InvestorWeightedMetric(metric: metrics[0], weight: 0.20),
      InvestorWeightedMetric(metric: metrics[1], weight: 0.30),
      InvestorWeightedMetric(metric: metrics[2], weight: 0.25),
      InvestorWeightedMetric(metric: metrics[3], weight: 0.25),
    ]);

    final directionText = switch (aggregate.direction) {
      EvidenceDirection.bullish => 'Improving quality',
      EvidenceDirection.bearish => 'Deteriorating quality',
      EvidenceDirection.neutral => 'Mixed / stable quality',
      EvidenceDirection.unknown => 'Not available',
    };

    final evidence = EvidenceResult(
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
      baselineValue: '${available.length} multi-year profitability measures',
      relativeValue:
          'Signed family signal ${aggregate.signedScore.toStringAsFixed(0)}',
      explanation:
          '$directionText. Margin and ROIC metrics are combined inside one Profitability & Quality family assessment. '
          'Current family reliability is ${(aggregate.reliability * 100).toStringAsFixed(0)}%. '
          'Peer-relative level calibration is intentionally not claimed in Batch 2.',
    );

    return InvestorEvidenceAssessment(evidence: evidence, metrics: metrics);
  }

  InvestorMetricAssessment _marginMetric({
    required InvestorPointInTimeSnapshot snapshot,
    required InvestorFundamentalMetric sourceMetric,
    required InvestorMetricKind kind,
    required double trendFullScale,
    required double levelWeight,
    double? levelFullScale,
  }) {
    final points =
        snapshot.fundamentals
            .where((point) => point.metric == sourceMetric)
            .toList()
          ..sort(
            (a, b) => a.metadata.observedAt.compareTo(b.metadata.observedAt),
          );

    final explainability = InvestorMetricExplainabilityCatalog.forKind(kind);

    if (points.length < 3) {
      return _metricUnavailable(
        kind: kind,
        explainability: explainability,
        reason: 'At least three annual observations are required.',
      );
    }

    final first = points.first.value;
    final last = points.last.value;
    final change = last - first;

    final trendScore = InvestorEvidenceMath.symmetricNormalize(
      change,
      fullScaleMagnitude: trendFullScale,
    );

    var signedScore = trendScore;

    if (levelWeight > 0) {
      if (levelFullScale == null || levelFullScale <= 0) {
        return _metricUnavailable(
          kind: kind,
          explainability: explainability,
          reason: 'The profitability level normalization is invalid.',
        );
      }

      final levelScore = InvestorEvidenceMath.symmetricNormalize(
        last,
        fullScaleMagnitude: levelFullScale,
      );

      signedScore =
          ((trendScore * (1 - levelWeight)) + (levelScore * levelWeight)).clamp(
            -100.0,
            100.0,
          );
    }

    final direction = signedScore > 10
        ? EvidenceDirection.bullish
        : signedScore < -10
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    final anySynthetic = points.any((point) => point.metadata.isSynthetic);
    final sampleFactor = (points.length / 4).clamp(0.60, 1.0);
    final sourceFactor = anySynthetic ? 0.75 : 0.95;
    final reliability = (sampleFactor * sourceFactor).clamp(0.0, 1.0);

    final changePrefix = change > 0 ? '+' : '';

    return InvestorMetricAssessment(
      kind: kind,
      status: InvestorMetricAssessmentStatus.available,
      direction: direction,
      signedScore: signedScore,
      reliability: reliability,
      currentValue: '${last.toStringAsFixed(1)}%',
      baselineValue:
          '${first.toStringAsFixed(1)}% → ${last.toStringAsFixed(1)}% ($changePrefix${change.toStringAsFixed(1)}pp)',
      explanation:
          '${kind.label} is ${last.toStringAsFixed(1)}%, a $changePrefix${change.toStringAsFixed(1)} percentage-point change across ${points.length} point-in-time-safe observations.',
      explainability: explainability,
    );
  }

  InvestorMetricAssessment _metricUnavailable({
    required InvestorMetricKind kind,
    required MetricExplainability explainability,
    required String reason,
  }) {
    return InvestorMetricAssessment(
      kind: kind,
      status: InvestorMetricAssessmentStatus.insufficientData,
      direction: EvidenceDirection.unknown,
      signedScore: 0,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'Insufficient valid history',
      explanation: reason,
      explainability: explainability,
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
        currentValue: 'Not enough profitability history',
        baselineValue: 'At least three profitability measures required',
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
        baselineValue: 'Point-in-time safety required',
        relativeValue: 'Not available',
        explanation: reason,
        unavailableReason: reason,
      ),
      metrics: const [],
    );
  }
}
