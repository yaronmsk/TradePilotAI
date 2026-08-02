import 'package:flutter/material.dart';

import '../../../shared/widgets/dashboard_card.dart';
import '../../market/controllers/market_controller.dart';
import '../../market/models/market_state.dart';

class MarketStatusCard extends StatelessWidget {
  const MarketStatusCard({required this.controller, super.key});

  final MarketController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;

        return DashboardCard(
          title: 'Market Status',
          child: _buildContent(context, state),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, MarketState state) {
    switch (state.status) {
      case MarketStatus.initial:
        return const Row(
          children: [
            Icon(Icons.circle_outlined, size: 14),
            SizedBox(width: 8),
            Text('Waiting for market data'),
          ],
        );

      case MarketStatus.loading:
        return const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading market data...'),
          ],
        );

      case MarketStatus.loaded:
        final snapshot = state.snapshot;

        if (snapshot == null) {
          return const Text('Market data is unavailable.');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${snapshot.symbol} connected',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '\$${snapshot.currentPrice.toStringAsFixed(2)}',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 20,
              runSpacing: 8,
              children: [
                _MarketValue(label: 'Timeframe', value: snapshot.timeframe),
                _MarketValue(
                  label: 'Candles',
                  value: snapshot.candleCount.toString(),
                ),
                _MarketValue(
                  label: 'Volume',
                  value: snapshot.currentVolume.toStringAsFixed(0),
                ),
              ],
            ),
          ],
        );

      case MarketStatus.error:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.errorMessage ?? 'Unable to load market data.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
    }
  }
}

class _MarketValue extends StatelessWidget {
  const _MarketValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
