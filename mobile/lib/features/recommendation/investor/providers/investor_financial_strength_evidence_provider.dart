import '../../models/evidence_definition.dart';
import '../../models/evidence_family.dart';
import '../../models/evidence_result.dart';
import '../models/investor_data_contracts.dart';
import '../models/investor_metric_assessment.dart';
import '../models/investor_metric_explainability_catalog.dart';
import 'investor_evidence_math.dart';
import 'investor_evidence_provider.dart';

class InvestorFinancialStrengthEvidenceProvider
    implements InvestorEvidenceProvider {
  const InvestorFinancialStrengthEvidenceProvider();

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    family: EvidenceFamily.financialStrength,
    name: 'Investor Financial Strength',
    description:
        'Evaluates whether a non-financial company has a manageable debt burden, adequate interest coverage and a useful cash cushion.',
    whyItMatters:
        'A long-term investment thesis is more resilient when the company can service obligations without relying on destructive refinancing or shareholder dilution.',
    calculation:
        'Combines Net Debt / Free Cash Flow, operating-profit Interest Coverage and Cash / Debt into one de-duplicated Financial Strength family result. Generic corporate leverage rules are withheld for identified banks, insurers and similar financial structures.',
    explainability: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'A long-term balance-sheet resilience assessment for ordinary non-financial operating companies.',
      calculation:
          'Three bounded debt/liquidity metrics are reliability-weighted and combined into one Financial Strength family assessment. The thresholds are transparent v0.12 development policy assumptions, not a credit rating or historically optimized model.',
      whyItMatters:
          'Excess leverage or weak debt-service capacity can destroy equity value even when growth appears attractive.',
      supportiveInterpretation:
          'Low net debt, strong interest coverage and a healthy cash cushion support bullish Investor evidence.',
      opposingInterpretation:
          'Heavy net debt, weak interest coverage or very low cash relative to debt oppose the long-term investment thesis.',
      neutralInterpretation:
          'Mixed financial-strength measures remain neutral rather than being forced into a direction.',
      recommendationImpact:
          'Financial Strength is one independent core Investor family, but Investor recommendation generation remains disabled in Batch 3.',
      limitations:
          'Debt norms differ by industry and capital structure. These generic corporate thresholds must not be applied to banks, insurers or other businesses whose balance sheets require specialized regulatory/accounting analysis.',
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

    if (_requiresSpecializedFinancialModel(snapshot.peerClassification)) {
      return _unavailable(
        'Generic corporate leverage metrics are not valid for this financial-sector business model.',
      );
    }

    final metrics = [
      _netDebtToFreeCashFlow(snapshot),
      _interestCoverage(snapshot),
      _cashToDebt(snapshot),
    ];

    final available = metrics.where((metric) => metric.isAvailable).toList();

    if (available.length < 2) {
      return _insufficient(
        metrics,
        'Financial Strength requires at least two valid debt/liquidity measures.',
      );
    }

    final aggregate = InvestorEvidenceMath.aggregate([
      InvestorWeightedMetric(metric: metrics[0], weight: 0.45),
      InvestorWeightedMetric(metric: metrics[1], weight: 0.35),
      InvestorWeightedMetric(metric: metrics[2], weight: 0.20),
    ]);

    final directionText = switch (aggregate.direction) {
      EvidenceDirection.bullish => 'Resilient balance sheet',
      EvidenceDirection.bearish => 'Financial pressure',
      EvidenceDirection.neutral => 'Mixed financial strength',
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
        baselineValue: '${available.length} debt/liquidity measures',
        relativeValue:
            'Signed family signal ${aggregate.signedScore.toStringAsFixed(0)}',
        explanation:
            '$directionText. Debt burden, debt-service capacity and liquidity are combined inside one Financial Strength family assessment. '
            'Current family reliability is ${(aggregate.reliability * 100).toStringAsFixed(0)}%. '
            'This is not a credit rating and does not activate Investor recommendations in Batch 3.',
      ),
      metrics: metrics,
    );
  }

  InvestorMetricAssessment _netDebtToFreeCashFlow(
    InvestorPointInTimeSnapshot snapshot,
  ) {
    final kind = InvestorMetricKind.netDebtToFreeCashFlow;
    final explainability = InvestorMetricExplainabilityCatalog.forKind(kind);

    final debt = _latest(snapshot, InvestorFundamentalMetric.totalDebt);
    final cash = _latest(
      snapshot,
      InvestorFundamentalMetric.cashAndEquivalents,
    );
    final fcf = _latest(snapshot, InvestorFundamentalMetric.freeCashFlow);

    if (debt == null || cash == null || fcf == null) {
      return _metricUnavailable(
        kind,
        'Debt, cash and free cash flow are all required.',
      );
    }

    final netDebt = debt.value - cash.value;
    double signedScore;
    String currentValue;

    if (fcf.value <= 0) {
      signedScore = netDebt <= 0 ? -10 : -100;
      currentValue = 'FCF not positive';
    } else {
      final ratio = netDebt / fcf.value;
      currentValue = '${ratio.toStringAsFixed(2)}×';

      signedScore = ratio <= 0
          ? 100
          : ratio <= 1
          ? 80
          : ratio <= 2
          ? 50
          : ratio <= 3
          ? 20
          : ratio <= 4
          ? -20
          : ratio <= 6
          ? -60
          : -100;
    }

    return _availableMetric(
      kind: kind,
      signedScore: signedScore,
      currentValue: currentValue,
      baselineValue:
          'Debt ${debt.value.toStringAsFixed(1)} · Cash ${cash.value.toStringAsFixed(1)} · FCF ${fcf.value.toStringAsFixed(1)}',
      explanation:
          'Net debt is ${netDebt.toStringAsFixed(1)} against current free cash flow of ${fcf.value.toStringAsFixed(1)}.',
      synthetic:
          debt.metadata.isSynthetic ||
          cash.metadata.isSynthetic ||
          fcf.metadata.isSynthetic,
      explainability: explainability,
    );
  }

  InvestorMetricAssessment _interestCoverage(
    InvestorPointInTimeSnapshot snapshot,
  ) {
    final kind = InvestorMetricKind.interestCoverage;
    final explainability = InvestorMetricExplainabilityCatalog.forKind(kind);

    final revenue = _latest(snapshot, InvestorFundamentalMetric.revenue);
    final operatingMargin = _latest(
      snapshot,
      InvestorFundamentalMetric.operatingMargin,
    );
    final interest = _latest(
      snapshot,
      InvestorFundamentalMetric.interestExpense,
    );

    if (revenue == null || operatingMargin == null || interest == null) {
      return _metricUnavailable(
        kind,
        'Revenue, operating margin and interest expense are required.',
      );
    }

    final operatingIncome = revenue.value * operatingMargin.value / 100;

    double signedScore;
    String currentValue;

    if (interest.value <= 0) {
      signedScore = operatingIncome > 0 ? 100 : 0;
      currentValue = operatingIncome > 0
          ? 'No material interest'
          : 'Not meaningful';
    } else {
      final coverage = operatingIncome / interest.value;
      currentValue = '${coverage.toStringAsFixed(2)}×';

      signedScore = coverage >= 8
          ? 100
          : coverage >= 5
          ? 70
          : coverage >= 3
          ? 40
          : coverage >= 2
          ? 10
          : coverage >= 1
          ? -40
          : coverage >= 0
          ? -80
          : -100;
    }

    return _availableMetric(
      kind: kind,
      signedScore: signedScore,
      currentValue: currentValue,
      baselineValue:
          'Operating profit ${operatingIncome.toStringAsFixed(1)} · Interest ${interest.value.toStringAsFixed(1)}',
      explanation:
          'Interest coverage compares estimated operating profit with reported interest expense.',
      synthetic:
          revenue.metadata.isSynthetic ||
          operatingMargin.metadata.isSynthetic ||
          interest.metadata.isSynthetic,
      explainability: explainability,
    );
  }

  InvestorMetricAssessment _cashToDebt(InvestorPointInTimeSnapshot snapshot) {
    final kind = InvestorMetricKind.cashToDebt;
    final explainability = InvestorMetricExplainabilityCatalog.forKind(kind);

    final debt = _latest(snapshot, InvestorFundamentalMetric.totalDebt);
    final cash = _latest(
      snapshot,
      InvestorFundamentalMetric.cashAndEquivalents,
    );

    if (debt == null || cash == null) {
      return _metricUnavailable(kind, 'Debt and cash are required.');
    }

    double signedScore;
    String currentValue;

    if (debt.value <= 0) {
      signedScore = 100;
      currentValue = 'No debt';
    } else {
      final ratio = cash.value / debt.value;
      currentValue = '${ratio.toStringAsFixed(2)}×';

      signedScore = ratio >= 1
          ? 100
          : ratio >= 0.50
          ? 60
          : ratio >= 0.25
          ? 20
          : ratio >= 0.10
          ? -30
          : -70;
    }

    return _availableMetric(
      kind: kind,
      signedScore: signedScore,
      currentValue: currentValue,
      baselineValue:
          'Cash ${cash.value.toStringAsFixed(1)} · Debt ${debt.value.toStringAsFixed(1)}',
      explanation:
          'Cash is compared with total debt as a simple liquidity cushion, not as a complete maturity analysis.',
      synthetic: debt.metadata.isSynthetic || cash.metadata.isSynthetic,
      explainability: explainability,
    );
  }

  InvestorMetricPoint<InvestorFundamentalMetric>? _latest(
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

  bool _requiresSpecializedFinancialModel(
    InvestorPeerClassification? classification,
  ) {
    if (classification == null) {
      return false;
    }

    final text = '${classification.sector} ${classification.industry}'
        .toLowerCase();

    return text.contains('financial') ||
        text.contains('bank') ||
        text.contains('insurance');
  }

  InvestorMetricAssessment _availableMetric({
    required InvestorMetricKind kind,
    required double signedScore,
    required String currentValue,
    required String baselineValue,
    required String explanation,
    required bool synthetic,
    required MetricExplainability explainability,
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
      explainability: explainability,
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
        currentValue: 'Not enough financial-strength data',
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
        baselineValue: 'Specialized model or point-in-time-safe data required',
        relativeValue: 'Not available',
        explanation: reason,
        unavailableReason: reason,
      ),
      metrics: const [],
    );
  }
}
