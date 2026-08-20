import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/widgets/collapsible_dashboard_card.dart';

void main() {
  testWidgets('collapses and expands its content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CollapsibleDashboardCard(
            title: 'Example',
            collapsedSummary: Text('Summary'),
            child: Text('Expanded content'),
          ),
        ),
      ),
    );

    expect(find.text('Expanded content'), findsOneWidget);
    expect(find.text('Summary'), findsNothing);
    await tester.tap(find.byTooltip('Collapse'));
    await tester.pumpAndSettle();
    expect(find.text('Expanded content'), findsNothing);
    expect(find.text('Summary'), findsOneWidget);
    await tester.tap(find.byTooltip('Expand'));
    await tester.pumpAndSettle();
    expect(find.text('Expanded content'), findsOneWidget);
    expect(find.text('Summary'), findsNothing);
  });
}
