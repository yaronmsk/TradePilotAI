import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/recommendation/models/evidence_definition.dart';
import 'package:mobile/features/recommendation/widgets/evidence_info_dialog.dart';

void main() {
  testWidgets('generic evidence retains the legacy explanation fallback', (
    tester,
  ) async {
    const definition = EvidenceDefinition(
      name: 'Legacy Evidence',
      description: 'Legacy description',
      whyItMatters: 'Legacy importance',
      calculation: 'Legacy calculation',
    );

    await _openDialog(tester, definition: definition);

    expect(find.text('Legacy Evidence'), findsOneWidget);
    expect(find.text('Legacy description'), findsOneWidget);
    expect(find.text('Legacy importance'), findsOneWidget);
    expect(find.text('Legacy calculation'), findsOneWidget);

    expect(find.text('Semantic role'), findsNothing);
    expect(find.text('Supportive interpretation'), findsNothing);
    expect(find.text('Opposing interpretation'), findsNothing);
    expect(find.text('Limitations'), findsNothing);
  });

  testWidgets(
    'production evidence renders the reusable explainability contract',
    (tester) async {
      const definition = EvidenceDefinition(
        kind: EvidenceKind.rsi,
        name: 'RSI',
        description: 'Legacy RSI description',
        whyItMatters: 'Legacy RSI importance',
        calculation: 'Legacy RSI calculation',
      );

      await _openDialog(tester, definition: definition);

      expect(find.text('RSI'), findsOneWidget);

      expect(find.text('Semantic role'), findsOneWidget);
      expect(find.text('Directional / evaluative'), findsOneWidget);

      expect(find.text('What does this mean?'), findsOneWidget);
      expect(find.text('How is it calculated?'), findsOneWidget);
      expect(find.text('Why does it matter?'), findsOneWidget);

      expect(find.text('Supportive interpretation'), findsOneWidget);
      expect(find.text('Opposing interpretation'), findsOneWidget);
      expect(find.text('Neutral interpretation'), findsOneWidget);

      expect(
        find.text('How does it affect the recommendation?'),
        findsOneWidget,
      );
      expect(find.text('Limitations'), findsOneWidget);

      expect(find.textContaining('scale from 0 to 100'), findsOneWidget);

      expect(find.textContaining('Momentum family'), findsOneWidget);

      expect(find.textContaining('past direction'), findsNothing);
    },
  );

  testWidgets('confidence-risk explanation renders its explicit impact boundary', (
    tester,
  ) async {
    const definition = EvidenceDefinition(
      name: 'Event Risk Example',
      description: 'Legacy description',
      whyItMatters: 'Legacy importance',
      calculation: 'Legacy calculation',
      explainability: MetricExplainability(
        semanticRole: MetricSemanticRole.confidenceRiskOnly,
        whatItIs: 'Measures scheduled-event uncertainty.',
        calculation: 'Uses event proximity and importance.',
        whyItMatters: 'Events can increase uncertainty.',
        recommendationImpact:
            'It can reduce confidence but cannot create directional evidence.',
        limitations: 'Unexpected events cannot be known in advance.',
        boundedImpact:
            'Confidence reduction is capped and cannot create Buy/Sell direction.',
      ),
    );

    await _openDialog(tester, definition: definition);

    expect(find.text('Confidence / risk only'), findsOneWidget);

    expect(find.text('Impact boundary'), findsOneWidget);

    expect(
      find.text(
        'Confidence reduction is capped and cannot create Buy/Sell direction.',
      ),
      findsOneWidget,
    );

    expect(find.text('Supportive interpretation'), findsNothing);
    expect(find.text('Opposing interpretation'), findsNothing);
  });
}

Future<void> _openDialog(
  WidgetTester tester, {
  required EvidenceDefinition definition,
}) async {
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
}
