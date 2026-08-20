import 'package:flutter/material.dart';

import '../models/evidence_contribution.dart';
import '../models/evidence_family.dart';
import '../models/scoring_result.dart';

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
          'Direction influence shows what share of the final directional '
          'decision came from each independent evidence group. Confidence '
          'share shows how much of the evidence-derived confidence came from '
          'that group after coverage, alignment, and reliability adjustments. '
          'Historical validation is reconciled separately.',
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
          'evidence groups. This prevents indicators such as Candle Trend, '
          'EMA Structure, and Multi-Timeframe Trend from each receiving a '
          'full independent vote.\n\n'
          'Direction influence percentages are calculated after that '
          'de-duplication step. Supporting and opposing groups together '
          'account for 100% of the family-level directional influence.\n\n'
          'Confidence share distributes evidence-derived confidence across the '
          'evidence groups that built its evidence-strength base. Coverage, '
          'alignment, and reliability adjustments are applied before that '
          'attribution. Historical setup validation is shown separately so it '
          'cannot be mistaken for another indicator vote. Confidence is not a '
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
          child: Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                '${_directionRelationship()} '
                '${(contribution.directionShare * 100).toStringAsFixed(0)}%',
              ),
              Text(
                'Evidence confidence share '
                '${(contribution.confidenceShare * 100).toStringAsFixed(0)}%',
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
              '${contribution.confidenceContributionPoints.toStringAsFixed(1)} evidence-confidence pts',
              style: Theme.of(context).textTheme.bodySmall,
            ),
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
          Text(
            'Direction: ${_signed(provider.directionImpactPoints)} pts · '
            '${(provider.directionShareWithinFamily * 100).toStringAsFixed(0)}% '
            'of ${_familyLabel(provider.family)} calculation',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Evidence confidence: '
            '${provider.confidenceContributionPoints.toStringAsFixed(1)} pts · '
            '${(provider.confidenceShare * 100).toStringAsFixed(0)}% of evidence-derived confidence',
            style: Theme.of(context).textTheme.bodySmall,
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

class _ConfidenceCalculation extends StatelessWidget {
  const _ConfidenceCalculation({required this.consensus});

  final ScoringResult consensus;

  @override
  Widget build(BuildContext context) {
    final evidenceModifiers = consensus.confidenceModifiers
        .where((modifier) => modifier.label != 'Historical setup validation')
        .toList(growable: false);
    final externalModifiers = consensus.confidenceModifiers
        .where((modifier) => modifier.label == 'Historical setup validation')
        .toList(growable: false);

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: const Text('Confidence calculation'),
      subtitle: const Text(
        'See how evidence strength becomes evidence confidence, then how external validation adjusts the final score.',
      ),
      children: [
        _CalculationRow(
          label: 'Evidence-strength baseline',
          value: '${consensus.baseEvidenceStrength.toStringAsFixed(1)}%',
        ),
        ...evidenceModifiers.map(
          (modifier) => _CalculationRow(
            label: modifier.label,
            value: '${_signedImpact(modifier.impactPoints)} pts',
          ),
        ),
        if (externalModifiers.isNotEmpty) ...[
          const Divider(),
          _CalculationRow(
            label: 'Evidence-derived confidence',
            value: '${consensus.evidenceConfidence.toStringAsFixed(1)}%',
          ),
          ...externalModifiers.map(
            (modifier) => _CalculationRow(
              label: modifier.label,
              value: '${_signedImpact(modifier.impactPoints)} pts',
            ),
          ),
        ],
        const Divider(),
        _CalculationRow(
          label: 'Final confidence',
          value: '${consensus.confidence.toStringAsFixed(1)}%',
          emphasize: true,
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
  });

  final String label;
  final String value;
  final bool emphasize;

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
  }
}
