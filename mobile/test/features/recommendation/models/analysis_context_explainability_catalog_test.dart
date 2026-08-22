import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/recommendation/models/analysis_context_explainability_catalog.dart';
import 'package:mobile/features/recommendation/models/analysis_context_metric.dart';
import 'package:mobile/features/recommendation/models/metric_explainability.dart';

void main() {
  group('AnalysisContextExplainabilityCatalog', () {
    test('covers every Analysis Context metric', () {
      expect(
        AnalysisContextExplainabilityCatalog.definitions.keys,
        unorderedEquals(AnalysisContextMetric.values),
      );

      expect(AnalysisContextExplainabilityCatalog.coversAllMetrics, isTrue);
    });

    test('every Analysis Context explanation is complete', () {
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

    test('semantic roles preserve directional and confidence boundaries', () {
      expect(
        AnalysisContextExplainabilityCatalog.forMetric(
          AnalysisContextMetric.primaryAnalysisInterval,
        ).semanticRole,
        MetricSemanticRole.contextConfiguration,
      );

      expect(
        AnalysisContextExplainabilityCatalog.forMetric(
          AnalysisContextMetric.eventRisk,
        ).semanticRole,
        MetricSemanticRole.confidenceRiskOnly,
      );

      final directionalMetrics = {
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
  });
}
