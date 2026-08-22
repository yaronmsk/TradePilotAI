import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/recommendation/models/evidence_definition.dart';
import 'package:mobile/features/recommendation/models/evidence_explainability_catalog.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';

void main() {
  group('EvidenceDefinition', () {
    test('stores existing evidence definition information', () {
      const definition = EvidenceDefinition(
        family: EvidenceFamily.trend,
        name: 'Candle Trend',
        description: 'Measures recent price direction.',
        whyItMatters: 'Price trends often indicate market momentum.',
        calculation: 'Percentage change between first and last candle.',
      );

      expect(definition.name, 'Candle Trend');
      expect(definition.family, EvidenceFamily.trend);
      expect(definition.description, 'Measures recent price direction.');
      expect(
        definition.whyItMatters,
        'Price trends often indicate market momentum.',
      );
      expect(
        definition.calculation,
        'Percentage change between first and last candle.',
      );

      expect(definition.explainability, isNull);
      expect(definition.hasCompleteExplainability, isFalse);
    });

    test('reports complete explicit explainability when metadata is complete', () {
      const definition = EvidenceDefinition(
        family: EvidenceFamily.trend,
        name: 'Candle Trend',
        description: 'Measures recent price direction.',
        whyItMatters: 'Price trends often indicate market momentum.',
        calculation: 'Percentage change between first and last candle.',
        explainability: MetricExplainability(
          semanticRole: MetricSemanticRole.directionalEvaluative,
          whatItIs: 'Measures recent price direction.',
          calculation: 'Compares the first and last closing prices.',
          whyItMatters: 'Trend direction helps describe current momentum.',
          supportiveInterpretation:
              'A positive trend supports bullish directional evidence.',
          opposingInterpretation:
              'A negative trend supports bearish directional evidence.',
          neutralInterpretation:
              'A small move does not provide meaningful directional evidence.',
          recommendationImpact:
              'It can affect direction and confidence subject to Trend-family aggregation.',
          limitations:
              'Short lookbacks can be noisy and do not guarantee continuation.',
        ),
      );

      expect(definition.hasCompleteExplainability, isTrue);
      expect(definition.explainability!.allowsDirectionalInfluence, isTrue);
    });

    test('production evidence resolves explainability from its kind', () {
      const definition = EvidenceDefinition(
        kind: EvidenceKind.rsi,
        family: EvidenceFamily.momentum,
        name: 'RSI',
        description: 'Momentum metric.',
        whyItMatters: 'Identifies stretched momentum.',
        calculation: 'Calculated from recent gains and losses.',
      );

      expect(definition.explainability, isNotNull);
      expect(definition.hasCompleteExplainability, isTrue);
      expect(
        definition.explainability!.semanticRole,
        MetricSemanticRole.directionalEvaluative,
      );
    });
  });

  group('EvidenceExplainabilityCatalog', () {
    test('covers every production EvidenceKind', () {
      final productionKinds = EvidenceKind.values
          .where((kind) => kind != EvidenceKind.generic)
          .toSet();

      expect(
        EvidenceExplainabilityCatalog.definitions.keys,
        unorderedEquals(productionKinds),
      );

      expect(EvidenceExplainabilityCatalog.coversAllProductionKinds, isTrue);
    });

    test('every production evidence explanation is complete', () {
      for (final kind in EvidenceKind.values) {
        if (kind == EvidenceKind.generic) {
          continue;
        }

        final explainability = EvidenceExplainabilityCatalog.forKind(kind);

        expect(
          explainability,
          isNotNull,
          reason: '$kind must have explainability metadata.',
        );

        expect(
          explainability!.isComplete,
          isTrue,
          reason: '$kind must have complete explainability metadata.',
        );

        expect(
          explainability.semanticRole,
          MetricSemanticRole.directionalEvaluative,
          reason:
              '$kind is production evidence and must explicitly declare its directional/evaluative role.',
        );
      }
    });
  });

  group('MetricExplainability', () {
    test(
      'directional metrics require supportive and opposing interpretations',
      () {
        const explainability = MetricExplainability(
          semanticRole: MetricSemanticRole.directionalEvaluative,
          whatItIs: 'A directional metric.',
          calculation: 'Calculated from market data.',
          whyItMatters: 'It can add directional evidence.',
          supportiveInterpretation: 'Can support the analyzed direction.',
          recommendationImpact: 'May influence direction and confidence.',
          limitations: 'It is not reliable in every market regime.',
        );

        expect(explainability.isComplete, isFalse);
        expect(explainability.allowsDirectionalInfluence, isTrue);
      },
    );

    test('confidence/risk-only metrics require a bounded impact', () {
      const withoutBound = MetricExplainability(
        semanticRole: MetricSemanticRole.confidenceRiskOnly,
        whatItIs: 'Measures scheduled event risk.',
        calculation: 'Uses event proximity and event importance.',
        whyItMatters: 'Events can increase uncertainty.',
        recommendationImpact:
            'It can reduce confidence but cannot create directional evidence.',
        limitations: 'Unexpected events are not captured.',
      );

      const withBound = MetricExplainability(
        semanticRole: MetricSemanticRole.confidenceRiskOnly,
        whatItIs: 'Measures scheduled event risk.',
        calculation: 'Uses event proximity and event importance.',
        whyItMatters: 'Events can increase uncertainty.',
        recommendationImpact:
            'It can reduce confidence but cannot create directional evidence.',
        limitations: 'Unexpected events are not captured.',
        boundedImpact:
            'Confidence reduction is capped and cannot create Buy/Sell direction.',
      );

      expect(withoutBound.isComplete, isFalse);
      expect(withBound.isComplete, isTrue);
      expect(withBound.allowsDirectionalInfluence, isFalse);
    });

    test(
      'context/configuration metrics do not require artificial directional interpretations',
      () {
        const explainability = MetricExplainability(
          semanticRole: MetricSemanticRole.contextConfiguration,
          whatItIs: 'The selected primary analysis interval.',
          calculation: 'Selected by the user from supported Trader intervals.',
          whyItMatters:
              'It determines which candle interval feeds primary analysis.',
          recommendationImpact:
              'It changes analysis configuration rather than directly creating bullish or bearish evidence.',
          limitations:
              'Changing the interval can materially change the observed setup.',
        );

        expect(explainability.isComplete, isTrue);
        expect(explainability.allowsDirectionalInfluence, isFalse);
      },
    );
  });
}
