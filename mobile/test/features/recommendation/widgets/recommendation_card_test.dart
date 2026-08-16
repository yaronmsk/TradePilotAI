import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/evidence_report.dart';
import 'package:mobile/features/recommendation/models/recommendation.dart';
import 'package:mobile/features/recommendation/models/strategy_recommendation.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/widgets/recommendation_card.dart';

void main() {
  testWidgets('makes recommendation strategy context explicit', (tester) async {
    final recommendation = Recommendation(
      type: RecommendationType.buy,
      evidenceScore: 72,
      oneLineExplanation: 'Bullish evidence leads.',
      timeframe: '5m',
      candleCount: 48,
      analysisTime: DateTime(2026, 8, 16, 10),
      evidenceReport: EvidenceReport.fromResults(
        results: const [],
        expectedProviderCount: 0,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecommendationCard(
            strategyRecommendation: StrategyRecommendation(
              strategy: StrategyType.trader,
              recommendation: recommendation,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Trader Recommendation'), findsOneWidget);
    expect(find.text('Hours–Days'), findsOneWidget);
    expect(find.text('Confidence'), findsOneWidget);
    expect(find.text('72%'), findsOneWidget);
  });
}
