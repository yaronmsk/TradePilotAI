import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/app.dart';

void main() {
  testWidgets('TradePilot AI app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const TradePilotApp());

    expect(find.text('TradePilot AI'), findsOneWidget);
    expect(find.text('Version 0.2'), findsOneWidget);
  });
}