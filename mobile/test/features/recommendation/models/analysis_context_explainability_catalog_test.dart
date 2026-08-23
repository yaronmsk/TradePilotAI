import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/recommendation/models/analysis_context_explainability_catalog.dart';
import 'package:mobile/features/recommendation/models/analysis_context_metric.dart';
import 'package:mobile/features/recommendation/models/metric_explainability.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';

void main() {
  group('AnalysisContextExplainabilityCatalog', () {
    test('covers every Analysis Context metric', () {
      expect(
        AnalysisContextExplainabilityCatalog.definitions.keys,
        unorderedEquals(AnalysisContextMetric.values),
      );

      expect(AnalysisContextExplainabilityCatalog.coversAllMetrics, isTrue);
    });

    test('every default Analysis Context explanation is complete', () {
      for (final metric in AnalysisContextMetric.values) {
        final explanation = AnalysisContextExplainabilityCatalog.forMetric(
          metric,
        );

        expect(
          explanation.isComplete,
          isTrue,
          reason: '${metric.label} must have complete explainability metadata.',
        );
      }
    });

    test('timeframe interval metrics are context/configuration', () {
      const metrics = {
        AnalysisContextMetric.primaryAnalysisInterval,
        AnalysisContextMetric.confirmationInterval,
        AnalysisContextMetric.broaderRegimeInterval,
      };

      for (final metric in metrics) {
        expect(
          AnalysisContextExplainabilityCatalog.forMetric(metric).semanticRole,
          MetricSemanticRole.contextConfiguration,
          reason: '${metric.label} must not manufacture direction.',
        );
      }
    });

    test('semantic roles preserve directional and confidence boundaries', () {
      expect(
        AnalysisContextExplainabilityCatalog.forMetric(
          AnalysisContextMetric.eventRisk,
        ).semanticRole,
        MetricSemanticRole.confidenceRiskOnly,
      );

      const directionalMetrics = {
        AnalysisContextMetric.timeframeAlignment,
        AnalysisContextMetric.marketEnvironment,
        AnalysisContextMetric.marketBreadth,
        AnalysisContextMetric.relativeStrength,
        AnalysisContextMetric.newsSentiment,
      };

      for (final metric in directionalMetrics) {
        expect(
          AnalysisContextExplainabilityCatalog.forMetric(metric).semanticRole,
          MetricSemanticRole.directionalEvaluative,
          reason: '${metric.label} must remain directional/evaluative.',
        );
      }
    });

    test('Event Risk cannot claim directional influence', () {
      final eventRisk = AnalysisContextExplainabilityCatalog.forMetric(
        AnalysisContextMetric.eventRisk,
      );

      expect(eventRisk.allowsDirectionalInfluence, isFalse);
      expect(eventRisk.supportiveInterpretation, isNull);
      expect(eventRisk.opposingInterpretation, isNull);
      expect(eventRisk.boundedImpact, contains('at most 12 points'));
      expect(
        eventRisk.boundedImpact,
        contains('cannot create Buy/Sell direction'),
      );
    });

    test('Swing timeframe explanations are strategy-specific and complete', () {
      const metrics = {
        AnalysisContextMetric.primaryAnalysisInterval,
        AnalysisContextMetric.confirmationInterval,
        AnalysisContextMetric.broaderRegimeInterval,
        AnalysisContextMetric.timeframeAlignment,
      };

      for (final metric in metrics) {
        final explanation = AnalysisContextExplainabilityCatalog.forMetric(
          metric,
          strategy: StrategyType.swing,
        );

        expect(
          explanation.isComplete,
          isTrue,
          reason: '${metric.label} needs complete Swing explainability.',
        );
      }
    });

    test('Swing confirmation cannot independently flip primary direction', () {
      final confirmation = AnalysisContextExplainabilityCatalog.forMetric(
        AnalysisContextMetric.confirmationInterval,
        strategy: StrategyType.swing,
      );

      expect(
        confirmation.recommendationImpact,
        contains('cannot independently flip'),
      );

      expect(confirmation.allowsDirectionalInfluence, isFalse);
    });

    test('Swing alignment explains role weights without fake attribution', () {
      final alignment = AnalysisContextExplainabilityCatalog.forMetric(
        AnalysisContextMetric.timeframeAlignment,
        strategy: StrategyType.swing,
      );

      expect(alignment.calculation, contains('60%'));
      expect(alignment.calculation, contains('25%'));
      expect(alignment.calculation, contains('15%'));

      expect(
        alignment.recommendationImpact,
        contains('not percentages of the final recommendation'),
      );

      expect(alignment.limitations, contains('not statistically optimized'));
    });
  });
}
