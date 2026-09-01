import 'dart:math' as math;

import '../../models/evidence_definition.dart';
import '../../models/evidence_family.dart';
import '../../models/evidence_result.dart';
import '../models/investor_data_contracts.dart';
import '../models/investor_metric_assessment.dart';
import '../models/investor_metric_explainability_catalog.dart';
import 'investor_evidence_math.dart';
import 'investor_evidence_provider.dart';

class InvestorGrowthEvidenceProvider implements InvestorEvidenceProvider {
  const InvestorGrowthEvidenceProvider();

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    family: EvidenceFamily.growth,
    name: 'Investor Growth',
    description:
        'Evaluates whether revenue, diluted EPS and free cash flow are expanding or contracting over a multi-year horizon.',
    whyItMatters:
        'Durable long-term growth can expand the economic base of the business, while persistent contraction can weaken the investment thesis.',
    calculation:
        'Combines point-in-time-safe multi-year CAGR assessments for Revenue, diluted EPS and Free Cash Flow. The metrics are aggregated inside one Growth family result so correlated growth measures do not become separate recommendation votes.',
    explainability: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'A de-duplicated long-term Growth family assessment built from several company growth measures.',
      calculation:
          'Revenue, diluted EPS and Free Cash Flow CAGR are normalized symmetrically, reliability-weighted and combined into one family-level evidence result. Batch 2 uses transparent deterministic normalization, not historically optimized recommendation thresholds.',
      whyItMatters:
          'A long-term Investor thesis should distinguish durable business expansion from stagnation or contraction.',
      supportiveInterpretation:
          'Broad positive multi-year growth supports bullish Investor evidence.',
      opposingInterpretation:
          'Broad multi-year contraction supports bearish Investor evidence.',
      neutralInterpretation:
          'Flat or materially mixed growth measures remain neutral rather than being forced into a direction.',
      recommendationImpact:
          'This assessment is structurally compatible with the shared evidence/consensus model but Investor recommendation generation remains disabled in Batch 2.',
      limitations:
          'Growth alone does not prove quality or attractive valuation. Sector-relative growth normalization, cyclicality and acquisition decomposition are not yet modeled.',
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
      _cagrMetric(
        snapshot: snapshot,
        metric: InvestorFundamentalMetric.revenue,
        kind: InvestorMetricKind.revenueCagr,
      ),
      _cagrMetric(
        snapshot: snapshot,
        metric: InvestorFundamentalMetric.dilutedEps,
        kind: InvestorMetricKind.dilutedEpsCagr,
      ),
      _cagrMetric(
        snapshot: snapshot,
        metric: InvestorFundamentalMetric.freeCashFlow,
        kind: InvestorMetricKind.freeCashFlowCagr,
      ),
    ];

    final available = metrics.where((metric) => metric.isAvailable).toList();

    final hasRevenue = metrics
        .where((metric) => metric.kind == InvestorMetricKind.revenueCagr)
        .any((metric) => metric.isAvailable);

    if (!hasRevenue || available.length < 2) {
      return _insufficient(
        metrics,
        'Investor Growth requires Revenue Growth plus at least one additional valid growth measure.',
      );
    }

    final aggregate = InvestorEvidenceMath.aggregate([
      InvestorWeightedMetric(metric: metrics[0], weight: 0.45),
      InvestorWeightedMetric(metric: metrics[1], weight: 0.20),
      InvestorWeightedMetric(metric: metrics[2], weight: 0.35),
    ]);

    final directionText = switch (aggregate.direction) {
      EvidenceDirection.bullish => 'Supportive growth',
      EvidenceDirection.bearish => 'Contracting growth',
      EvidenceDirection.neutral => 'Mixed / limited growth',
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
      baselineValue: '${available.length} multi-year growth measures',
      relativeValue:
          'Signed family signal ${aggregate.signedScore.toStringAsFixed(0)}',
      explanation:
          '$directionText. Revenue, EPS and Free Cash Flow are combined inside one Growth family assessment. '
          'Current family reliability is ${(aggregate.reliability * 100).toStringAsFixed(0)}%. '
          'This Batch 2 result does not activate an Investor recommendation.',
    );

    return InvestorEvidenceAssessment(evidence: evidence, metrics: metrics);
  }

  InvestorMetricAssessment _cagrMetric({
    required InvestorPointInTimeSnapshot snapshot,
    required InvestorFundamentalMetric metric,
    required InvestorMetricKind kind,
  }) {
    final points =
        snapshot.fundamentals.where((point) => point.metric == metric).toList()
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

    final first = points.first;
    final last = points.last;

    if (first.value <= 0 || last.value <= 0) {
      return _metricUnavailable(
        kind: kind,
        explainability: explainability,
        reason:
            'CAGR is withheld because both the starting and ending values must be positive.',
      );
    }

    final years =
        last.metadata.observedAt.difference(first.metadata.observedAt).inDays /
        365.25;

    if (years < 1.5) {
      return _metricUnavailable(
        kind: kind,
        explainability: explainability,
        reason: 'The observation span is too short for multi-year CAGR.',
      );
    }

    final cagr =
        (math.pow(last.value / first.value, 1 / years).toDouble() - 1) * 100;

    final signedScore = InvestorEvidenceMath.symmetricNormalize(
      cagr,
      fullScaleMagnitude: 20,
    );

    final direction = signedScore > 10
        ? EvidenceDirection.bullish
        : signedScore < -10
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    final anySynthetic = points.any((point) => point.metadata.isSynthetic);
    final sampleFactor = (points.length / 4).clamp(0.60, 1.0);
    final sourceFactor = anySynthetic ? 0.75 : 0.95;
    final reliability = (sampleFactor * sourceFactor).clamp(0.0, 1.0);

    return InvestorMetricAssessment(
      kind: kind,
      status: InvestorMetricAssessmentStatus.available,
      direction: direction,
      signedScore: signedScore,
      reliability: reliability,
      currentValue: '${cagr >= 0 ? '+' : ''}${cagr.toStringAsFixed(1)}% CAGR',
      baselineValue:
          '${first.value.toStringAsFixed(1)} → ${last.value.toStringAsFixed(1)} over ${years.toStringAsFixed(1)} years',
      explanation:
          '${kind.label} changed at an annualized ${cagr.toStringAsFixed(1)}% rate across ${points.length} point-in-time-safe observations.',
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
        currentValue: 'Not enough fundamental history',
        baselineValue: 'Revenue plus one additional growth measure required',
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
