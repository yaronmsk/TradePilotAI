import 'package:flutter/material.dart';

import '../../../shared/widgets/dashboard_card.dart';
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

    return DashboardCard(
      title: '${strategy.title} Analysis Context',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Choose the primary analysis interval, then see how it fits the broader trend and market environment.',
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
            label: 'Relative Strength',
            value: _relativeStrengthLabel(market.relativeStrength),
            detail: market.hasSufficientData
                ? _relativeStrengthDetail(market)
                : 'Relative performance unavailable',
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
              child: Text(_summary(multiTimeframe, market)),
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
        content: Text(
          'The Primary Analysis Interval controls the candles used by the main ${strategy.title} technical evidence. '
          'For the current setup, $primary drive the primary signal, $confirmation provide confirmation, and $regime provide the broader trend backdrop. '
          'These are candle intervals, not the expected holding period. '
          'TradePilot does not count each timeframe as a separate independent vote. '
          'Market Environment evaluates the broad market and the relevant sector, while Relative Strength separately asks how the stock is performing versus those benchmarks. '
          'These inputs can strengthen or weaken confidence, but they do not override the complete evidence set by themselves.',
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
        parts.add(
          'The current market environment is a headwind rather than a tailwind.',
        );
      } else if (market.backdrop == MarketBackdrop.supportive) {
        parts.add(
          'The current market environment provides a supportive tailwind.',
        );
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

  String _signed(double value) {
    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(1)}';
  }

  String _alignmentLabel(TimeframeAlignment alignment) {
    switch (alignment) {
      case TimeframeAlignment.aligned:
        return 'Aligned';
      case TimeframeAlignment.mixed:
        return 'Mixed';
      case TimeframeAlignment.opposed:
        return 'Opposed';
      case TimeframeAlignment.unknown:
        return 'Unavailable';
    }
  }

  String _marketEnvironmentLabel(MarketBackdrop backdrop) {
    switch (backdrop) {
      case MarketBackdrop.supportive:
        return 'Supportive';
      case MarketBackdrop.neutral:
        return 'Neutral';
      case MarketBackdrop.challenging:
        return 'Challenging';
      case MarketBackdrop.unknown:
        return 'Unavailable';
    }
  }

  String _relativeStrengthLabel(RelativeStrengthState state) {
    switch (state) {
      case RelativeStrengthState.outperforming:
        return 'Outperforming';
      case RelativeStrengthState.inLine:
        return 'In Line';
      case RelativeStrengthState.underperforming:
        return 'Underperforming';
      case RelativeStrengthState.unknown:
        return 'Unavailable';
    }
  }

  String _directionLabel(EvidenceDirection direction) {
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
