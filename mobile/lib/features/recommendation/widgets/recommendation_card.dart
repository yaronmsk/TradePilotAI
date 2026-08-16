import 'package:flutter/material.dart';

import '../../../shared/widgets/dashboard_card.dart';
import '../models/strategy_recommendation.dart';
import '../presentation/recommendation_presentation.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key, required this.strategyRecommendation});

  final StrategyRecommendation strategyRecommendation;

  @override
  Widget build(BuildContext context) {
    final recommendation = strategyRecommendation.recommendation;
    final presentation = RecommendationPresentation.fromType(
      recommendation.type,
    );

    return DashboardCard(
      title: '${strategyRecommendation.title} Recommendation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strategyRecommendation.horizon,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(presentation.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                presentation.label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: presentation.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Confidence',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: recommendation.confidenceScore / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 6),
          Text(
            '${recommendation.confidenceScore.toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(recommendation.oneLineExplanation),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Text('Analysis timeframe: ${recommendation.timeframe}'),
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

  String _formatAnalysisTime(DateTime? analysisTime) {
    if (analysisTime == null) {
      return 'Not available';
    }

    final hour = analysisTime.hour.toString().padLeft(2, '0');
    final minute = analysisTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}
