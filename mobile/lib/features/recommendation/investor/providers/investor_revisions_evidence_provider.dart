import '../../models/evidence_definition.dart';
import '../../models/evidence_family.dart';
import '../../models/evidence_result.dart';
import '../models/investor_data_contracts.dart';
import '../models/investor_metric_assessment.dart';
import '../models/investor_metric_explainability_catalog.dart';
import 'investor_evidence_math.dart';
import 'investor_evidence_provider.dart';

class InvestorRevisionsEvidenceProvider implements InvestorEvidenceProvider {
  const InvestorRevisionsEvidenceProvider();

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    family: EvidenceFamily.revisions,
    name: 'Investor Analyst Revisions',
    description:
        'Measures whether point-in-time analyst consensus estimates for the same future fiscal period have been revised upward, downward or remained broadly stable.',
    whyItMatters:
        'Changes in analyst expectations can reveal whether the forward fundamental outlook is improving or deteriorating before that change appears in reported annual results.',
    calculation:
        'For Revenue, diluted EPS and Free Cash Flow, Batch 5 compares the latest estimate with available 30-day and 90-day vintages for the same target fiscal period. Each metric combines its own windows first; the three metrics are then de-duplicated into one Revisions family.',
    explainability: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'A point-in-time estimate-revision assessment using historical analyst-consensus vintages for one matching future fiscal period.',
      calculation:
          'Each forecast metric compares like-for-like estimate vintages for the same target period. The 90-day change receives 60% of that metric signal and the 30-day change 40% when both exist. Metric-level signals are then combined once inside the Revisions family.',
      whyItMatters:
          'Repeated upward revisions can indicate improving forward expectations, while downward revisions can signal weakening expectations.',
      supportiveInterpretation:
          'Broad or material upward revisions support bullish Investor Revisions evidence.',
      opposingInterpretation:
          'Broad or material downward revisions support bearish Investor Revisions evidence.',
      neutralInterpretation:
          'Small, conflicting or broadly unchanged revisions remain neutral.',
      recommendationImpact:
          'Revisions is one independent core Investor family, but it cannot activate Investor recommendations in Batch 5.',
      limitations:
          'Analyst estimates can be wrong, herding can occur, and sparse coverage lowers reliability. Current consensus must never be backfilled into history. Batch 5 uses transparent development normalization rather than historically optimized thresholds.',
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
        'The snapshot contains analyst estimates that were not yet available at the analysis time.',
      );
    }

    final metrics = [
      _revisionMetric(
        snapshot,
        metric: InvestorEstimateMetric.revenue,
        kind: InvestorMetricKind.revenueEstimateRevision,
        fullScalePercent: 8,
      ),
      _revisionMetric(
        snapshot,
        metric: InvestorEstimateMetric.dilutedEps,
        kind: InvestorMetricKind.dilutedEpsEstimateRevision,
        fullScalePercent: 15,
      ),
      _revisionMetric(
        snapshot,
        metric: InvestorEstimateMetric.freeCashFlow,
        kind: InvestorMetricKind.freeCashFlowEstimateRevision,
        fullScalePercent: 15,
      ),
    ];

    final available = metrics.where((metric) => metric.isAvailable).toList();

    if (available.length < 2) {
      return _insufficient(
        metrics,
        'Revisions requires at least two forecast metrics with like-for-like historical vintages for the same target period.',
      );
    }

    final aggregate = InvestorEvidenceMath.aggregate([
      InvestorWeightedMetric(metric: metrics[0], weight: 0.35),
      InvestorWeightedMetric(metric: metrics[1], weight: 0.40),
      InvestorWeightedMetric(metric: metrics[2], weight: 0.25),
    ]);

    final up = available
        .where((metric) => metric.direction == EvidenceDirection.bullish)
        .length;
    final down = available
        .where((metric) => metric.direction == EvidenceDirection.bearish)
        .length;

    final directionText = switch (aggregate.direction) {
      EvidenceDirection.bullish => 'Estimates revising upward',
      EvidenceDirection.bearish => 'Estimates revising downward',
      EvidenceDirection.neutral => 'Mixed / stable revisions',
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
        baselineValue:
            '$up upward · $down downward · ${available.length} usable',
        relativeValue:
            'Signed family signal ${aggregate.signedScore.toStringAsFixed(0)}',
        explanation:
            '$directionText. Revenue, EPS and FCF revisions are each compared only across matching target-period vintages, then combined into one Revisions family. '
            'Current family reliability is ${(aggregate.reliability * 100).toStringAsFixed(0)}%.',
      ),
      metrics: metrics,
    );
  }

  InvestorMetricAssessment _revisionMetric(
    InvestorPointInTimeSnapshot snapshot, {
    required InvestorEstimateMetric metric,
    required InvestorMetricKind kind,
    required double fullScalePercent,
  }) {
    final series = snapshot.estimates
        .where((point) => point.metric == metric)
        .where(
          (point) => !point.targetPeriodEnd.isBefore(snapshot.analysisTime),
        )
        .toList(growable: false);

    if (series.length < 2) {
      return _metricUnavailable(
        kind,
        'At least two historical estimate vintages are required.',
      );
    }

    final targetDates =
        series
            .map((point) => point.targetPeriodEnd)
            .toSet()
            .toList(growable: false)
          ..sort();

    List<InvestorEstimatePoint>? selected;
    for (final target in targetDates) {
      final sameTarget =
          series
              .where((point) => point.targetPeriodEnd == target)
              .toList(growable: false)
            ..sort(
              (a, b) =>
                  a.metadata.availableAt.compareTo(b.metadata.availableAt),
            );

      if (sameTarget.length >= 2) {
        selected = sameTarget;
        break;
      }
    }

    if (selected == null || selected.length < 2) {
      return _metricUnavailable(
        kind,
        'No future target period has enough like-for-like estimate vintages.',
      );
    }

    final latest = selected.last;
    final ninetyCutoff = snapshot.analysisTime.subtract(
      const Duration(days: 75),
    );
    final thirtyCutoff = snapshot.analysisTime.subtract(
      const Duration(days: 20),
    );

    final ninetyBaseline = _latestAtOrBefore(selected, ninetyCutoff);
    final thirtyBaseline = _latestAtOrBefore(selected, thirtyCutoff);

    final windows = <({double changePercent, double weight, String label})>[];

    if (ninetyBaseline != null &&
        ninetyBaseline.metadata.availableAt.isBefore(
          latest.metadata.availableAt,
        )) {
      final change = _percentRevision(ninetyBaseline.value, latest.value);
      if (change != null) {
        windows.add((changePercent: change, weight: 0.60, label: '90D'));
      }
    }

    if (thirtyBaseline != null &&
        thirtyBaseline.metadata.availableAt.isBefore(
          latest.metadata.availableAt,
        )) {
      final change = _percentRevision(thirtyBaseline.value, latest.value);
      if (change != null) {
        windows.add((changePercent: change, weight: 0.40, label: '30D'));
      }
    }

    if (windows.isEmpty) {
      return _metricUnavailable(
        kind,
        'The available estimate baselines are too close to zero or do not provide a valid revision window.',
      );
    }

    final totalWeight = windows.fold<double>(
      0,
      (sum, item) => sum + item.weight,
    );
    final weightedChange =
        windows.fold<double>(
          0,
          (sum, item) => sum + item.changePercent * item.weight,
        ) /
        totalWeight;

    final signedScore = InvestorEvidenceMath.symmetricNormalize(
      weightedChange,
      fullScaleMagnitude: fullScalePercent,
    );

    final direction = signedScore > 10
        ? EvidenceDirection.bullish
        : signedScore < -10
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    final windowText = windows
        .map((item) => '${item.label} ${_signed(item.changePercent)}%')
        .join(' · ');

    final synthetic = selected.any((point) => point.metadata.isSynthetic);
    final coverageFactor = windows.length == 2 ? 1.0 : 0.85;
    final reliability = ((synthetic ? 0.75 : 0.95) * coverageFactor).clamp(
      0.0,
      1.0,
    );

    return InvestorMetricAssessment(
      kind: kind,
      status: InvestorMetricAssessmentStatus.available,
      direction: direction,
      signedScore: signedScore,
      reliability: reliability,
      currentValue: '${_signed(weightedChange)}%',
      baselineValue: '$windowText · target ${latest.targetPeriodEnd.year}',
      explanation:
          '${kind.label} changed ${_signed(weightedChange)}% on the weighted available revision windows for the same ${latest.targetPeriodEnd.year} target period.',
      explainability: InvestorMetricExplainabilityCatalog.forKind(kind),
    );
  }

  InvestorEstimatePoint? _latestAtOrBefore(
    List<InvestorEstimatePoint> points,
    DateTime cutoff,
  ) {
    InvestorEstimatePoint? result;
    for (final point in points) {
      if (!point.metadata.availableAt.isAfter(cutoff)) {
        result = point;
      }
    }
    return result;
  }

  double? _percentRevision(double baseline, double latest) {
    if (baseline.abs() < 0.000001) {
      return null;
    }

    return ((latest - baseline) / baseline.abs()) * 100;
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
      baselineValue: 'Matching estimate vintages required',
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
        currentValue: 'Not enough revision history',
        baselineValue: 'At least two usable forecast metrics required',
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
        baselineValue: 'Point-in-time-safe estimate vintages required',
        relativeValue: 'Not available',
        explanation: reason,
        unavailableReason: reason,
      ),
      metrics: const [],
    );
  }
}
