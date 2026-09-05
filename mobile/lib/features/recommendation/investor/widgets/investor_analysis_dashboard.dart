import 'package:flutter/material.dart';

import '../../../../shared/widgets/dashboard_card.dart';
import '../../history/historical_setup_validation.dart';
import '../../models/evidence_family.dart';
import '../../models/evidence_result.dart';
import '../../models/metric_explainability.dart';
import '../../models/strategy_recommendation.dart';
import '../../models/strategy_summary.dart';
import '../../presentation/recommendation_presentation.dart';
import '../../widgets/consensus_summary_card.dart';
import '../../widgets/evidence_list.dart';
import '../history/investor_historical_validation_explainability.dart';
import '../models/investor_historical_validation_case.dart';
import '../models/investor_metric_assessment.dart';
import '../models/investor_metric_explainability_catalog.dart';
import '../services/investor_analysis_service.dart';
import '../strategy/investor_market_expectations.dart';
import '../strategy/investor_recommendation_policy.dart';

class InvestorAnalysisDashboard extends StatelessWidget {
  const InvestorAnalysisDashboard({required this.result, super.key});

  final InvestorAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final strategyRecommendation = StrategyRecommendation(
      strategy: StrategyType.investor,
      recommendation: result.recommendationAnalysis.recommendation,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InvestorAnalysisContextCard(result: result),
        InvestorRecommendationCard(result: result),
        ConsensusSummaryCard(
          strategyRecommendation: strategyRecommendation,
          showHistoricalValidation: false,
        ),
        InvestorBusinessStrengthCard(result: result),
        InvestorValuationExpectationsCard(result: result),
        InvestorMarketContextCard(result: result),
        InvestorOwnershipPositioningCard(result: result),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Investor Evidence',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        EvidenceList(
          results: strategyRecommendation.recommendation.evidenceReport.results,
          familySummaries:
              strategyRecommendation.recommendation.consensus.familySummaries,
        ),
        InvestorRiskContextCard(result: result),
        InvestorHistoricalValidationCard(result: result),
      ],
    );
  }
}

class InvestorAnalysisContextCard extends StatelessWidget {
  const InvestorAnalysisContextCard({required this.result, super.key});

  final InvestorAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final analysis = result.recommendationAnalysis;

    return DashboardCard(
      title: 'Investor Analysis Context',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.isSynthetic) ...[
            _SyntheticBanner(),
            const SizedBox(height: 12),
          ],
          Text(
            'Long-term company evidence is the primary decision basis. Market and positioning context are secondary and capped.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoMetric(
                label: 'Analysis Horizon',
                value: 'Months–Years',
                infoTitle: 'Investor Analysis Horizon',
                infoText:
                    'Investor is designed for months-to-years decisions. It does not treat a short candle interval or a fixed candle count as the primary decision basis.',
              ),
              _InfoMetric(
                label: 'Core Evidence',
                value:
                    '${analysis.coreFamilyCount} of ${InvestorRecommendationPolicy.expectedCoreFamilyCount} families',
                infoTitle: 'Core Fundamental Breadth',
                infoText:
                    'Investor action requires at least ${InvestorRecommendationPolicy.minimumCoreFamiliesForAction} of ${InvestorRecommendationPolicy.expectedCoreFamilyCount} breadth-eligible core families, and Valuation must be available. Market and ownership context cannot satisfy this gate.',
              ),
              _InfoMetric(
                label: 'Point-in-Time Safety',
                value: result.snapshot.isPointInTimeSafe ? 'Passed' : 'Failed',
                infoTitle: 'Point-in-Time Safety',
                infoText:
                    'Historical and current Investor inputs are gated by when the information was actually available. Filing-period dates or later revisions must not be treated as though they were known earlier.',
              ),
              _InfoMetric(
                label: 'Data Mode',
                value: result.isSynthetic
                    ? 'Synthetic development data'
                    : 'Production data',
                infoTitle: 'Investor Data Mode',
                infoText:
                    'The current Batch 10 app wiring uses explicitly synthetic development providers. These values validate orchestration and UI behavior and must not be presented as live company fundamentals.',
              ),
              _InfoMetric(
                label: 'Historical Windows',
                value: '6m / 12m / 24m',
                infoTitle: 'Historical Validation Windows',
                infoText:
                    'Investor Historical Setup Validation evaluates mature 6-month, 12-month and 24-month outcomes. The 12-month horizon is mandatory and all usable horizons share one combined ±8 confidence-point cap.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InvestorRecommendationCard extends StatelessWidget {
  const InvestorRecommendationCard({required this.result, super.key});

  final InvestorAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final analysis = result.recommendationAnalysis;
    final recommendation = analysis.recommendation;
    final presentation = RecommendationPresentation.fromType(
      recommendation.type,
    );

    return DashboardCard(
      title: 'Investor Recommendation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(presentation.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  presentation.label,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: presentation.color,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'About Investor recommendation',
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfoDialog(
                  context,
                  title: 'Investor Recommendation',
                  text:
                      'Investor recommendation direction comes from breadth-eligible core fundamentals plus capped contextual direction. BUY and SELL use symmetric thresholds. Historical validation can change confidence only.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(recommendation.oneLineExplanation),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoMetric(
                label: 'Confidence',
                value: '${recommendation.confidenceScore.toStringAsFixed(0)}%',
                infoTitle: 'Investor Confidence',
                infoText:
                    'Confidence is derived from core fundamental evidence and may receive one bounded Historical Setup Validation adjustment. It is not a probability of profit.',
              ),
              _InfoMetric(
                label: 'Signal Direction',
                value: _signedScore(recommendation.directionScore),
                infoTitle: 'Investor Signal Direction',
                infoText:
                    'The signed direction score runs from -100 to +100 after evidence-family de-duplication and the Investor context cap. Negative values oppose the long-term thesis; positive values support it.',
              ),
              _InfoMetric(
                label: 'Core Coverage',
                value: '${(analysis.coreCoverage * 100).toStringAsFixed(0)}%',
                infoTitle: 'Investor Core Coverage',
                infoText:
                    'Core coverage is the share of the six breadth-eligible fundamental families with usable evidence. Context families are excluded from this denominator.',
              ),
              _InfoMetric(
                label: 'Valuation Gate',
                value: analysis.requiredCoreFamiliesAvailable
                    ? 'Available'
                    : 'Missing',
                infoTitle: 'Mandatory Valuation Gate',
                infoText:
                    'Valuation is mandatory for an actionable Investor BUY or SELL. A strong company without usable valuation evidence remains non-actionable.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InvestorBusinessStrengthCard extends StatelessWidget {
  const InvestorBusinessStrengthCard({required this.result, super.key});

  final InvestorAnalysisResult result;

  static const _families = [
    EvidenceFamily.growth,
    EvidenceFamily.profitabilityQuality,
    EvidenceFamily.financialStrength,
    EvidenceFamily.revisions,
    EvidenceFamily.capitalAllocation,
    EvidenceFamily.competitiveDurability,
  ];

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Business Strength',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Company/business evidence is shown separately from market price and positioning.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          for (final family in _families)
            if (result.assessmentFor(family) case final assessment?) ...[
              _FamilySection(
                assessment: assessment,
                note: family == EvidenceFamily.competitiveDurability
                    ? 'Visible analysis only — 0 recommendation weight in v0.12 because the current proxy overlaps Profitability & Quality.'
                    : null,
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class InvestorValuationExpectationsCard extends StatelessWidget {
  const InvestorValuationExpectationsCard({required this.result, super.key});

  final InvestorAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final valuation = result.assessmentFor(EvidenceFamily.valuation);
    final expectations = result.marketExpectations;

    return DashboardCard(
      title: 'Valuation & Expectations',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (valuation != null) _FamilySection(assessment: valuation),
          if (valuation != null) const SizedBox(height: 14),
          _InfoMetric(
            label: 'Market Expectations',
            value: expectations.level.label,
            detail: expectations.explanation,
            infoTitle: 'Market Expectations',
            infoText: _explainabilityText(expectations.explainability),
            width: double.infinity,
          ),
          const SizedBox(height: 8),
          Text(
            'Zero-vote helper: this label adds no evidence vote, direction point or confidence point.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class InvestorMarketContextCard extends StatelessWidget {
  const InvestorMarketContextCard({required this.result, super.key});

  final InvestorAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final assessment = result.assessmentFor(EvidenceFamily.marketContext);

    return DashboardCard(
      title: 'Global Market Context',
      child: assessment == null
          ? const Text('Market context is not available.')
          : _FamilySection(
              assessment: assessment,
              note:
                  'Context is secondary. Market + Ownership direction attribution is collectively capped at 20% and cannot satisfy core breadth.',
            ),
    );
  }
}

class InvestorOwnershipPositioningCard extends StatelessWidget {
  const InvestorOwnershipPositioningCard({required this.result, super.key});

  final InvestorAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final assessment = result.assessmentFor(
      EvidenceFamily.ownershipPositioning,
    );

    return DashboardCard(
      title: 'Ownership & Positioning',
      child: assessment == null
          ? const Text('Ownership & Positioning is not available.')
          : _FamilySection(
              assessment: assessment,
              note:
                  'Published ownership/short-interest trends are contextual only. Raw insider net shares remain non-directional without transaction-code-aware data.',
            ),
    );
  }
}

class InvestorRiskContextCard extends StatelessWidget {
  const InvestorRiskContextCard({required this.result, super.key});

  final InvestorAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final analysis = result.recommendationAnalysis;
    final validation = result.historicalValidation.validation;
    final macro = result.assessmentFor(EvidenceFamily.marketContext);
    InvestorMetricAssessment? vix;

    if (macro != null) {
      for (final metric in macro.metrics) {
        if (metric.kind == InvestorMetricKind.marketImpliedVolatilityContext) {
          vix = metric;
          break;
        }
      }
    }

    return DashboardCard(
      title: 'Investor Risk Context',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This is a transparent context summary, not a full production Risk Engine.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoMetric(
                label: 'Context Direction Share',
                value:
                    '${(analysis.contextDirectionShare * 100).toStringAsFixed(0)}%',
                infoTitle: 'Context Direction Share',
                infoText:
                    'This is the actual post-cap direction-attribution share from Market Context and Ownership & Positioning. The collective maximum is ${(InvestorRecommendationPolicy.maximumContextDirectionShare * 100).toStringAsFixed(0)}%.',
              ),
              _InfoMetric(
                label: 'Core Conflict',
                value: '${(analysis.coreConflict * 100).toStringAsFixed(0)}%',
                infoTitle: 'Core Fundamental Conflict',
                infoText:
                    'Core Conflict measures disagreement among breadth-eligible company fundamentals. At ${(InvestorRecommendationPolicy.materialConflictThreshold * 100).toStringAsFixed(0)}% or above, Investor forces No Clear Direction rather than an actionable BUY/SELL.',
              ),
              _InfoMetric(
                label: 'Historical Confidence Impact',
                value: _signedPoints(validation.confidenceImpactPoints),
                infoTitle: 'Historical Confidence Impact',
                infoText: _explainabilityText(
                  InvestorHistoricalValidationExplainability.definition,
                ),
              ),
              if (vix != null)
                _InfoMetric(
                  label: vix.kind.label,
                  value: vix.currentValue,
                  detail: vix.baselineValue,
                  infoTitle: vix.kind.label,
                  infoText: _explainabilityText(vix.explainability),
                ),
              _InfoMetric(
                label: 'Risk Engine Status',
                value: 'Not implemented',
                infoTitle: 'Risk Engine Status',
                infoText:
                    'TradePilot AI does not yet have a dedicated production Investor Risk Engine. This card exposes validated context and confidence constraints only, so it must not be interpreted as position sizing, stop-loss or portfolio-risk advice.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InvestorHistoricalValidationCard extends StatelessWidget {
  const InvestorHistoricalValidationCard({required this.result, super.key});

  final InvestorAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final historical = result.historicalValidation;
    final validation = historical.validation;
    final explainability =
        InvestorHistoricalValidationExplainability.definition;

    return DashboardCard(
      title: 'Investor Historical Setup Validation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(validation.summary),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoMetric(
                label: 'Historical Verdict',
                value: _historicalVerdictLabel(validation.verdict),
                infoTitle: 'Historical Verdict',
                infoText: _explainabilityText(explainability),
              ),
              _InfoMetric(
                label: 'Confidence Impact',
                value: _signedPoints(validation.confidenceImpactPoints),
                infoTitle: 'Historical Confidence Impact',
                infoText: _explainabilityText(explainability),
              ),
              _InfoMetric(
                label: 'Matched Setups',
                value: validation.matchedCases.toString(),
                infoTitle: 'Matched Historical Setups',
                infoText:
                    'Matched setups are de-overlapped, point-in-time-safe same-stock Investor fingerprints that pass the minimum similarity threshold. At least 8 are required.',
              ),
              _InfoMetric(
                label: 'Average Similarity',
                value:
                    '${(validation.averageSimilarity * 100).toStringAsFixed(0)}%',
                infoTitle: 'Historical Similarity',
                infoText:
                    'Similarity compares only the six breadth-eligible core Investor families. Context and zero-vote helpers cannot increase the similarity score.',
              ),
            ],
          ),
          if (historical.horizons.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Mature outcome windows',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final horizon in historical.horizons) ...[
              _HistoricalHorizonSection(summary: horizon),
              const SizedBox(height: 10),
            ],
          ],
          const SizedBox(height: 4),
          Text(
            'Historical similarity is not a probability of profit and cannot change recommendation direction by itself.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _HistoricalHorizonSection extends StatelessWidget {
  const _HistoricalHorizonSection({required this.summary});

  final InvestorHistoricalHorizonSummary summary;

  @override
  Widget build(BuildContext context) {
    final explainability =
        InvestorHistoricalValidationExplainability.definition;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary.horizon.label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoMetric(
                label: 'Matched Cases',
                value: summary.matchedCases.toString(),
                infoTitle: '${summary.horizon.label} Matched Cases',
                infoText: _explainabilityText(explainability),
              ),
              _InfoMetric(
                label: 'Absolute Edge',
                value:
                    '${_signedNumber(summary.absoluteEdgePercentagePoints)} pp',
                infoTitle: '${summary.horizon.label} Absolute Edge',
                infoText:
                    'Matched same-direction outcome rate minus the stock’s broader same-direction historical baseline for this horizon.',
              ),
              _InfoMetric(
                label: 'Benchmark-Relative Edge',
                value:
                    '${_signedNumber(summary.relativeEdgePercentagePoints)} pp',
                infoTitle: '${summary.horizon.label} Benchmark-Relative Edge',
                infoText:
                    'Matched benchmark-relative follow-through rate minus the stock’s broader same-direction benchmark-relative baseline for this horizon.',
              ),
              _InfoMetric(
                label: 'Reliability',
                value: '${(summary.reliability * 100).toStringAsFixed(0)}%',
                infoTitle: '${summary.horizon.label} Reliability',
                infoText:
                    'Reliability is reduced when the effective sample is small or average similarity is close to the minimum threshold. It gates the horizon support score separately from direction.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FamilySection extends StatelessWidget {
  const _FamilySection({required this.assessment, this.note});

  final InvestorEvidenceAssessment assessment;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final evidence = assessment.evidence;
    final explainability = evidence.definition.explainability;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  evidence.definition.family.label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${_directionLabel(evidence.direction)} · ${evidence.score.toStringAsFixed(0)}/100',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              IconButton(
                tooltip: 'About ${evidence.definition.family.label}',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.info_outline, size: 18),
                onPressed: explainability == null
                    ? null
                    : () => _showInfoDialog(
                        context,
                        title: evidence.definition.family.label,
                        text: _explainabilityText(explainability),
                      ),
              ),
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: 4),
            Text(note!, style: Theme.of(context).textTheme.bodySmall),
          ],
          if (assessment.metrics.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final metric in assessment.metrics) ...[
              _InvestorMetricRow(metric: metric),
              const SizedBox(height: 6),
            ],
          ],
        ],
      ),
    );
  }
}

class _InvestorMetricRow extends StatelessWidget {
  const _InvestorMetricRow({required this.metric});

  final InvestorMetricAssessment metric;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            metric.kind.label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(metric.currentValue),
              if (metric.baselineValue.isNotEmpty)
                Text(
                  metric.baselineValue,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'About ${metric.kind.label}',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.info_outline, size: 18),
          onPressed: () => _showInfoDialog(
            context,
            title: metric.kind.label,
            text: _explainabilityText(metric.explainability),
          ),
        ),
      ],
    );
  }
}

class _InfoMetric extends StatelessWidget {
  const _InfoMetric({
    required this.label,
    required this.value,
    required this.infoTitle,
    required this.infoText,
    this.detail,
    this.width = 215,
  });

  final String label;
  final String value;
  final String? detail;
  final String infoTitle;
  final String infoText;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                tooltip: 'About $label',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                icon: const Icon(Icons.info_outline, size: 18),
                onPressed: () =>
                    _showInfoDialog(context, title: infoTitle, text: infoText),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (detail != null && detail!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(detail!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _SyntheticBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.science_outlined, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Synthetic development data — Investor UI is active for validation, but these fundamentals, estimates, macro inputs and ownership values are not live production data.',
            ),
          ),
        ],
      ),
    );
  }
}

String _directionLabel(EvidenceDirection direction) {
  return switch (direction) {
    EvidenceDirection.bullish => 'Supportive',
    EvidenceDirection.bearish => 'Opposing',
    EvidenceDirection.neutral => 'Neutral',
    EvidenceDirection.unknown => 'Unavailable',
  };
}

String _signedScore(double value) {
  final prefix = value > 0 ? '+' : '';
  return '$prefix${value.toStringAsFixed(0)} / 100';
}

String _signedPoints(double value) {
  final prefix = value > 0 ? '+' : '';
  return '$prefix${value.toStringAsFixed(1)} pts';
}

String _signedNumber(double value) {
  final prefix = value > 0 ? '+' : '';
  return '$prefix${value.toStringAsFixed(1)}';
}

String _historicalVerdictLabel(HistoricalValidationVerdict verdict) {
  return switch (verdict) {
    HistoricalValidationVerdict.supports => 'Supports confidence',
    HistoricalValidationVerdict.opposes => 'Reduces confidence',
    HistoricalValidationVerdict.mixed => 'Mixed / neutral',
    HistoricalValidationVerdict.unavailable => 'Not available',
  };
}

String _explainabilityText(MetricExplainability explainability) {
  final sections = <String>[
    'What it is\n${explainability.whatItIs}',
    'How it is calculated\n${explainability.calculation}',
    'Why it matters\n${explainability.whyItMatters}',
    if (explainability.supportiveInterpretation case final text?)
      'Supportive interpretation\n$text',
    if (explainability.opposingInterpretation case final text?)
      'Opposing interpretation\n$text',
    if (explainability.neutralInterpretation case final text?)
      'Neutral / unavailable interpretation\n$text',
    'Recommendation impact\n${explainability.recommendationImpact}',
    if (explainability.boundedImpact case final text?) 'Bounded impact\n$text',
    'Limitations\n${explainability.limitations}',
  ];

  return sections.join('\n\n');
}

Future<void> _showInfoDialog(
  BuildContext context, {
  required String title,
  required String text,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: Text(text)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
