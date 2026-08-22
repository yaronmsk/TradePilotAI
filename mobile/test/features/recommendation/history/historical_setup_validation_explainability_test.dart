import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/recommendation/history/historical_setup_validation.dart';
import 'package:mobile/features/recommendation/history/historical_setup_validation_explainability.dart';
import 'package:mobile/features/recommendation/models/metric_explainability.dart';

void main() {
  group('HistoricalSetupValidationExplainability', () {
    test('is a complete confidence-risk-only explanation', () {
      const explanation = HistoricalSetupValidationExplainability.definition;

      expect(explanation.isComplete, isTrue);
      expect(explanation.semanticRole, MetricSemanticRole.confidenceRiskOnly);
      expect(explanation.allowsDirectionalInfluence, isFalse);
    });

    test('explicitly explains supportive and opposing historical outcomes', () {
      const explanation = HistoricalSetupValidationExplainability.definition;

      expect(explanation.supportiveInterpretation, isNotNull);
      expect(explanation.opposingInterpretation, isNotNull);

      expect(
        explanation.supportiveInterpretation,
        contains('above both 50% and the same-stock baseline'),
      );

      expect(explanation.opposingInterpretation, contains('reduce confidence'));

      expect(
        explanation.opposingInterpretation,
        contains('cannot reverse the recommendation direction'),
      );
    });

    test('documents the architectural confidence boundary', () {
      const explanation = HistoricalSetupValidationExplainability.definition;

      expect(HistoricalSetupValidation.maximumConfidenceImpactPoints, 8);

      expect(explanation.boundedImpact, contains('±8 points'));
      expect(
        explanation.boundedImpact,
        contains('cannot create or flip Buy/Sell direction'),
      );
    });
  });
}
