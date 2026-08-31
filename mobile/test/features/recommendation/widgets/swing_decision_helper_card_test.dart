import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/metric_explainability.dart';
import 'package:mobile/features/recommendation/models/swing_decision_helper.dart';
import 'package:mobile/features/recommendation/widgets/swing_decision_helper_card.dart';

const helperExplainability = MetricExplainability(
  semanticRole: MetricSemanticRole.confidenceRiskOnly,
  whatItIs: 'Test helper meaning.',
  calculation: 'Test helper calculation.',
  whyItMatters: 'Test helper relevance.',
  recommendationImpact: 'Test helper adds no new score or evidence vote.',
  limitations: 'Test limitation.',
  boundedImpact: 'The helper adds 0 direction points and 0 confidence points.',
);

void main() {
  testWidgets('shows the three Swing decision-helper concepts', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SwingDecisionHelperCard(summary: summary),
          ),
        ),
      ),
    );

    expect(find.text('Swing Decision Helper'), findsOneWidget);
    expect(find.text('Entry Quality'), findsOneWidget);
    expect(find.text('Favorable'), findsOneWidget);
    expect(find.text('Price Stretch'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
    expect(find.text('Structure Watch'), findsOneWidget);
    expect(find.text('Near key level'), findsOneWidget);
    expect(
      find.text('No extra score or evidence vote is added.'),
      findsOneWidget,
    );
  });

  testWidgets('gives each helper value its own explainability path', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SwingDecisionHelperCard(summary: summary),
          ),
        ),
      ),
    );

    expect(find.byTooltip('About Entry Quality'), findsOneWidget);
    expect(find.byTooltip('About Price Stretch'), findsOneWidget);
    expect(find.byTooltip('About Structure Watch'), findsOneWidget);

    await tester.tap(find.byTooltip('About Entry Quality'));
    await tester.pumpAndSettle();

    expect(find.text('About Entry Quality'), findsOneWidget);
    expect(find.text('Confidence / risk only'), findsOneWidget);
    expect(
      find.text('The helper adds 0 direction points and 0 confidence points.'),
      findsOneWidget,
    );
  });
}

const summary = SwingDecisionHelperSummary(
  entryQuality: SwingDecisionHelperMetric(
    label: 'Entry Quality',
    value: 'Favorable',
    detail: 'Price stretch is normal and structure is supportive.',
    explainability: helperExplainability,
  ),
  priceStretch: SwingDecisionHelperMetric(
    label: 'Price Stretch',
    value: 'Normal',
    detail: 'Current stretch: +0.80 ATR.',
    explainability: helperExplainability,
  ),
  structureWatch: SwingDecisionHelperMetric(
    label: 'Structure Watch',
    value: 'Near key level',
    detail: 'Price is close to a structural level.',
    explainability: helperExplainability,
  ),
);
