import 'package:flutter/material.dart';

import '../context/stock_behavior_profile.dart';
import '../models/stock_behavior_explainability_catalog.dart';
import 'metric_explainability_dialog.dart';

class StockBehaviorCard extends StatelessWidget {
  const StockBehaviorCard({required this.profile, super.key});

  final StockBehaviorProfile profile;

  @override
  Widget build(BuildContext context) {
    final hasHistory = profile.hasHistoricalBaseline;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasHistory ? 'Stock DNA' : 'Stock Behavior',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasHistory
                            ? 'How this stock normally behaves, compared with its own one-year history.'
                            : 'Short-term behavior while historical baseline data is unavailable.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'About Stock DNA',
                  onPressed: () => _showInfo(context),
                  icon: const Icon(Icons.info_outline),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 20,
              runSpacing: 14,
              children: [
                _Metric(
                  metric: StockBehaviorMetric.stockType,
                  label: 'Stock Type',
                  value: _behaviorLabel(profile.behaviorType),
                ),
                _Metric(
                  metric: StockBehaviorMetric.volatilityNow,
                  label: 'Volatility Now',
                  value: _volatilityValue(profile),
                ),
                _Metric(
                  metric: StockBehaviorMetric.typicalDailyRange,
                  label: hasHistory ? 'Typical Daily Range' : 'Current ATR',
                  value: hasHistory
                      ? '${profile.typicalDailyAtrPercent.toStringAsFixed(2)}%'
                      : '${profile.atrPercent.toStringAsFixed(2)}%',
                ),
                _Metric(
                  metric: StockBehaviorMetric.volumePattern,
                  label: hasHistory ? 'Volume Pattern' : 'Relative Volume',
                  value: hasHistory
                      ? _volumePattern(profile.volumeVariability)
                      : '${profile.relativeVolume.toStringAsFixed(2)}x',
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              _summary(profile),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (hasHistory) ...[
              const SizedBox(height: 6),
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 4),
                  title: const Text('How TradePilot uses this'),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _brainUsage(profile),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _technicalBaseline(profile),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('What is Stock DNA?'),
          content: const Text(
            'Stock DNA is TradePilot\'s long-term behavior baseline. It uses daily price and volume history to understand whether a stock is normally steady or volatile, how unusual current volatility is for that same stock, and how consistent its volume usually is.\n\n'
            'Stock DNA does not create a Buy or Sell signal by itself. It changes how much trust the recommendation brain gives to other evidence. For Swing, these adjustments require a valid daily historical baseline and are deliberately bounded so Stock DNA cannot dominate the recommendation. For example, an RSI extreme carries less standalone weight in an inherently volatile stock than in a historically steady stock.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _behaviorLabel(StockBehaviorType type) {
    switch (type) {
      case StockBehaviorType.unknown:
        return 'Unknown';
      case StockBehaviorType.steady:
        return 'Steady';
      case StockBehaviorType.balanced:
        return 'Balanced';
      case StockBehaviorType.volatile:
        return 'Volatile';
    }
  }

  String _volatilityValue(StockBehaviorProfile profile) {
    final regime = _volatilityLabel(profile.volatilityRegime);

    if (!profile.hasHistoricalBaseline) {
      return regime;
    }

    return '$regime · ${_formatPercentile(profile.volatilityPercentile)}';
  }

  String _formatPercentile(double value) {
    final percentile = value.round().clamp(0, 100).toInt();
    final remainder100 = percentile % 100;

    String suffix;
    if (remainder100 >= 11 && remainder100 <= 13) {
      suffix = 'th';
    } else {
      suffix = switch (percentile % 10) {
        1 => 'st',
        2 => 'nd',
        3 => 'rd',
        _ => 'th',
      };
    }

    return '$percentile$suffix percentile';
  }

  String _volatilityLabel(VolatilityRegime regime) {
    switch (regime) {
      case VolatilityRegime.unknown:
        return 'Unknown';
      case VolatilityRegime.calm:
        return 'Calm';
      case VolatilityRegime.normal:
        return 'Normal';
      case VolatilityRegime.elevated:
        return 'Elevated';
    }
  }

  String _volumePattern(double variability) {
    if (variability <= 0.25) {
      return 'Stable';
    }

    if (variability <= 0.50) {
      return 'Variable';
    }

    return 'Highly variable';
  }

  String _summary(StockBehaviorProfile profile) {
    if (!profile.hasSufficientData) {
      return 'More market data is required before stock-specific evidence weighting can be applied.';
    }

    if (!profile.hasHistoricalBaseline) {
      return 'TradePilot is using a short-term fallback profile. The recommendation remains available, but long-term Stock DNA adjustments are not active yet.';
    }

    final volatilityContext = switch (profile.volatilityRegime) {
      VolatilityRegime.calm =>
        'Current volatility is low compared with this stock\'s own history.',
      VolatilityRegime.normal =>
        'Current volatility is within this stock\'s normal historical range.',
      VolatilityRegime.elevated =>
        'Current volatility is high compared with this stock\'s own history.',
      VolatilityRegime.unknown =>
        'Current volatility cannot yet be classified reliably.',
    };

    final typeContext = switch (profile.behaviorType) {
      StockBehaviorType.steady =>
        'This is historically a steadier stock, so unusual moves and oscillator extremes can be more informative.',
      StockBehaviorType.balanced =>
        'This stock has a balanced long-term behavior profile, so evidence stays close to normal weighting.',
      StockBehaviorType.volatile =>
        'This is historically a volatile stock, so TradePilot requires stronger confirmation before trusting simple reversal signals.',
      StockBehaviorType.unknown =>
        'The long-term stock type cannot yet be classified reliably.',
    };

    return '$typeContext $volatilityContext';
  }

  String _brainUsage(StockBehaviorProfile profile) {
    final parts = <String>[];

    switch (profile.behaviorType) {
      case StockBehaviorType.steady:
        parts.add(
          'Mean-reversion evidence such as RSI can receive slightly more trust because large oscillator extremes are less routine.',
        );
        break;
      case StockBehaviorType.volatile:
        parts.add(
          'RSI receives less standalone weight, while clean directional trend evidence requires and can receive stronger confirmation.',
        );
        break;
      case StockBehaviorType.balanced:
        parts.add(
          'Indicator weights remain closer to their defaults unless current conditions become unusually extreme.',
        );
        break;
      case StockBehaviorType.unknown:
        parts.add('Historical stock-type adjustments are limited.');
        break;
    }

    if (profile.volatilityRegime == VolatilityRegime.elevated) {
      parts.add(
        'Because volatility is elevated versus the stock\'s own history, the brain becomes more cautious with reversal signals and looks for cleaner confirmation.',
      );
    }

    if (profile.volumeVariability <= 0.25) {
      parts.add(
        'Daily volume is normally stable, so an unusual volume expansion carries extra information.',
      );
    } else if (profile.volumeVariability >= 0.50) {
      parts.add(
        'Daily volume is naturally erratic, so moderate volume spikes are treated as less exceptional.',
      );
    }

    return parts.join(' ');
  }

  String _technicalBaseline(StockBehaviorProfile profile) {
    return 'Historical baseline: ${profile.historicalSampleSize} daily sessions · '
        '20-day realized volatility ${profile.recentRealizedVolatilityPercent.toStringAsFixed(1)}% '
        'vs typical ${profile.typicalRealizedVolatilityPercent.toStringAsFixed(1)}% · '
        '20D/60D average volume ${profile.volumeTrendRatio.toStringAsFixed(2)}x · '
        'current intraday volume ${profile.relativeVolume.toStringAsFixed(2)}x its recent analysis-window average.';
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.metric,
    required this.label,
    required this.value,
  });

  final StockBehaviorMetric metric;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(width: 2),
              IconButton(
                tooltip: 'About $label',
                onPressed: () => MetricExplainabilityDialog.show(
                  context,
                  title: label,
                  explainability: StockBehaviorExplainabilityCatalog.forMetric(
                    metric,
                  ),
                ),
                icon: const Icon(Icons.info_outline),
                iconSize: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 24,
                  height: 24,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
