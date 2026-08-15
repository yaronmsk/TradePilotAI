import 'package:flutter/material.dart';

import '../models/strategy_summary.dart';

class StrategySummaryCard extends StatelessWidget {
  const StrategySummaryCard({required this.strategies, super.key});

  final List<StrategySummary> strategies;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Strategy Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            ...strategies.map(
              (strategy) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StrategyTile(strategy: strategy),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StrategyTile extends StatelessWidget {
  const _StrategyTile({required this.strategy});

  final StrategySummary strategy;

  @override
  Widget build(BuildContext context) {
    final active = strategy.isAvailable;

    return Container(
      decoration: BoxDecoration(
        color: active
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
            : null,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Text(_icon(strategy.type), style: const TextStyle(fontSize: 24)),

          const SizedBox(width: 12),

          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strategy.title,
                  style: TextStyle(
                    fontWeight: active ? FontWeight.bold : FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  strategy.horizon,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          Expanded(
            flex: 2,
            child: active
                ? Text(
                    strategy.recommendation ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : const Text('🚧 Coming Soon'),
          ),

          SizedBox(
            width: 90,
            child: active
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: (strategy.confidence ?? 0) / 100,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 4),
                      Text('${strategy.confidence!.toStringAsFixed(0)}%'),
                    ],
                  )
                : const Center(child: Text('—')),
          ),
        ],
      ),
    );
  }

  String _icon(StrategyType type) {
    switch (type) {
      case StrategyType.trader:
        return '⚡';
      case StrategyType.swing:
        return '📈';
      case StrategyType.investor:
        return '🏛';
    }
  }
}
