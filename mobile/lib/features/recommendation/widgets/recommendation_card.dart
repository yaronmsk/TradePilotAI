import 'package:flutter/material.dart';

import '../../../shared/widgets/dashboard_card.dart';
import '../models/recommendation.dart';

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;

  const RecommendationCard({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Recommendation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _iconFor(recommendation.type),
                color: _colorFor(recommendation.type),
              ),
              const SizedBox(width: 8),
              Text(
                _labelFor(recommendation.type),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Evidence Score',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            recommendation.evidenceScore.toStringAsFixed(0),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(recommendation.oneLineExplanation),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Text('Timeframe: ${recommendation.timeframe}'),
          Text('Candles analyzed: ${recommendation.candleCount}'),
          Text(
            'Evidence coverage: '
            '${(recommendation.evidenceReport.coverage * 100).toStringAsFixed(0)}%',
          ),
          Text(
            'Last analysis: ${_formatAnalysisTime(recommendation.analysisTime)}',
          ),
        ],
      ),
    );
  }

  String _labelFor(RecommendationType type) {
    switch (type) {
      case RecommendationType.strongBuy:
        return 'Strong Buy';
      case RecommendationType.buy:
        return 'Buy';
      case RecommendationType.hold:
        return 'Hold';
      case RecommendationType.sell:
        return 'Sell';
      case RecommendationType.strongSell:
        return 'Strong Sell';
      case RecommendationType.wait:
        return 'Wait';
      case RecommendationType.unknown:
        return 'Waiting for Analysis';
    }
  }

  IconData _iconFor(RecommendationType type) {
    switch (type) {
      case RecommendationType.strongBuy:
      case RecommendationType.buy:
        return Icons.trending_up;
      case RecommendationType.sell:
      case RecommendationType.strongSell:
        return Icons.trending_down;
      case RecommendationType.hold:
        return Icons.horizontal_rule;
      case RecommendationType.wait:
      case RecommendationType.unknown:
        return Icons.hourglass_empty;
    }
  }

  Color _colorFor(RecommendationType type) {
    switch (type) {
      case RecommendationType.strongBuy:
      case RecommendationType.buy:
        return Colors.green;
      case RecommendationType.sell:
      case RecommendationType.strongSell:
        return Colors.red;
      case RecommendationType.hold:
        return Colors.blueGrey;
      case RecommendationType.wait:
      case RecommendationType.unknown:
        return Colors.orange;
    }
  }

  String _formatAnalysisTime(DateTime? analysisTime) {
    if (analysisTime == null) {
      return 'Not available';
    }

    final hour = analysisTime.hour.toString().padLeft(2, '0');
    final minute = analysisTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}