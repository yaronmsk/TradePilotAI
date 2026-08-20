import 'package:flutter/material.dart';

import '../history/historical_setup_match.dart';
import '../history/historical_setup_validation.dart';

class HistoricalSetupValidationPanel extends StatelessWidget {
  const HistoricalSetupValidationPanel({required this.validation, super.key});

  final HistoricalSetupValidation validation;

  @override
  Widget build(BuildContext context) {
    if (validation.status == HistoricalValidationStatus.unavailable) {
      return const SizedBox.shrink();
    }

    final symbol = validation.symbol.isEmpty ? 'This stock' : validation.symbol;
    final shortWindow = validation.outcomeWindowShortLabel.isEmpty
        ? validation.outcomeWindowLabel
        : validation.outcomeWindowShortLabel;

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
                  'Historical Setup Check',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              _VerdictChip(validation: validation),
              IconButton(
                tooltip: 'About Historical Setup Check',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.info_outline, size: 19),
                onPressed: () => _showInfo(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            validation.summary,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Text(
            'Based on ${validation.matchedCases} similar cases • '
            '${(validation.averageSimilarity * 100).toStringAsFixed(0)}% match quality',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (validation.status == HistoricalValidationStatus.available) ...[
            _NarrativeMetric(
              title:
                  'Similar historical setups: ${(validation.alignedOutcomeRate * 100).toStringAsFixed(0)}% follow-through',
              description:
                  'In ${(validation.alignedOutcomeRate * 100).toStringAsFixed(0)}% of similar past setups from $symbol and other stocks with the same ${validation.stockProfileLabel} Stock Profile, price moved in the recommendation direction during the following $shortWindow.',
            ),
            const SizedBox(height: 10),
            _NarrativeMetric(
              title:
                  '$symbol under comparable conditions: ${(validation.controlAlignedOutcomeRate * 100).toStringAsFixed(0)}% follow-through',
              description:
                  'Across $symbol\'s historical data under the same ${validation.stockProfileLabel} Stock Profile, volatility regime, and market environment, but without requiring today\'s specific evidence setup, price moved in the recommendation direction during the following $shortWindow in ${(validation.controlAlignedOutcomeRate * 100).toStringAsFixed(0)}% of cases.',
            ),
            const SizedBox(height: 10),
            _NarrativeMetric(
              title:
                  'Historical Difference: ${_signedPercentPoints(validation.edgeVsControlPercentagePoints)}',
              description: _differenceDescription(
                symbol,
                validation.edgeVsControlPercentagePoints,
              ),
            ),
            const SizedBox(height: 10),
            _NarrativeMetric(
              title:
                  'Confidence effect: ${_signedConfidencePoints(validation.confidenceImpactPoints)}',
              description:
                  'Historical validation adjusts confidence only. It does not change the recommendation direction by itself.',
            ),
          ] else ...[
            Text(
              validation.status == HistoricalValidationStatus.neutralSignal
                  ? 'The current direction is too balanced to score historical follow-through.'
                  : 'Historical comparison data is currently too limited to influence confidence.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 10),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 4),
            title: const Text('How was this calculated?'),
            subtitle: Text(validation.outcomeWindowLabel),
            children: [
              _DetailRow(
                label: 'Similar setup cases',
                value: '${validation.matchedCases}',
              ),
              _DetailRow(
                label: 'Effective setup sample',
                value: validation.effectiveSampleSize.toStringAsFixed(0),
              ),
              _DetailRow(
                label: 'Average setup match quality',
                value:
                    '${(validation.averageSimilarity * 100).toStringAsFixed(0)}%',
              ),
              _DetailRow(
                label: '$symbol comparison observations',
                value: '${validation.comparisonCases}',
              ),
              if (validation.status ==
                  HistoricalValidationStatus.available) ...[
                _DetailRow(
                  label: 'Similar setup follow-through',
                  value:
                      '${(validation.alignedOutcomeRate * 100).toStringAsFixed(0)}%',
                ),
                _DetailRow(
                  label: '$symbol comparable-condition follow-through',
                  value:
                      '${(validation.controlAlignedOutcomeRate * 100).toStringAsFixed(0)}%',
                ),
                _DetailRow(
                  label: 'Historical difference',
                  value: _signedPercentPoints(
                    validation.edgeVsControlPercentagePoints,
                  ),
                ),
              ],
              _DetailRow(
                label: 'Median forward move',
                value:
                    '${_signedNumber(validation.medianForwardReturnPercent)}%',
              ),
              _DetailRow(
                label: 'Median move vs current direction',
                value:
                    '${_signedNumber(validation.medianDirectionalReturnPercent)}%',
              ),
              _DetailRow(
                label: 'Median favorable excursion',
                value:
                    '+${validation.medianFavorableExcursionPercent.toStringAsFixed(2)}%',
              ),
              _DetailRow(
                label: 'Median adverse excursion',
                value:
                    '${validation.medianAdverseExcursionPercent.toStringAsFixed(2)}%',
              ),
              if (validation.status ==
                  HistoricalValidationStatus.available) ...[
                const Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Historical scoring weights',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Outcome measurements are not equally important. Reliability is applied afterward as a gate, not as another vote.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                _WeightedScoreRow(
                  label: 'Difference vs stock baseline',
                  weight: validation.scoringBreakdown.edgeVsControlWeight,
                  score: validation.scoringBreakdown.edgeVsControlScore,
                ),
                _WeightedScoreRow(
                  label: 'Directional follow-through',
                  weight: validation.scoringBreakdown.followThroughWeight,
                  score: validation.scoringBreakdown.followThroughScore,
                ),
                _WeightedScoreRow(
                  label: 'Normalized outcome magnitude',
                  weight: validation.scoringBreakdown.outcomeMagnitudeWeight,
                  score: validation.scoringBreakdown.outcomeMagnitudeScore,
                ),
                _WeightedScoreRow(
                  label: 'Excursion quality',
                  weight: validation.scoringBreakdown.excursionQualityWeight,
                  score: validation.scoringBreakdown.excursionQualityScore,
                ),
                _DetailRow(
                  label: 'Weighted historical quality',
                  value: _normalizedScore(
                    validation.scoringBreakdown.weightedOutcomeScore,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Reliability gates',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _DetailRow(
                  label: 'Effective-sample reliability',
                  value: _percentage(
                    validation.scoringBreakdown.effectiveSampleReliability,
                  ),
                ),
                _DetailRow(
                  label: 'Match-quality reliability',
                  value: _percentage(
                    validation.scoringBreakdown.matchQualityReliability,
                  ),
                ),
                _DetailRow(
                  label: 'Applied reliability',
                  value: _percentage(
                    validation.scoringBreakdown.appliedReliability,
                  ),
                ),
              ],
              if (validation.topMatches.isNotEmpty) ...[
                const Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Closest historical matches',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                ...validation.topMatches
                    .take(3)
                    .map((match) => _MatchRow(match: match)),
              ],
              if (validation.isSynthetic) ...[
                const SizedBox(height: 8),
                Text(
                  '${validation.sourceLabel}: historical outcomes are synthetic development data. They validate the architecture and UI, not real-world performance.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showInfo(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Historical Setup Check'),
        content: const Text(
          'TradePilot uses two different historical groups.\n\n'
          '1. Similar historical setups: cases from the current stock and other stocks that share the same Stock Profile. The setup matcher then compares the independent evidence groups, volatility regime, market environment, relative strength, strategy and analysis interval. Stock Profile is a hard eligibility rule, not merely a small weighting bonus.\n\n'
          '2. The current stock under comparable conditions: observations from this stock only, with the same strategy, analysis interval, Stock Profile, volatility regime and market environment. These observations are deliberately NOT required to match today\'s evidence pattern. They estimate what the stock usually did under similar surrounding conditions.\n\n'
          'TradePilot compares the two follow-through rates so ordinary stock or market behavior is less likely to be mistaken for setup-specific historical evidence. Outcome measurements have unequal weights, while sample depth and match quality are applied afterward as reliability gates. Historical validation can adjust confidence within a strict cap, but it does not change recommendation direction by itself.\n\n'
          'Historical results do not guarantee future performance.',
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

  static String _differenceDescription(String symbol, double difference) {
    if (difference >= 5) {
      return 'Similar setups historically performed better than $symbol under comparable conditions.';
    }
    if (difference <= -5) {
      return 'Similar setups historically performed worse than $symbol under comparable conditions.';
    }
    return 'Similar setups historically performed about the same as $symbol under comparable conditions.';
  }

  static String _signedConfidencePoints(double value) {
    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(1)} points';
  }

  static String _signedPercentPoints(double value) {
    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(0)}% points';
  }

  static String _signedNumber(double value) {
    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(2)}';
  }

  static String _normalizedScore(double value) {
    final points = value * 100;
    final prefix = points > 0 ? '+' : '';
    return '$prefix${points.toStringAsFixed(0)}/100';
  }

  static String _percentage(double value) =>
      '${(value * 100).toStringAsFixed(0)}%';
}

class _VerdictChip extends StatelessWidget {
  const _VerdictChip({required this.validation});

  final HistoricalSetupValidation validation;

  @override
  Widget build(BuildContext context) {
    final label = switch (validation.status) {
      HistoricalValidationStatus.unavailable => 'Unavailable',
      HistoricalValidationStatus.insufficientData => 'Limited Data',
      HistoricalValidationStatus.neutralSignal => 'Neutral',
      HistoricalValidationStatus.available => switch (validation.verdict) {
        HistoricalValidationVerdict.supports => 'Supports',
        HistoricalValidationVerdict.mixed => 'Mixed',
        HistoricalValidationVerdict.opposes => 'Opposes',
        HistoricalValidationVerdict.unavailable => 'Unavailable',
      },
    };

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Chip(visualDensity: VisualDensity.compact, label: Text(label)),
    );
  }
}

class _NarrativeMetric extends StatelessWidget {
  const _NarrativeMetric({required this.title, required this.description});

  final String title;
  final String description;

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
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(description, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _WeightedScoreRow extends StatelessWidget {
  const _WeightedScoreRow({
    required this.label,
    required this.weight,
    required this.score,
  });

  final String label;
  final double weight;
  final double score;

  @override
  Widget build(BuildContext context) {
    final scorePoints = score * 100;
    final scorePrefix = scorePoints > 0 ? '+' : '';

    return _DetailRow(
      label: '$label (${(weight * 100).toStringAsFixed(0)}%)',
      value: '$scorePrefix${scorePoints.toStringAsFixed(0)}/100',
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
          const SizedBox(width: 12),
          Text(value),
        ],
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  const _MatchRow({required this.match});

  final HistoricalSetupMatch match;

  @override
  Widget build(BuildContext context) {
    final date = match.setupCase.occurredAt;
    final formattedDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final forwardReturn = match.setupCase.forwardReturnPercent;
    final prefix = forwardReturn > 0 ? '+' : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${match.setupCase.symbol} · $formattedDate · ${(match.similarity * 100).toStringAsFixed(0)}% match',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$prefix${forwardReturn.toStringAsFixed(2)}%',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
