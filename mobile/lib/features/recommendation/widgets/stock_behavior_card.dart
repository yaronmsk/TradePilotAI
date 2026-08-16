import 'package:flutter/material.dart';

import '../context/stock_behavior_profile.dart';

class StockBehaviorCard extends StatelessWidget {
  const StockBehaviorCard({required this.profile, super.key});

  final StockBehaviorProfile profile;

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
              'Stock Behavior',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _Metric(
                  label: 'Profile',
                  value: _behaviorLabel(profile.behaviorType),
                ),
                _Metric(
                  label: 'Volatility Regime',
                  value: _volatilityLabel(profile.volatilityRegime),
                ),
                _Metric(
                  label: 'Relative Volume',
                  value: '${profile.relativeVolume.toStringAsFixed(2)}x',
                ),
                _Metric(
                  label: 'ATR',
                  value: '${profile.atrPercent.toStringAsFixed(2)}%',
                ),
                _Metric(
                  label: 'Trend Efficiency',
                  value:
                      '${(profile.trendEfficiency * 100).toStringAsFixed(0)}%',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _summary(profile),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
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

  String _summary(StockBehaviorProfile profile) {
    if (!profile.hasSufficientData) {
      return 'More market history is required before stock-specific evidence weighting can be applied.';
    }

    switch (profile.behaviorType) {
      case StockBehaviorType.steady:
        return 'This stock is currently behaving relatively steadily, so mean-reversion evidence such as RSI can receive slightly more trust.';
      case StockBehaviorType.balanced:
        return 'This stock is currently showing a balanced price profile. Evidence weights remain close to their default values unless volume or volatility becomes unusual.';
      case StockBehaviorType.volatile:
        return 'This stock is currently behaving as a volatile stock. The engine reduces reliance on simple overbought/oversold signals and gives more weight to directional trend evidence when the move is consistent.';
      case StockBehaviorType.unknown:
        return 'The current stock behavior cannot yet be classified reliably.';
    }
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 145,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
