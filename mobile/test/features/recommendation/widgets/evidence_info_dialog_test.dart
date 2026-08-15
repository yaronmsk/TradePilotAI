import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/evidence_definition.dart';
import 'package:mobile/features/recommendation/widgets/evidence_info_dialog.dart';

void main() {
  testWidgets('displays evidence definition', (tester) async {
    const definition = EvidenceDefinition(
      name: 'Candle Trend',
      description: 'Description',
      whyItMatters: 'Importance',
      calculation: 'Calculation',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    EvidenceInfoDialog.show(context, definition: definition);
                  },
                  child: const Text('Open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));

    await tester.pumpAndSettle();

    expect(find.text('Candle Trend'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Importance'), findsOneWidget);
    expect(find.text('Calculation'), findsOneWidget);
  });
}
