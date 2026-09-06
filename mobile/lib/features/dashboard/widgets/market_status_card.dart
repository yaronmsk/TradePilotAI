import 'package:flutter/material.dart';

import '../../../core/data/data_provenance.dart';
import '../../../shared/widgets/collapsible_dashboard_card.dart';
import '../../market/controllers/market_controller.dart';
import '../../market/controllers/market_history_controller.dart';
import '../../market/widgets/market_history_chart.dart';
import '../../market/widgets/market_history_range_selector.dart';

class MarketStatusCard extends StatelessWidget {
  const MarketStatusCard({
    required this.marketController,
    required this.historyController,
    super.key,
  });

  final MarketController marketController;
  final MarketHistoryController historyController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: marketController,
      builder: (context, _) {
        return AnimatedBuilder(
          animation: historyController,
          builder: (context, _) {
            final snapshot = marketController.state.snapshot;

            if (snapshot == null) {
              final error = marketController.state.errorMessage;
              return CollapsibleDashboardCard(
                title: 'Market Status',
                collapsedSummary: Text(
                  error == null
                      ? 'Waiting for market data'
                      : 'Market data unavailable',
                ),
                child: Text(
                  error == null
                      ? 'Waiting for market data.'
                      : 'Market data unavailable: $error',
                ),
              );
            }

            return CollapsibleDashboardCard(
              title: 'Market Status',
              collapsedSummary: _CollapsedMarketSummary(
                symbol: snapshot.symbol,
                currentPrice: snapshot.currentPrice,
                provenance: snapshot.provenance,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 760;

                  final summary = _MarketSummary(
                    symbol: snapshot.symbol,
                    currentPrice: snapshot.currentPrice,
                    currentVolume: snapshot.currentVolume,
                    provenance: snapshot.provenance,
                  );

                  final history = _HistorySection(
                    controller: historyController,
                  );

                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 250, child: summary),
                        const SizedBox(width: 24),
                        Expanded(child: history),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [summary, const SizedBox(height: 20), history],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _CollapsedMarketSummary extends StatelessWidget {
  const _CollapsedMarketSummary({
    required this.symbol,
    required this.currentPrice,
    required this.provenance,
  });

  final String symbol;
  final double currentPrice;
  final DataProvenance provenance;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$symbol  •  \$${currentPrice.toStringAsFixed(2)}  •  '
      '${provenance.state.wireValue}',
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _MarketSummary extends StatelessWidget {
  const _MarketSummary({
    required this.symbol,
    required this.currentPrice,
    required this.currentVolume,
    required this.provenance,
  });

  final String symbol;
  final double currentPrice;
  final double currentVolume;
  final DataProvenance provenance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.circle,
              size: 12,
              color: provenance.isLiveUsable ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$symbol • ${provenance.state.wireValue}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              tooltip: 'About this market data',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.info_outline, size: 20),
              onPressed: () => _showDataSourceDialog(context, provenance),
            ),
          ],
        ),
        Text(provenance.source, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 20),
        const Text(
          'Current Price',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${currentPrice.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 18),
        Text('Current volume: ${currentVolume.toStringAsFixed(0)}'),
      ],
    );
  }
}

Future<void> _showDataSourceDialog(
  BuildContext context,
  DataProvenance provenance,
) {
  final observedAt = provenance.observedAt?.toLocal().toIso8601String();
  final fetchedAt = provenance.fetchedAt?.toLocal().toIso8601String();

  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Market data source'),
        content: SingleChildScrollView(
          child: Text(
            'State: ${provenance.state.wireValue}\n'
            'Source: ${provenance.source}\n'
            'Market timestamp: ${observedAt ?? 'Not available'}\n'
            'Fetched: ${fetchedAt ?? 'Not applicable'}\n\n'
            'LIVE means the market values came through the TradePilot live-data '
            'path. PARTIAL_LIVE means the source returned fewer observations '
            'than requested. SYNTHETIC means deterministic development data and '
            'must not be treated as current market information.\n\n'
            'Source/freshness labels describe the data input, not the certainty '
            'or profitability of a recommendation.',
          ),
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

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.controller});

  final MarketHistoryController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Price History',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (state.isLoading) ...[
              const SizedBox(width: 12),
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        MarketHistoryChart(candles: state.candles),
        const SizedBox(height: 12),
        MarketHistoryRangeSelector(
          selectedRange: state.range,
          onSelected: controller.selectRange,
        ),
        if (state.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            state.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }
}
