import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/recommendation_attribution_explainability.dart';

void main() {
  group('RecommendationAttributionExplainability', () {
    test('every attribution metric has a complete explainability path', () {
      for (final definition in RecommendationAttributionExplainability.all) {
        expect(definition.isComplete, isTrue);
      }
    });

    test(
      'only direction attribution definitions allow directional influence',
      () {
        expect(
          RecommendationAttributionExplainability
              .directionInfluence
              .allowsDirectionalInfluence,
          isTrue,
        );

        expect(
          RecommendationAttributionExplainability
              .providerDirectionImpact
              .allowsDirectionalInfluence,
          isTrue,
        );

        final confidenceOnly = [
          RecommendationAttributionExplainability.evidenceConfidenceShare,
          RecommendationAttributionExplainability
              .providerConfidenceContribution,
          RecommendationAttributionExplainability.evidenceStrengthBaseline,
          RecommendationAttributionExplainability.evidenceQualityAdjustment,
          RecommendationAttributionExplainability.evidenceDerivedConfidence,
          RecommendationAttributionExplainability.eventRiskAdjustment,
          RecommendationAttributionExplainability
              .historicalValidationAdjustment,
          RecommendationAttributionExplainability.finalConfidence,
        ];

        for (final definition in confidenceOnly) {
          expect(definition.allowsDirectionalInfluence, isFalse);
        }
      },
    );

    test(
      'external confidence explainability preserves hard direction boundaries',
      () {
        final eventRisk =
            RecommendationAttributionExplainability.eventRiskAdjustment;

        final historical = RecommendationAttributionExplainability
            .historicalValidationAdjustment;

        expect(eventRisk.boundedImpact, contains('12-point'));

        expect(
          eventRisk.boundedImpact,
          contains('Directional influence is exactly zero'),
        );

        expect(historical.boundedImpact, contains('±8'));

        expect(
          historical.boundedImpact,
          contains('zero directional influence'),
        );
      },
    );

    test(
      'provider direction explanation rejects recommendation percentages',
      () {
        final provider =
            RecommendationAttributionExplainability.providerDirectionImpact;

        expect(
          provider.limitations,
          contains(
            'Provider-level percentages are intentionally not presented',
          ),
        );

        expect(
          provider.recommendationImpact,
          contains('cannot bypass the family cap'),
        );
      },
    );
  });
}
