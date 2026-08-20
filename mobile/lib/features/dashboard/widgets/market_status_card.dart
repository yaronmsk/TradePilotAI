import 'package:flutter/material.dart';

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
              return const CollapsibleDashboardCard(
                title: 'Market Status',
                collapsedSummary: Text('Waiting for market data'),
                child: Text('Waiting for market data.'),
              );
            }

            return CollapsibleDashboardCard(
              title: 'Market Status',
              collapsedSummary: _CollapsedMarketSummary(
                symbol: snapshot.symbol,
                currentPrice: snapshot.currentPrice,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 760;

                  final summary = _MarketSummary(
                    symbol: snapshot.symbol,
                    currentPrice: snapshot.currentPrice,
                    currentVolume: snapshot.currentVolume,
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
  });

  final String symbol;
  final double currentPrice;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$symbol  •  \$${currentPrice.toStringAsFixed(2)}',
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
  });

  final String symbol;
  final double currentPrice;
  final double currentVolume;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.circle, size: 12, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              '$symbol connected',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
