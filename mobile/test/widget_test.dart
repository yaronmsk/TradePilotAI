import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/app.dart';

void main() {
  testWidgets('TradePilot AI app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const TradePilotApp());
    await tester.pumpAndSettle();

    expect(find.text('TradePilot AI'), findsOneWidget);
    expect(find.text('Waiting for Analysis'), findsOneWidget);
    expect(find.text('Evidence Score'), findsOneWidget);
  });
}