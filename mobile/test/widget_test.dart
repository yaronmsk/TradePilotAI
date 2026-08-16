import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('TradePilot AI loads the default stock workspace', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const TradePilotApp());
    await tester.pumpAndSettle();

    expect(find.text('TradePilot AI'), findsOneWidget);
    expect(find.text('AAPL connected'), findsOneWidget);
    expect(find.text('Price History'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Recommendation'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Stock Behavior'), findsOneWidget);
    expect(find.text('Recommendation'), findsOneWidget);
    expect(find.text('Evidence Score'), findsOneWidget);
    expect(find.text('Waiting for Analysis'), findsNothing);
  });
}
