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
    expect(find.text('Watchlist'), findsOneWidget);

    final dashboardScroll = find.byType(Scrollable).first;

    await tester.scrollUntilVisible(
      find.text('Market Status'),
      250,
      scrollable: dashboardScroll,
    );
    expect(find.text('Market Status'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('AAPL connected'),
      200,
      scrollable: dashboardScroll,
    );
    expect(find.text('AAPL connected'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Price History'),
      200,
      scrollable: dashboardScroll,
    );
    expect(find.text('Price History'), findsOneWidget);

    final watchlistTop = tester.getTopLeft(find.text('Watchlist')).dy;
    final marketStatusTop = tester.getTopLeft(find.text('Market Status')).dy;
    expect(watchlistTop, lessThan(marketStatusTop));

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

    await tester.scrollUntilVisible(
      find.text('Historical Setup Check'),
      250,
      scrollable: dashboardScroll,
    );
    expect(find.text('Historical Setup Check'), findsOneWidget);
    expect(find.textContaining('similar cases'), findsOneWidget);
    expect(find.text('Waiting for Analysis'), findsNothing);

    // Batch 9A2: activate Swing through the real dashboard UI.
    await tester.scrollUntilVisible(
      find.text('Strategy Summary'),
      -250,
      scrollable: dashboardScroll,
    );

    expect(find.text('Ready to analyze'), findsOneWidget);
    expect(find.text('Tap to run'), findsOneWidget);
    expect(find.text('🚧 Coming Soon'), findsOneWidget);

    await tester.tap(find.text('Swing'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Swing Analysis Context'),
      250,
      scrollable: dashboardScroll,
    );
    expect(find.text('Swing Analysis Context'), findsOneWidget);
    expect(find.text('Primary Analysis Interval'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Swing Recommendation'),
      250,
      scrollable: dashboardScroll,
    );
    expect(find.text('Swing Recommendation'), findsOneWidget);
    expect(find.text('Swing Recommendation Insight'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Swing Decision Helper'),
      250,
      scrollable: dashboardScroll,
    );
    expect(find.text('Swing Decision Helper'), findsOneWidget);
    expect(find.text('Entry Quality'), findsOneWidget);
    expect(find.text('Price Stretch'), findsOneWidget);
    expect(find.text('Structure Watch'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Swing Evidence'),
      250,
      scrollable: dashboardScroll,
    );
    expect(find.text('Swing Evidence'), findsOneWidget);
    expect(find.text('Waiting for Analysis'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Version 0.11'),
      250,
      scrollable: dashboardScroll,
    );
    expect(find.text('Version 0.11'), findsOneWidget);
  });
}
