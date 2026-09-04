import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/investor/engines/investor_recommendation_engine.dart';
import 'package:mobile/features/recommendation/investor/models/investor_metric_assessment.dart';
import 'package:mobile/features/recommendation/investor/strategy/investor_recommendation_policy.dart';
import 'package:mobile/features/recommendation/models/evidence_definition.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/recommendation.dart';

void main() {
  const engine = InvestorRecommendationEngine();
  final analysisTime = DateTime(2026, 9, 4);

  InvestorEvidenceAssessment assessment(
    EvidenceFamily family,
    EvidenceDirection direction,
    double score, {
    double reliability = 1,
  }) {
    return InvestorEvidenceAssessment(
      evidence: EvidenceResult(
        providerName: 'Test ${family.name}',
        definition: EvidenceDefinition(
          family: family,
          name: family.name,
          description: 'Test Investor evidence',
          whyItMatters: 'Test Investor evidence',
          calculation: 'Test Investor evidence',
        ),
        status: EvidenceStatus.available,
        direction: direction,
        strength: score >= 80
            ? EvidenceStrength.exceptional
            : score >= 60
            ? EvidenceStrength.strong
            : score >= 35
            ? EvidenceStrength.moderate
            : EvidenceStrength.weak,
        score: score,
        baseWeight: 1,
        dynamicWeight: 1,
        reliability: reliability,
        currentValue: 'Test',
        baselineValue: 'Test',
        relativeValue: 'Test',
        explanation: 'Test',
      ),
      metrics: const [],
    );
  }

  List<InvestorEvidenceAssessment> allCore(
    EvidenceDirection direction,
    double score,
  ) {
    return [
      for (final family
          in InvestorRecommendationPolicy.breadthEligibleCoreFamilies)
        assessment(family, direction, score),
    ];
  }

  test('strong core breadth produces symmetric strong BUY', () {
    final result = engine.create(
      assessments: allCore(EvidenceDirection.bullish, 80),
      analysisTime: analysisTime,
    );

    expect(result.recommendation.type, RecommendationType.strongBuy);
    expect(result.coreFamilyCount, 6);
    expect(result.coreCoverage, 1);
    expect(result.requiredCoreFamiliesAvailable, isTrue);
  });

  test('strong core breadth produces symmetric strong SELL', () {
    final result = engine.create(
      assessments: allCore(EvidenceDirection.bearish, 80),
      analysisTime: analysisTime,
    );

    expect(result.recommendation.type, RecommendationType.strongSell);
    expect(
      result.recommendation.decisionReasons,
      contains(RecommendationDecisionReason.strongBearishAction),
    );
  });

  test('context cannot substitute for missing core breadth', () {
    final result = engine.create(
      assessments: [
        assessment(EvidenceFamily.growth, EvidenceDirection.bullish, 90),
        assessment(
          EvidenceFamily.profitabilityQuality,
          EvidenceDirection.bullish,
          90,
        ),
        assessment(EvidenceFamily.valuation, EvidenceDirection.bullish, 90),
        assessment(
          EvidenceFamily.marketContext,
          EvidenceDirection.bullish,
          100,
        ),
        assessment(
          EvidenceFamily.ownershipPositioning,
          EvidenceDirection.bullish,
          100,
        ),
      ],
      analysisTime: analysisTime,
    );

    expect(result.coreFamilyCount, 3);
    expect(result.recommendation.type, RecommendationType.wait);
    expect(
      result.recommendation.decisionReasons,
      contains(RecommendationDecisionReason.insufficientFamilyBreadth),
    );
  });

  test(
    'Valuation missing blocks action even with five other core families',
    () {
      final families = InvestorRecommendationPolicy.breadthEligibleCoreFamilies
          .where((family) => family != EvidenceFamily.valuation);

      final result = engine.create(
        assessments: [
          for (final family in families)
            assessment(family, EvidenceDirection.bullish, 90),
        ],
        analysisTime: analysisTime,
      );

      expect(result.coreFamilyCount, 5);
      expect(result.requiredCoreFamiliesAvailable, isFalse);
      expect(result.recommendation.type, RecommendationType.wait);
      expect(result.recommendation.oneLineExplanation, contains('Valuation'));
    },
  );

  test('collective contextual direction is capped at 20 percent', () {
    final result = engine.create(
      assessments: [
        ...allCore(EvidenceDirection.bullish, 50),
        assessment(
          EvidenceFamily.marketContext,
          EvidenceDirection.bearish,
          100,
        ),
        assessment(
          EvidenceFamily.ownershipPositioning,
          EvidenceDirection.bearish,
          100,
        ),
      ],
      analysisTime: analysisTime,
    );

    expect(
      result.contextDirectionShare,
      lessThanOrEqualTo(
        InvestorRecommendationPolicy.maximumContextDirectionShare + 0.000001,
      ),
    );
    expect(result.contextDirectionScale, lessThan(1));
    expect(result.recommendation.directionScore, greaterThan(0));
  });

  test('Competitive Durability cannot double vote current Quality inputs', () {
    final result = engine.create(
      assessments: [
        ...allCore(EvidenceDirection.bullish, 60),
        assessment(
          EvidenceFamily.competitiveDurability,
          EvidenceDirection.bearish,
          100,
        ),
      ],
      analysisTime: analysisTime,
    );

    expect(
      result.excludedRecommendationFamilies,
      contains(EvidenceFamily.competitiveDurability),
    );
    expect(
      result.recommendation.consensus.familyContributions
          .where(
            (contribution) =>
                contribution.family == EvidenceFamily.competitiveDurability,
          )
          .isEmpty,
      isTrue,
    );
    expect(result.coreFamilyCount, 6);
  });

  test('context receives direction attribution but zero confidence share', () {
    final result = engine.create(
      assessments: [
        ...allCore(EvidenceDirection.bullish, 70),
        assessment(EvidenceFamily.marketContext, EvidenceDirection.bullish, 90),
        assessment(
          EvidenceFamily.ownershipPositioning,
          EvidenceDirection.bullish,
          80,
        ),
      ],
      analysisTime: analysisTime,
    );

    final contextContributions = result
        .recommendation
        .consensus
        .familyContributions
        .where(
          (contribution) => InvestorRecommendationPolicy
              .directionalContextFamilies
              .contains(contribution.family),
        )
        .toList();

    expect(contextContributions, isNotEmpty);
    expect(
      contextContributions.fold<double>(
        0,
        (sum, contribution) => sum + contribution.confidenceShare,
      ),
      0,
    );

    final coreConfidenceShare = result
        .recommendation
        .consensus
        .familyContributions
        .where(
          (contribution) => InvestorRecommendationPolicy
              .breadthEligibleCoreFamilies
              .contains(contribution.family),
        )
        .fold<double>(
          0,
          (sum, contribution) => sum + contribution.confidenceShare,
        );

    expect(coreConfidenceShare, closeTo(1, 0.000001));
    expect(
      result.recommendation.consensus.directionAttributionShareTotal,
      closeTo(1, 0.000001),
    );
    expect(
      result.recommendation.consensus.directionReconciliationError.abs(),
      lessThan(0.000001),
    );
    expect(
      result.recommendation.consensus.providerDirectionReconciliationError
          .abs(),
      lessThan(0.000001),
    );
  });

  test('material conflict among core fundamentals forces HOLD', () {
    final coreFamilies = InvestorRecommendationPolicy
        .breadthEligibleCoreFamilies
        .toList();

    final result = engine.create(
      assessments: [
        for (var index = 0; index < coreFamilies.length; index++)
          assessment(
            coreFamilies[index],
            index < 3 ? EvidenceDirection.bullish : EvidenceDirection.bearish,
            80,
          ),
      ],
      analysisTime: analysisTime,
    );

    expect(result.recommendation.type, RecommendationType.hold);
    expect(
      result.recommendation.decisionReasons,
      contains(RecommendationDecisionReason.materialConflict),
    );
  });
}
