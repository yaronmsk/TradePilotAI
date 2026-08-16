import 'package:flutter/material.dart';

import '../models/strategy_summary.dart';

class StrategySummaryCard extends StatelessWidget {
  const StrategySummaryCard({
    required this.strategies,
    required this.selectedType,
    required this.onStrategySelected,
    super.key,
  });

  final List<StrategySummary> strategies;
  final StrategyType selectedType;
  final ValueChanged<StrategyType> onStrategySelected;

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
            const SizedBox(height: 4),
            Text(
              'Select a strategy to control the recommendation, evidence and risk context below.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ...strategies.map(
              (strategy) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StrategyTile(
                  strategy: strategy,
                  selected: strategy.type == selectedType,
                  onTap: strategy.isAvailable
                      ? () => onStrategySelected(strategy.type)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StrategyTile extends StatelessWidget {
  const _StrategyTile({
    required this.strategy,
    required this.selected,
    required this.onTap,
  });

  final StrategySummary strategy;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final available = strategy.isAvailable;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? colorScheme.primary.withValues(alpha: 0.10)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? colorScheme.primary : Colors.grey.shade300,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(strategy.type.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            strategy.title,
                            style: TextStyle(
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (selected) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Selected',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ],
                      ],
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
                child: available
                    ? Text(
                        strategy.recommendation ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : const Text('🚧 Coming Soon'),
              ),
              SizedBox(
                width: 90,
                child: available
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
        ),
      ),
    );
  }
}
