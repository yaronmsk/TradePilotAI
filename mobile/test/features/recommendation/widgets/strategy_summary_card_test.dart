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
}
