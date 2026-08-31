import 'package:flutter/material.dart';

import '../../../shared/widgets/dashboard_card.dart';
import '../models/swing_decision_helper.dart';
import 'metric_explainability_dialog.dart';

class SwingDecisionHelperCard extends StatelessWidget {
  const SwingDecisionHelperCard({required this.summary, super.key});

  final SwingDecisionHelperSummary summary;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Swing Decision Helper',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A quick view of entry timing and nearby price structure using '
            'evidence already included in the Swing analysis.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          Text(
            'No extra score or evidence vote is added.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          _DecisionHelperMetricTile(metric: summary.entryQuality),
          const SizedBox(height: 10),
          _DecisionHelperMetricTile(metric: summary.priceStretch),
          const SizedBox(height: 10),
          _DecisionHelperMetricTile(metric: summary.structureWatch),
        ],
      ),
    );
  }
}

class _DecisionHelperMetricTile extends StatelessWidget {
  const _DecisionHelperMetricTile({required this.metric});

  final SwingDecisionHelperMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  metric.label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                tooltip: 'About ${metric.label}',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                icon: const Icon(Icons.info_outline, size: 18),
                onPressed: () => MetricExplainabilityDialog.show(
                  context,
                  title: metric.label,
                  explainability: metric.explainability,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            metric.value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(metric.detail, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
