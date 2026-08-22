import 'package:flutter/material.dart';

import '../../../shared/widgets/dashboard_card.dart';
import '../context/external_context_profile.dart';
import '../context/market_context_profile.dart';
import '../context/multi_timeframe_profile.dart';
import '../context/recommendation_analysis_context.dart';
import '../context/strategy_timeframe_plan.dart';
import '../models/evidence_result.dart';
import '../models/strategy_summary.dart';

class AnalysisContextCard extends StatelessWidget {
  const AnalysisContextCard({
    required this.strategy,
    required this.analysisContext,
    required this.timeframePlan,
    required this.availablePrimaryTimeframes,
    required this.onPrimaryTimeframeSelected,
    this.isReloading = false,
    super.key,
  });

  final StrategyType strategy;
  final RecommendationAnalysisContext analysisContext;
  final StrategyTimeframePlan timeframePlan;
  final List<String> availablePrimaryTimeframes;
  final ValueChanged<String>? onPrimaryTimeframeSelected;
  final bool isReloading;

  @override
  Widget build(BuildContext context) {
    final multiTimeframe = analysisContext.multiTimeframeProfile;
    final market = analysisContext.marketContextProfile;
    final external = analysisContext.externalContextProfile;

    return DashboardCard(
      title: '${strategy.title} Analysis Context',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Choose the primary analysis interval, then see the broader trend, market participation, event risk and information context around the setup.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              IconButton(
                tooltip: 'About Analysis Context',
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfo(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AnalysisTimeframeSelector(
            strategy: strategy,
            selectedTimeframe: timeframePlan.primaryTimeframe,
            availableTimeframes: availablePrimaryTimeframes,
            onSelected: onPrimaryTimeframeSelected,
            isReloading: isReloading,
          ),
          const SizedBox(height: 8),
          Text(
            '${timeframePlan.primaryCandleCount} × '
            '${StrategyTimeframePlan.timeframeDescription(timeframePlan.primaryTimeframe)} '
            'feed the primary ${strategy.title} evidence. Confirmation and broader context are selected automatically.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          const Divider(),
          _ContextRow(
            label: 'Timeframe Alignment',
            value: _alignmentLabel(multiTimeframe.alignment),
            detail: multiTimeframe.hasSufficientData
                ? _timeframeAlignmentDetail(multiTimeframe)
                : 'Higher-timeframe data unavailable',
          ),
          const Divider(),
          _ContextRow(
            label: 'Market Environment',
            value: _marketEnvironmentLabel(market.backdrop),
            detail: market.hasSufficientData
                ? _marketEnvironmentDetail(market)
                : 'Benchmark context unavailable',
          ),
          const Divider(),
          _ContextRow(
            label: 'Market Breadth',
            value: _breadthLabel(external.marketBreadth.state),
            detail: external.marketBreadth.isAvailable
                ? '${external.marketBreadth.advancingPercent.toStringAsFixed(0)}% advancing • '
                      '${external.marketBreadth.above50DayPercent.toStringAsFixed(0)}% above 50-day reference'
                : 'Broad market participation unavailable',
          ),
          const Divider(),
          _ContextRow(
            label: 'Relative Strength',
            value: _relativeStrengthLabel(market.relativeStrength),
            detail: market.hasSufficientData
                ? _relativeStrengthDetail(market)
                : 'Relative performance unavailable',
          ),
          const Divider(),
          _ContextRow(
            label: 'Event Risk',
            value: _eventRiskLabel(external.eventRisk.level),
            detail: external.eventRisk.isAvailable
                ? _eventRiskDetail(external.eventRisk)
                : 'Upcoming earnings/event context unavailable',
          ),
          const Divider(),
          _ContextRow(
            label: 'News Sentiment',
            value: _newsLabel(external.newsSentiment.state),
            detail: external.newsSentiment.isAvailable
                ? '${external.newsSentiment.articleCount} recent items • '
                      '${external.newsSentiment.sourceCount} sources • '
                      'freshest ~${external.newsSentiment.freshnessHours.toStringAsFixed(1)}h'
                : 'Recent news context unavailable',
          ),
          if (analysisContext.hasAnyContext) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_summary(multiTimeframe, market, external)),
            ),
          ],
          if (external.isSynthetic) ...[
            const SizedBox(height: 8),
            Text(
              '${external.sourceLabel}: breadth, events and news are synthetic development context. They validate the architecture and UI, not real-world market conditions.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showInfo(BuildContext context) {
    final primary = StrategyTimeframePlan.timeframeDescription(
      timeframePlan.primaryTimeframe,
    );
    final confirmation = StrategyTimeframePlan.timeframeDescription(
      timeframePlan.confirmationTimeframe,
    );
    final regime = StrategyTimeframePlan.timeframeDescription(
      timeframePlan.regimeTimeframe,
    );

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('What is Analysis Context?'),
        content: SingleChildScrollView(
          child: Text(
            'The Primary Analysis Interval controls the candles used by the main ${strategy.title} technical evidence. '
            'For the current setup, $primary drive the primary signal, $confirmation provide confirmation, and $regime provide the broader trend backdrop. '
            'These are candle intervals, not the expected holding period.\n\n'
            'Market Environment evaluates the broad market and relevant sector. Market Breadth asks whether many stocks are participating in that move instead of trusting a headline index alone. Relative Strength asks how this stock is performing versus those benchmarks.\n\n'
            'Event Risk covers scheduled catalysts such as earnings and high-impact macro events. It is a confidence/risk modifier only: event proximity can reduce confidence, but it never creates a Buy or Sell direction by itself.\n\n'
            'News Sentiment is directional evidence, but TradePilot scales it using source diversity, freshness and materiality so repeated or low-quality headlines cannot dominate the recommendation.\n\n'
            'Market Breadth remains inside the Market Context evidence group, while News Sentiment has its own capped Sentiment group. This prevents related context signals from being counted as unlimited independent votes.',
          ),
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

  String _summary(
    MultiTimeframeProfile multiTimeframe,
    MarketContextProfile market,
    ExternalContextProfile external,
  ) {
    final parts = <String>[];

    if (multiTimeframe.hasSufficientData) {
      switch (multiTimeframe.alignment) {
        case TimeframeAlignment.aligned:
          parts.add('The primary and broader trend views are aligned.');
          break;
        case TimeframeAlignment.opposed:
          parts.add(
            'Both broader trend views oppose the primary trend, which reduces confirmation.',
          );
          break;
        case TimeframeAlignment.mixed:
          parts.add(
            'The primary and broader trend views are mixed, so trend confirmation is limited.',
          );
          break;
        case TimeframeAlignment.unknown:
          break;
      }
    }

    if (market.hasSufficientData) {
      if (market.relativeStrength == RelativeStrengthState.outperforming) {
        parts.add('The stock is outperforming its market/sector benchmarks.');
      } else if (market.relativeStrength ==
          RelativeStrengthState.underperforming) {
        parts.add('The stock is underperforming its market/sector benchmarks.');
      } else {
        parts.add('The stock is trading broadly in line with its benchmarks.');
      }

      if (market.backdrop == MarketBackdrop.challenging) {
        parts.add('The current market environment is a headwind.');
      } else if (market.backdrop == MarketBackdrop.supportive) {
        parts.add('The current market environment provides a tailwind.');
      }
    }

    if (external.marketBreadth.isAvailable) {
      if (external.marketBreadth.state == MarketBreadthState.weak ||
          external.marketBreadth.state == MarketBreadthState.stressed) {
        parts.add('Market participation is weak, which reduces confirmation.');
      } else if (external.marketBreadth.state == MarketBreadthState.strong ||
          external.marketBreadth.state == MarketBreadthState.healthy) {
        parts.add(
          'Market participation is broad enough to support the backdrop.',
        );
      }
    }

    if (external.eventRisk.isAvailable &&
        external.eventRisk.confidencePenaltyPoints >= 3) {
      parts.add(
        'Upcoming scheduled events reduce confidence because gap/volatility risk is elevated.',
      );
    }

    if (external.newsSentiment.isAvailable) {
      if (external.newsSentiment.state == NewsSentimentState.positive) {
        parts.add('Recent company news is directionally positive.');
      } else if (external.newsSentiment.state == NewsSentimentState.negative) {
        parts.add('Recent company news is directionally negative.');
      }
    }

    return parts.isEmpty ? 'Context is still loading.' : parts.join(' ');
  }

  String _timeframeAlignmentDetail(MultiTimeframeProfile profile) {
    return '${_timeframeRoleLabel(profile.primary)}: '
        '${_directionLabel(profile.primary.direction)} • '
        '${_timeframeRoleLabel(profile.confirmation)}: '
        '${_directionLabel(profile.confirmation.direction)} • '
        '${_timeframeRoleLabel(profile.regime)}: '
        '${_directionLabel(profile.regime.direction)}';
  }

  String _timeframeRoleLabel(TimeframeTrendSignal signal) {
    final description = StrategyTimeframePlan.timeframeDescription(
      signal.timeframe,
    );

    switch (signal.role) {
      case TimeframeRole.primary:
        return 'Primary trend ($description)';
      case TimeframeRole.confirmation:
        return 'Confirmation trend ($description)';
      case TimeframeRole.regime:
        if (signal.timeframe == '1d') {
          return 'Daily backdrop ($description)';
        }
        return 'Broader backdrop ($description)';
    }
  }

  String _marketEnvironmentDetail(MarketContextProfile market) {
    if (!market.target.hasSectorBenchmark) {
      return '${market.target.marketSymbol} broad market benchmark';
    }

    return '${market.target.marketSymbol} broad market • '
        '${market.target.sectorName} sector (${market.target.sectorSymbol})';
  }

  String _relativeStrengthDetail(MarketContextProfile market) {
    final marketValue = _signed(market.stockVsMarketPercent);

    if (!market.target.hasSectorBenchmark) {
      return 'vs ${market.target.marketSymbol}: $marketValue pp';
    }

    return 'vs ${market.target.marketSymbol}: $marketValue pp • '
        'vs ${market.target.sectorSymbol}: '
        '${_signed(market.stockVsSectorPercent)} pp';
  }

  String _eventRiskDetail(EventRiskProfile profile) {
    final parts = <String>[];
    if (profile.earningsHoursAway != null) {
      parts.add('earnings in ~${_humanDuration(profile.earningsHoursAway!)}');
    }
    if (profile.macroEventHoursAway != null) {
      parts.add(
        '${profile.macroEventLabel.toLowerCase()} in ~${_humanDuration(profile.macroEventHoursAway!)}',
      );
    }
    parts.add(
      '-${profile.confidencePenaltyPoints.toStringAsFixed(1)} confidence pts',
    );
    return parts.join(' • ');
  }

  String _humanDuration(int hours) {
    if (hours < 24) {
      return '${hours}h';
    }
    final days = hours / 24;
    return days == days.roundToDouble()
        ? '${days.toStringAsFixed(0)}d'
        : '${days.toStringAsFixed(1)}d';
  }

  String _signed(double value) {
    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(1)}';
  }

  String _alignmentLabel(TimeframeAlignment alignment) {
    return switch (alignment) {
      TimeframeAlignment.aligned => 'Aligned',
      TimeframeAlignment.mixed => 'Mixed',
      TimeframeAlignment.opposed => 'Opposed',
      TimeframeAlignment.unknown => 'Unavailable',
    };
  }

  String _marketEnvironmentLabel(MarketBackdrop backdrop) {
    return switch (backdrop) {
      MarketBackdrop.supportive => 'Supportive',
      MarketBackdrop.neutral => 'Neutral',
      MarketBackdrop.challenging => 'Challenging',
      MarketBackdrop.unknown => 'Unavailable',
    };
  }

  String _breadthLabel(MarketBreadthState state) {
    return switch (state) {
      MarketBreadthState.strong => 'Strong',
      MarketBreadthState.healthy => 'Healthy',
      MarketBreadthState.mixed => 'Mixed',
      MarketBreadthState.weak => 'Weak',
      MarketBreadthState.stressed => 'Stressed',
      MarketBreadthState.unavailable => 'Unavailable',
    };
  }

  String _eventRiskLabel(EventRiskLevel level) {
    return switch (level) {
      EventRiskLevel.low => 'Low',
      EventRiskLevel.moderate => 'Moderate',
      EventRiskLevel.high => 'High',
      EventRiskLevel.critical => 'Critical',
      EventRiskLevel.unavailable => 'Unavailable',
    };
  }

  String _newsLabel(NewsSentimentState state) {
    return switch (state) {
      NewsSentimentState.positive => 'Positive',
      NewsSentimentState.neutral => 'Neutral',
      NewsSentimentState.negative => 'Negative',
      NewsSentimentState.mixed => 'Mixed',
      NewsSentimentState.unavailable => 'Unavailable',
    };
  }

  String _relativeStrengthLabel(RelativeStrengthState state) {
    return switch (state) {
      RelativeStrengthState.outperforming => 'Outperforming',
      RelativeStrengthState.inLine => 'In Line',
      RelativeStrengthState.underperforming => 'Underperforming',
      RelativeStrengthState.unknown => 'Unavailable',
    };
  }

  String _directionLabel(EvidenceDirection direction) {
    return switch (direction) {
      EvidenceDirection.bullish => 'Bullish',
      EvidenceDirection.bearish => 'Bearish',
      EvidenceDirection.neutral => 'Neutral',
      EvidenceDirection.unknown => 'Unknown',
    };
  }
}

class _AnalysisTimeframeSelector extends StatelessWidget {
  const _AnalysisTimeframeSelector({
    required this.strategy,
    required this.selectedTimeframe,
    required this.availableTimeframes,
    required this.onSelected,
    required this.isReloading,
  });

  final StrategyType strategy;
  final String selectedTimeframe;
  final List<String> availableTimeframes;
  final ValueChanged<String>? onSelected;
  final bool isReloading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Primary Analysis Interval',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (isReloading) ...[
              const SizedBox(width: 10),
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Changes the ${strategy.title} evidence calculation. It does not change the Price History range.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTimeframes
              .map((timeframe) {
                return ChoiceChip(
                  label: Text(timeframe),
                  selected: timeframe == selectedTimeframe,
                  onSelected: onSelected == null || isReloading
                      ? null
                      : (selected) {
                          if (selected) {
                            onSelected!(timeframe);
                          }
                        },
                );
              })
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _ContextRow extends StatelessWidget {
  const _ContextRow({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(detail, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
