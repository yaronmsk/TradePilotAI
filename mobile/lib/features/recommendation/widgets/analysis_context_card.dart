import 'package:flutter/material.dart';

import '../../../shared/widgets/dashboard_card.dart';
import '../context/market_context_profile.dart';
import '../context/multi_timeframe_profile.dart';
import '../context/recommendation_analysis_context.dart';
import '../models/evidence_result.dart';
import '../models/strategy_summary.dart';

class AnalysisContextCard extends StatelessWidget {
  const AnalysisContextCard({
    required this.strategy,
    required this.analysisContext,
    super.key,
  });

  final StrategyType strategy;
  final RecommendationAnalysisContext analysisContext;

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
                  'How the selected strategy fits recent price action and the market environment.',
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
          const SizedBox(height: 8),
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
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('What is Analysis Context?'),
        content: const Text(
          'TradePilot does not treat every timeframe as another independent vote. '
          'For Trader mode, recent price action is evaluated with 5-minute candles as the active short-term signal, 1-hour candles for confirmation, and daily candles only as the broader trend backdrop. '
          'These labels describe candle intervals, not the total holding period. '
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
          parts.add('The short-term and broader trend views are aligned.');
          break;
        case TimeframeAlignment.opposed:
          parts.add(
            'Both broader trend views oppose the active short-term trend, which reduces confirmation.',
          );
          break;
        case TimeframeAlignment.mixed:
          parts.add(
            'The short-term and broader trend views are mixed, so trend confirmation is limited.',
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
    return '${_timeframeRoleLabel(profile.primary.timeframe)}: '
        '${_directionLabel(profile.primary.direction)} • '
        '${_timeframeRoleLabel(profile.confirmation.timeframe)}: '
        '${_directionLabel(profile.confirmation.direction)} • '
        '${_timeframeRoleLabel(profile.regime.timeframe)}: '
        '${_directionLabel(profile.regime.direction)}';
  }

  String _timeframeRoleLabel(String timeframe) {
    switch (timeframe) {
      case '5m':
        return 'Short-term trend (5-minute candles)';
      case '1h':
        return 'Near-term trend (1-hour candles)';
      case '1d':
        return 'Daily backdrop (1-day candles)';
      default:
        return 'Trend ($timeframe candles)';
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
