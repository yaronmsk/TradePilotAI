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
    expect(find.text('Why this result'), findsOneWidget);
  });

  testWidgets('uses clear WAIT wording and shows its dynamic explanation', (
    tester,
  ) async {
    final recommendation = Recommendation(
      type: RecommendationType.wait,
      evidenceScore: 54,
      decisionReasons: const [
        RecommendationDecisionReason.insufficientDirectionalStrength,
        RecommendationDecisionReason.insufficientConfidence,
      ],
      oneLineExplanation:
          'A bullish direction is forming, but the directional edge is not yet strong enough and confidence is still below the level required for a Buy recommendation.',
      timeframe: '4h',
      candleCount: 90,
      analysisTime: DateTime(2026, 8, 31, 20),
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
              strategy: StrategyType.swing,
              recommendation: recommendation,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Wait for Confirmation'), findsOneWidget);
    expect(find.text('Wait'), findsNothing);
    expect(find.text('Why this result'), findsOneWidget);
    expect(
      find.textContaining('directional edge is not yet strong enough'),
      findsOneWidget,
    );
    expect(find.textContaining('confidence is still below'), findsOneWidget);
  });

  testWidgets('uses No Clear Direction instead of HOLD portfolio wording', (
    tester,
  ) async {
    final recommendation = Recommendation(
      type: RecommendationType.hold,
      evidenceScore: 40,
      decisionReasons: const [RecommendationDecisionReason.materialConflict],
      oneLineExplanation:
          'Bullish and bearish evidence currently conflict, so there is no clear recommendation.',
      timeframe: '1d',
      candleCount: 90,
      analysisTime: DateTime(2026, 8, 31, 20),
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
              strategy: StrategyType.swing,
              recommendation: recommendation,
            ),
          ),
        ),
      ),
    );

    expect(find.text('No Clear Direction'), findsOneWidget);
    expect(find.text('Hold'), findsNothing);
    expect(find.text('Why this result'), findsOneWidget);
    expect(find.textContaining('evidence currently conflict'), findsOneWidget);
  });
}
