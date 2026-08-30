import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/widgets/strategy_summary_card.dart';

void main() {
  const strategies = [
    StrategySummary(
      type: StrategyType.trader,
      title: 'Trader',
      status: StrategyStatus.active,
      recommendation: 'Buy',
      confidence: 78,
      horizon: 'Hours–Days',
    ),
    StrategySummary(
      type: StrategyType.swing,
      title: 'Swing',
      status: StrategyStatus.active,
      recommendation: 'Hold',
      confidence: 66,
      horizon: 'Days–Weeks',
    ),
    StrategySummary(
      type: StrategyType.investor,
      title: 'Investor',
      status: StrategyStatus.comingSoon,
      horizon: 'Months–Years',
    ),
  ];

  testWidgets('selects only available strategies', (tester) async {
    StrategyType? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StrategySummaryCard(
            strategies: strategies,
            selectedType: StrategyType.trader,
            onStrategySelected: (strategy) {
              selected = strategy;
            },
          ),
        ),
      ),
    );

    expect(find.text('Selected'), findsOneWidget);

    await tester.tap(find.text('Swing'));
    await tester.pump();

    expect(selected, StrategyType.swing);

    selected = null;

    await tester.tap(find.text('Investor'));
    await tester.pump();

    expect(selected, isNull);
  });

  testWidgets(
    'allows an active strategy to be selected before its first analysis',
    (tester) async {
      StrategyType? selected;

      const readyStrategies = [
        StrategySummary(
          type: StrategyType.trader,
          title: 'Trader',
          status: StrategyStatus.active,
          recommendation: 'Hold',
          confidence: 70,
          horizon: 'Hours–Days',
        ),
        StrategySummary(
          type: StrategyType.swing,
          title: 'Swing',
          status: StrategyStatus.active,
          recommendation: 'Ready to analyze',
          confidence: null,
          horizon: 'Days–Weeks',
        ),
        StrategySummary(
          type: StrategyType.investor,
          title: 'Investor',
          status: StrategyStatus.comingSoon,
          horizon: 'Months–Years',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StrategySummaryCard(
              strategies: readyStrategies,
              selectedType: StrategyType.trader,
              onStrategySelected: (strategy) {
                selected = strategy;
              },
            ),
          ),
        ),
      );

      expect(find.text('Ready to analyze'), findsOneWidget);
      expect(find.text('Tap to run'), findsOneWidget);
      expect(find.text('🚧 Coming Soon'), findsOneWidget);

      await tester.tap(find.text('Swing'));
      await tester.pump();

      expect(selected, StrategyType.swing);
    },
  );
}
