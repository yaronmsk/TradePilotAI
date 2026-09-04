import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/investor/strategy/investor_recommendation_policy.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';

void main() {
  test('Investor action policy freezes conservative core thresholds', () {
    expect(InvestorRecommendationPolicy.expectedCoreFamilyCount, 6);
    expect(InvestorRecommendationPolicy.minimumCoreFamiliesForAction, 4);
    expect(
      InvestorRecommendationPolicy.minimumCoreCoverage,
      closeTo(2 / 3, 0.000001),
    );
    expect(InvestorRecommendationPolicy.actionDirectionThreshold, 40);
    expect(InvestorRecommendationPolicy.strongDirectionThreshold, 70);
    expect(InvestorRecommendationPolicy.holdDirectionThreshold, 20);
    expect(InvestorRecommendationPolicy.minimumActionConfidence, 65);
    expect(InvestorRecommendationPolicy.strongActionConfidence, 80);
    expect(InvestorRecommendationPolicy.materialConflictThreshold, 0.50);
  });

  test('Valuation is a mandatory Investor action family', () {
    expect(InvestorRecommendationPolicy.requiredCoreFamilies, {
      EvidenceFamily.valuation,
    });
  });

  test('context and durability boundaries are explicit', () {
    expect(InvestorRecommendationPolicy.maximumContextDirectionShare, 0.20);
    expect(InvestorRecommendationPolicy.directionalContextFamilies, {
      EvidenceFamily.marketContext,
      EvidenceFamily.ownershipPositioning,
    });
    expect(InvestorRecommendationPolicy.zeroRecommendationWeightFamilies, {
      EvidenceFamily.competitiveDurability,
    });
    expect(
      InvestorRecommendationPolicy
          .marketImpliedVolatilityConfidenceImpactPoints,
      0,
    );
  });
}
