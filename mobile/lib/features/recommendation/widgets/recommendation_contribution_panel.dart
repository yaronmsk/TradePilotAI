import 'package:flutter/material.dart';

import '../models/evidence_contribution.dart';
import '../models/evidence_family.dart';
import '../models/metric_explainability.dart';
import '../models/recommendation_attribution_explainability.dart';
import '../models/scoring_result.dart';
import 'metric_explainability_dialog.dart';

class RecommendationContributionPanel extends StatelessWidget {
  const RecommendationContributionPanel({required this.consensus, super.key});

  final ScoringResult consensus;

  @override
  Widget build(BuildContext context) {
    if (consensus.familyContributions.isEmpty) {
      return const SizedBox.shrink();
    }

    final contributions = [...consensus.familyContributions]
      ..sort((a, b) => b.directionShare.compareTo(a.directionShare));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Evidence Contribution',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              tooltip: 'About Evidence Contribution',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.info_outline, size: 19),
              onPressed: () => _showContributionInfo(context),
            ),
          ],
        ),
        Text(
          'Direction influence is calculated at the independent-family '
          'level after correlated indicators are grouped and capped. Active '
          'family direction shares account for 100% of the current directional '
          'basis. Evidence confidence is separate, while Event Risk and '
          'Historical Validation appear as bounded confidence-only adjustments.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        ...contributions.map(
          (contribution) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _FamilyContributionTile(
              contribution: contribution,
              finalDirectionScore: consensus.directionScore ?? 0,
            ),
          ),
        ),
        const SizedBox(height: 2),
        _ConfidenceCalculation(consensus: consensus),
      ],
    );
  }

  Future<void> _showContributionInfo(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Evidence Contribution'),
        content: const Text(
          'TradePilot first groups correlated indicators into independent '
          'evidence families so related indicators do not each receive a full '
          'independent vote. Family caps are applied before attribution.\n\n'
          'Direction influence percentages are family-level percentages of '
          'the current post-cap directional basis. Supporting and opposing '
          'families together account for 100% when directional evidence '
          'exists.\n\n'
          'Provider details use signed direction points rather than provider '
          'recommendation percentages, because providers inside one family '
          'can oppose and partially cancel each other.\n\n'
          'Evidence confidence is attributed separately from direction. Event '
          'Risk and Historical Validation are shown as bounded point '
          'adjustments and never become indicator votes. Confidence is not a '
          'guaranteed probability of profit.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _FamilyContributionTile extends StatelessWidget {
  const _FamilyContributionTile({
    required this.contribution,
    required this.finalDirectionScore,
  });

  final EvidenceFamilyContribution contribution;
  final double finalDirectionScore;

  @override
  Widget build(BuildContext context) {
    final providers = [...contribution.providers]
      ..sort(
        (a, b) => b.directionImpactPoints.abs().compareTo(
          a.directionImpactPoints.abs(),
        ),
      );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          _familyLabel(contribution.family),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AttributionMetricLine(
                text:
                    '${_directionRelationship()} '
                    '${(contribution.directionShare * 100).toStringAsFixed(0)}%',
                tooltip: 'About Direction influence',
                title: 'Direction influence',
                explainability:
                    RecommendationAttributionExplainability.directionInfluence,
              ),
              _AttributionMetricLine(
                text:
                    'Evidence confidence share '
                    '${(contribution.confidenceShare * 100).toStringAsFixed(0)}%',
                tooltip: 'About Evidence confidence share',
                title: 'Evidence confidence share',
                explainability: RecommendationAttributionExplainability
                    .evidenceConfidenceShare,
              ),
            ],
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Exact group impact: '
              '${_signed(contribution.directionImpactPoints)} direction pts · '
              '${contribution.confidenceContributionPoints.toStringAsFixed(1)} '
              'evidence-confidence pts',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Provider detail below uses signed points only. Provider-level '
            'direction percentages are intentionally not shown because '
            'correlated providers share this family cap.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          ...providers.map(
            (provider) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ProviderContributionRow(provider: provider),
            ),
          ),
        ],
      ),
    );
  }

  String _directionRelationship() {
    if (contribution.directionImpactPoints.abs() < 0.0001) {
      return 'Neutral';
    }

    if (finalDirectionScore > 5) {
      return contribution.directionImpactPoints > 0 ? 'Supports' : 'Opposes';
    }

    if (finalDirectionScore < -5) {
      return contribution.directionImpactPoints < 0 ? 'Supports' : 'Opposes';
    }

    return contribution.directionImpactPoints > 0 ? 'Bullish' : 'Bearish';
  }

  String _signed(double value) {
    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(1)}';
  }
}

class _ProviderContributionRow extends StatelessWidget {
  const _ProviderContributionRow({required this.provider});

  final EvidenceContribution provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.providerName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          _AttributionMetricLine(
            text:
                'Direction impact: '
                '${_signed(provider.directionImpactPoints)} pts',
            tooltip: 'About Provider direction impact',
            title: 'Provider direction impact',
            explainability:
                RecommendationAttributionExplainability.providerDirectionImpact,
          ),
          _AttributionMetricLine(
            text:
                'Evidence confidence: '
                '${provider.confidenceContributionPoints.toStringAsFixed(1)} pts',
            tooltip: 'About Provider confidence contribution',
            title: 'Provider confidence contribution',
            explainability: RecommendationAttributionExplainability
                .providerConfidenceContribution,
          ),
        ],
      ),
    );
  }

  String _signed(double value) {
    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(1)}';
  }
}

class _AttributionMetricLine extends StatelessWidget {
  const _AttributionMetricLine({
    required this.text,
    required this.tooltip,
    required this.title,
    required this.explainability,
  });

  final String text;
  final String tooltip;
  final String title;
  final MetricExplainability explainability;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
        IconButton(
          tooltip: tooltip,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          icon: const Icon(Icons.info_outline, size: 17),
          onPressed: () {
            MetricExplainabilityDialog.show(
              context,
              title: title,
              explainability: explainability,
            );
          },
        ),
      ],
    );
  }
}

class _ConfidenceCalculation extends StatelessWidget {
  const _ConfidenceCalculation({required this.consensus});

  final ScoringResult consensus;

  @override
  Widget build(BuildContext context) {
    final hasEventRisk = consensus.confidenceModifiers.any(
      (modifier) => modifier.source == ConfidenceModifierSource.eventRisk,
    );

    final hasHistoricalValidation = consensus.confidenceModifiers.any(
      (modifier) =>
          modifier.source == ConfidenceModifierSource.historicalValidation,
    );

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: const Text('Confidence calculation'),
      subtitle: const Text(
        'Evidence confidence is shown separately from Event Risk and '
        'Historical Validation so confidence-only adjustments cannot be '
        'mistaken for directional evidence.',
      ),
      children: [
        _CalculationRow(
          label: 'Evidence-strength baseline',
          value: '${consensus.baseEvidenceStrength.toStringAsFixed(1)}%',
          infoTitle: 'Evidence-strength baseline',
          explainability:
              RecommendationAttributionExplainability.evidenceStrengthBaseline,
        ),
        _CalculationRow(
          label: 'Evidence-quality adjustments',
          value:
              '${_signedImpact(consensus.evidenceQualityAdjustmentPoints)} pts',
          infoTitle: 'Evidence-quality adjustments',
          explainability:
              RecommendationAttributionExplainability.evidenceQualityAdjustment,
        ),
        _CalculationRow(
          label: 'Evidence-derived confidence',
          value: '${consensus.evidenceConfidence.toStringAsFixed(1)}%',
          infoTitle: 'Evidence-derived confidence',
          explainability:
              RecommendationAttributionExplainability.evidenceDerivedConfidence,
        ),
        if (hasEventRisk) ...[
          const Divider(),
          _CalculationRow(
            label: 'Event Risk adjustment',
            value: '${_signedImpact(consensus.eventRiskAdjustmentPoints)} pts',
            infoTitle: 'Event Risk adjustment',
            explainability:
                RecommendationAttributionExplainability.eventRiskAdjustment,
          ),
        ],
        if (hasHistoricalValidation)
          _CalculationRow(
            label: 'Historical Validation adjustment',
            value:
                '${_signedImpact(consensus.historicalValidationAdjustmentPoints)} pts',
            infoTitle: 'Historical Validation adjustment',
            explainability: RecommendationAttributionExplainability
                .historicalValidationAdjustment,
          ),
        const Divider(),
        _CalculationRow(
          label: 'Final confidence',
          value: '${consensus.confidence.toStringAsFixed(1)}%',
          emphasize: true,
          infoTitle: 'Final confidence',
          explainability:
              RecommendationAttributionExplainability.finalConfidence,
        ),
      ],
    );
  }

  String _signedImpact(double value) {
    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(1)}';
  }
}

class _CalculationRow extends StatelessWidget {
  const _CalculationRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.infoTitle,
    this.explainability,
  });

  final String label;
  final String value;
  final bool emphasize;
  final String? infoTitle;
  final MetricExplainability? explainability;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 12),
          Text(value, style: style),
          if (explainability != null && infoTitle != null) ...[
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'About $infoTitle',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              icon: const Icon(Icons.info_outline, size: 17),
              onPressed: () {
                MetricExplainabilityDialog.show(
                  context,
                  title: infoTitle!,
                  explainability: explainability!,
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

String _familyLabel(EvidenceFamily family) {
  switch (family) {
    case EvidenceFamily.generic:
      return 'Other Evidence';
    case EvidenceFamily.trend:
      return 'Trend';
    case EvidenceFamily.momentum:
      return 'Momentum';
    case EvidenceFamily.participation:
      return 'Volume Activity';
    case EvidenceFamily.priceStructure:
      return 'Price Structure';
    case EvidenceFamily.volatility:
      return 'Entry & Volatility';
    case EvidenceFamily.marketContext:
      return 'Market Context';
    case EvidenceFamily.fundamentals:
      return 'Fundamentals';
    case EvidenceFamily.sentiment:
      return 'Sentiment';
    case EvidenceFamily.growth:
      return 'Growth';
    case EvidenceFamily.profitabilityQuality:
      return 'Profitability & Quality';
    case EvidenceFamily.financialStrength:
      return 'Financial Strength';
    case EvidenceFamily.valuation:
      return 'Valuation';
    case EvidenceFamily.revisions:
      return 'Revisions';
    case EvidenceFamily.competitiveDurability:
      return 'Competitive Durability';
    case EvidenceFamily.capitalAllocation:
      return 'Capital Allocation';
    case EvidenceFamily.ownershipPositioning:
      return 'Ownership & Positioning';
  }
}
