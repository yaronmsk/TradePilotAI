import 'package:flutter/material.dart';

import '../../../shared/widgets/dashboard_card.dart';
import '../models/evidence_family.dart';
import '../models/evidence_family_summary.dart';
import '../models/evidence_result.dart';
import '../models/scoring_result.dart';
import '../models/strategy_recommendation.dart';
import 'recommendation_contribution_panel.dart';

class ConsensusSummaryCard extends StatelessWidget {
  const ConsensusSummaryCard({required this.strategyRecommendation, super.key});

  final StrategyRecommendation strategyRecommendation;

  @override
  Widget build(BuildContext context) {
    final recommendation = strategyRecommendation.recommendation;
    final consensus = recommendation.consensus;

    return DashboardCard(
      title: '${strategyRecommendation.title} Recommendation Insight',
      child: consensus.familySummaries.isEmpty
          ? const Text('Waiting for consensus analysis.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A simple view of how strongly the evidence leans, how much '
                  'confidence TradePilot has in that conclusion, and whether '
                  'independent evidence groups agree.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _InsightMetric(
                      label: 'Signal Strength',
                      value: _signalStrengthLabel(
                        consensus.directionScore ?? 0,
                      ),
                      detail: _signalStrengthDetail(
                        consensus.directionScore ?? 0,
                      ),
                      infoTitle: 'Signal Strength',
                      infoText:
                          'Signal Strength shows how strongly the combined '
                          'evidence leans bullish or bearish after related '
                          'indicators are grouped so they do not count as '
                          'separate independent votes. The internal score '
                          'ranges from -100 (fully bearish) to +100 (fully '
                          'bullish).',
                    ),
                    _InsightMetric(
                      label: 'Confidence',
                      value: _confidenceLabel(consensus.confidence),
                      detail: '${consensus.confidence.toStringAsFixed(0)}%',
                      infoTitle: 'Confidence',
                      infoText:
                          'Confidence reflects evidence strength, data '
                          'coverage, agreement between independent evidence '
                          'groups, and reliability. It is not a guaranteed '
                          'probability of profit.',
                    ),
                    _InsightMetric(
                      label: 'Signal Alignment',
                      value: _alignmentLabel(consensus),
                      detail: _alignmentDetail(consensus),
                      infoTitle: 'Signal Alignment',
                      infoText:
                          'Signal Alignment describes whether independent '
                          'types of evidence point in the same direction. '
                          'Indicators that belong to the same evidence group '
                          'are combined first, helping prevent correlated '
                          'signals from creating false confidence.',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _WhyConfidencePanel(consensus: consensus),
                const SizedBox(height: 16),
                RecommendationContributionPanel(consensus: consensus),
                const SizedBox(height: 8),
                _TechnicalDetails(consensus: consensus),
              ],
            ),
    );
  }

  String _signalStrengthLabel(double score) {
    final magnitude = score.abs();
    final direction = score > 5
        ? 'Bullish'
        : score < -5
        ? 'Bearish'
        : 'Balanced';

    if (direction == 'Balanced') {
      return 'Balanced';
    }

    if (magnitude >= 75) {
      return 'Very Strong $direction';
    }

    if (magnitude >= 50) {
      return 'Strong $direction';
    }

    if (magnitude >= 25) {
      return 'Moderate $direction';
    }

    return 'Slight $direction';
  }

  String _signalStrengthDetail(double score) {
    final prefix = score > 0 ? '+' : '';
    return '$prefix${score.toStringAsFixed(0)} / 100';
  }

  String _confidenceLabel(double confidence) {
    if (confidence >= 80) {
      return 'High';
    }

    if (confidence >= 60) {
      return 'Moderate';
    }

    return 'Low';
  }

  String _alignmentLabel(ScoringResult consensus) {
    if (consensus.independentFamilyCount <= 1) {
      return 'Limited Confirmation';
    }

    if (consensus.conflict >= 0.60) {
      return 'Conflicting';
    }

    if (consensus.agreement >= 0.80) {
      return 'Strongly Aligned';
    }

    if (consensus.agreement >= 0.65) {
      return 'Mostly Aligned';
    }

    return 'Mixed';
  }

  String _alignmentDetail(ScoringResult consensus) {
    final leadingDirection = _leadingDirection(consensus.directionScore ?? 0);
    final supportingCount = consensus.familySummaries
        .where((family) => family.direction == leadingDirection)
        .length;

    if (leadingDirection == EvidenceDirection.neutral) {
      return '${consensus.independentFamilyCount} evidence groups evaluated';
    }

    return '$supportingCount of ${consensus.independentFamilyCount} groups support the lead';
  }

  EvidenceDirection _leadingDirection(double score) {
    if (score > 5) {
      return EvidenceDirection.bullish;
    }

    if (score < -5) {
      return EvidenceDirection.bearish;
    }

    return EvidenceDirection.neutral;
  }
}

class _InsightMetric extends StatelessWidget {
  const _InsightMetric({
    required this.label,
    required this.value,
    required this.detail,
    required this.infoTitle,
    required this.infoText,
  });

  final String label;
  final String value;
  final String detail;
  final String infoTitle;
  final String infoText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
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
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(detail, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
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
        content: Text(text),
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

class _WhyConfidencePanel extends StatelessWidget {
  const _WhyConfidencePanel({required this.consensus});

  final ScoringResult consensus;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why this confidence?',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(_summaryText(consensus)),
        ],
      ),
    );
  }

  String _summaryText(ScoringResult consensus) {
    final leadingDirection = _leadingDirection(consensus.directionScore ?? 0);
    final supporting = <String>[];
    final opposing = <String>[];
    final neutral = <String>[];

    for (final family in consensus.familySummaries) {
      final label = _friendlyFamilyLabel(family.family);

      if (leadingDirection == EvidenceDirection.neutral) {
        if (family.direction == EvidenceDirection.neutral) {
          neutral.add(label);
        } else {
          opposing.add(label);
        }
        continue;
      }

      if (family.direction == leadingDirection) {
        supporting.add(label);
      } else if (family.direction == EvidenceDirection.neutral) {
        neutral.add(label);
      } else {
        opposing.add(label);
      }
    }

    final parts = <String>[];

    if (leadingDirection == EvidenceDirection.neutral) {
      parts.add(
        'The independent evidence groups do not currently produce a clear '
        'bullish or bearish edge.',
      );
    } else {
      final directionWord = leadingDirection == EvidenceDirection.bullish
          ? 'bullish'
          : 'bearish';

      if (supporting.isNotEmpty) {
        parts.add(
          '${_joinLabels(supporting)} ${supporting.length == 1 ? 'supports' : 'support'} '
          'the $directionWord view.',
        );
      }

      if (opposing.isNotEmpty) {
        parts.add(
          '${_joinLabels(opposing)} ${opposing.length == 1 ? 'opposes' : 'oppose'} it.',
        );
      } else {
        parts.add('No independent evidence group materially opposes it.');
      }
    }

    if (neutral.isNotEmpty) {
      parts.add(
        '${_joinLabels(neutral)} ${neutral.length == 1 ? 'is' : 'are'} neutral.',
      );
    }

    parts.add(_coverageSentence(consensus));

    if (consensus.conflict >= 0.60) {
      parts.add(
        'Meaningful disagreement between evidence groups reduces confidence.',
      );
    } else if (consensus.agreement >= 0.80 &&
        consensus.independentFamilyCount > 1) {
      parts.add(
        'Strong agreement between independent evidence groups supports confidence.',
      );
    }

    return parts.join(' ');
  }

  String _coverageSentence(ScoringResult consensus) {
    final percent = (consensus.familyCoverage * 100).toStringAsFixed(0);

    if (consensus.familyCoverage >= 0.80) {
      return 'Evidence-group coverage is strong at $percent%.';
    }

    if (consensus.familyCoverage >= 0.60) {
      return 'Evidence-group coverage is moderate at $percent%.';
    }

    return 'Evidence-group coverage is limited at $percent%, which reduces confidence.';
  }

  EvidenceDirection _leadingDirection(double score) {
    if (score > 5) {
      return EvidenceDirection.bullish;
    }

    if (score < -5) {
      return EvidenceDirection.bearish;
    }

    return EvidenceDirection.neutral;
  }

  String _friendlyFamilyLabel(EvidenceFamily family) {
    switch (family) {
      case EvidenceFamily.generic:
        return 'Other evidence';
      case EvidenceFamily.trend:
        return 'Trend';
      case EvidenceFamily.momentum:
        return 'Momentum';
      case EvidenceFamily.participation:
        return 'Volume activity';
      case EvidenceFamily.priceStructure:
        return 'Price structure';
      case EvidenceFamily.volatility:
        return 'Volatility';
      case EvidenceFamily.marketContext:
        return 'Market context';
      case EvidenceFamily.fundamentals:
        return 'Fundamentals';
      case EvidenceFamily.sentiment:
        return 'Sentiment';
    }
  }

  String _joinLabels(List<String> labels) {
    if (labels.length == 1) {
      return labels.first;
    }

    if (labels.length == 2) {
      return '${labels.first} and ${labels.last}';
    }

    return '${labels.sublist(0, labels.length - 1).join(', ')}, and ${labels.last}';
  }
}

class _TechnicalDetails extends StatelessWidget {
  const _TechnicalDetails({required this.consensus});

  final ScoringResult consensus;

  @override
  Widget build(BuildContext context) {
    final averageReliability = consensus.familySummaries.isEmpty
        ? 0.0
        : consensus.familySummaries
                  .map((family) => family.reliability)
                  .reduce((a, b) => a + b) /
              consensus.familySummaries.length;

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: const Text('How was this calculated?'),
      subtitle: const Text(
        'View support, coverage, reliability, and evidence-group details.',
      ),
      children: [
        _DetailRow(
          label: 'Bullish evidence',
          value: '${consensus.bullishSupportPercent.toStringAsFixed(0)}%',
        ),
        _DetailRow(
          label: 'Bearish evidence',
          value: '${consensus.bearishSupportPercent.toStringAsFixed(0)}%',
        ),
        _DetailRow(
          label: 'Evidence groups',
          value: consensus.independentFamilyCount.toString(),
        ),
        _DetailRow(
          label: 'Evidence-group coverage',
          value: '${(consensus.familyCoverage * 100).toStringAsFixed(0)}%',
        ),
        _DetailRow(
          label: 'Provider coverage',
          value: '${(consensus.coverage * 100).toStringAsFixed(0)}%',
        ),
        _DetailRow(
          label: 'Average reliability',
          value: '${(averageReliability * 100).toStringAsFixed(0)}%',
        ),
        _DetailRow(
          label: 'Internal agreement',
          value: '${(consensus.agreement * 100).toStringAsFixed(0)}%',
        ),
        _DetailRow(
          label: 'Conflict level',
          value: '${(consensus.conflict * 100).toStringAsFixed(0)}%',
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Evidence groups',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        ...consensus.familySummaries.map(
          (family) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _FamilyRow(summary: family),
          ),
        ),
        if (consensus.warnings.isNotEmpty) ...[
          const SizedBox(height: 4),
          const Divider(),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'What reduces confidence',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          ...consensus.warnings.map(
            (warning) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('• $warning'),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _FamilyRow extends StatelessWidget {
  const _FamilyRow({required this.summary});

  final EvidenceFamilySummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              _friendlyFamilyLabel(summary.family),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              '${_directionText(summary.direction)} '
              '${_signed(summary.directionScore)}',
            ),
          ),
          Text(
            '${summary.evidenceCount} signal${summary.evidenceCount == 1 ? '' : 's'}',
          ),
        ],
      ),
    );
  }

  String _friendlyFamilyLabel(EvidenceFamily family) {
    switch (family) {
      case EvidenceFamily.generic:
        return 'Other';
      case EvidenceFamily.trend:
        return 'Trend';
      case EvidenceFamily.momentum:
        return 'Momentum';
      case EvidenceFamily.participation:
        return 'Volume activity';
      case EvidenceFamily.priceStructure:
        return 'Price structure';
      case EvidenceFamily.volatility:
        return 'Volatility';
      case EvidenceFamily.marketContext:
        return 'Market context';
      case EvidenceFamily.fundamentals:
        return 'Fundamentals';
      case EvidenceFamily.sentiment:
        return 'Sentiment';
    }
  }

  String _directionText(EvidenceDirection direction) {
    switch (direction) {
      case EvidenceDirection.bullish:
        return 'Bullish';
      case EvidenceDirection.bearish:
        return 'Bearish';
      case EvidenceDirection.neutral:
        return 'Neutral';
      case EvidenceDirection.unknown:
        return 'Unknown';
    }
  }

  String _signed(double value) {
    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(0)}';
  }
}
