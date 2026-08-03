import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('TradePilot AI app loads and analyzes the default stock', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const TradePilotApp());
    await tester.pumpAndSettle();

    expect(find.text('TradePilot AI'), findsOneWidget);
    expect(find.text('Evidence Score'), findsOneWidget);
    expect(find.text('Waiting for Analysis'), findsNothing);
    expect(find.text('AAPL connected'), findsOneWidget);
  });
}
