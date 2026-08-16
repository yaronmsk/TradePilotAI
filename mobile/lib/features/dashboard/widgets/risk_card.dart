import 'package:flutter/material.dart';

import '../../../shared/widgets/dashboard_card.dart';
import '../../recommendation/models/strategy_summary.dart';

class RiskCard extends StatelessWidget {
  const RiskCard({required this.strategy, super.key});

  final StrategyType strategy;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: '${strategy.title} Risk',
      child: const Text(
        'Strategy-specific risk analysis will be added as the risk engine is implemented.',
      ),
    );
  }
}
