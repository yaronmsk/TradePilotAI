import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('TradePilot AI loads a strategy-aware default stock workspace', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const TradePilotApp());
    await tester.pumpAndSettle();

    expect(find.text('TradePilot AI'), findsOneWidget);
    expect(find.text('AAPL connected'), findsOneWidget);
    expect(find.text('Price History'), findsOneWidget);

    final dashboardScroll = find.byType(Scrollable).first;

    await tester.scrollUntilVisible(
      find.text('Strategy Summary'),
      250,
      scrollable: dashboardScroll,
    );
    expect(find.text('Strategy Summary'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Trader Analysis Context'),
      250,
      scrollable: dashboardScroll,
    );
    expect(find.text('Trader Analysis Context'), findsOneWidget);
    expect(find.text('Primary Analysis Interval'), findsOneWidget);
    expect(find.text('Market Environment'), findsOneWidget);

    final strategySummaryTop = tester
        .getTopLeft(find.text('Strategy Summary'))
        .dy;
    final analysisContextTop = tester
        .getTopLeft(find.text('Trader Analysis Context'))
        .dy;
    expect(strategySummaryTop, lessThan(analysisContextTop));

    await tester.scrollUntilVisible(
      find.text('Stock DNA'),
      250,
      scrollable: dashboardScroll,
    );
    expect(find.text('Stock DNA'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Trader Recommendation'),
      250,
      scrollable: dashboardScroll,
    );

    expect(find.text('Trader Recommendation'), findsOneWidget);
    expect(find.text('Trader Recommendation Insight'), findsOneWidget);
    expect(find.text('Confidence'), findsWidgets);
    expect(find.text('Waiting for Analysis'), findsNothing);
  });
}
