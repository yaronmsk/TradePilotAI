import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/investor/strategy/investor_recommendation_policy.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/strategy/recommendation_strategy_policy.dart';
import 'package:mobile/features/recommendation/strategy/strategy_analysis_policy.dart';
import 'package:mobile/features/recommendation/strategy/strategy_analysis_policy_catalog.dart';

void main() {
  test('Investor recommendation breadth is fundamental-only', () {
    expect(InvestorRecommendationPolicy.breadthEligibleCoreFamilies, {
      EvidenceFamily.growth,
      EvidenceFamily.profitabilityQuality,
      EvidenceFamily.financialStrength,
      EvidenceFamily.valuation,
      EvidenceFamily.revisions,
      EvidenceFamily.capitalAllocation,
    });
    expect(
      InvestorRecommendationPolicy.directionalContextFamilies
          .intersection(
            InvestorRecommendationPolicy.breadthEligibleCoreFamilies,
          )
          .isEmpty,
      isTrue,
    );
  });

  test('Competitive Durability is zero-weight until overlap is resolved', () {
    expect(
      InvestorRecommendationPolicy.zeroRecommendationWeightFamilies,
      contains(EvidenceFamily.competitiveDurability),
    );
    expect(
      InvestorRecommendationPolicy.competitiveDurabilityRecommendationWeight,
      0,
    );
  });

  test(
    'Batch 8 backend does not activate generic Investor/UI orchestration',
    () {
      // The dedicated InvestorRecommendationEngine is the only Batch 8 backend
      // path. Generic RecommendationEngine remains guarded so it cannot apply
      // Swing-style independent-family breadth to Investor by accident.
      expect(
        RecommendationStrategyPolicy.forStrategy(StrategyType.investor),
        isNull,
      );
      expect(
        StrategyAnalysisPolicyCatalog.investor.status,
        StrategyAnalysisPolicyStatus.planned,
      );
      expect(
        StrategyAnalysisPolicyCatalog.investor.isRecommendationActive,
        isFalse,
      );
    },
  );
}
