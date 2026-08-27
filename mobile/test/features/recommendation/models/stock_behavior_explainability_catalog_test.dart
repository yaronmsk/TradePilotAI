import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/metric_explainability.dart';
import 'package:mobile/features/recommendation/models/stock_behavior_explainability_catalog.dart';

void main() {
  group('StockBehaviorExplainabilityCatalog', () {
    for (final metric in StockBehaviorMetric.values) {
      test('\$metric has complete context explainability', () {
        final explanation = StockBehaviorExplainabilityCatalog.forMetric(
          metric,
        );

        expect(explanation.isComplete, isTrue);
        expect(
          explanation.semanticRole,
          MetricSemanticRole.contextConfiguration,
        );
        expect(explanation.allowsDirectionalInfluence, isFalse);
        expect(
          explanation.recommendationImpact,
          contains('Buy/Sell direction'),
        );
      });
    }
  });
}
