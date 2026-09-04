import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/investor/models/investor_metric_explainability_catalog.dart';
import 'package:mobile/features/recommendation/investor/providers/investor_macro_sensitivity_evidence_provider.dart';
import 'package:mobile/features/recommendation/investor/strategy/investor_evidence_family_policy.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/strategy/recommendation_strategy_policy.dart';
import 'package:mobile/features/recommendation/strategy/strategy_analysis_policy.dart';
import 'package:mobile/features/recommendation/strategy/strategy_analysis_policy_catalog.dart';

void main() {
  test('all Investor metric explainability remains complete', () {
    expect(InvestorMetricExplainabilityCatalog.isComplete, isTrue);

    for (final kind in InvestorMetricKind.values) {
      expect(
        InvestorMetricExplainabilityCatalog.forKind(kind).isComplete,
        isTrue,
        reason: '$kind',
      );
    }
  });

  test('Competitive Durability remains core but is excluded from breadth', () {
    expect(
      InvestorEvidenceFamilyPolicy.isCoreFundamental(
        EvidenceFamily.competitiveDurability,
      ),
      isTrue,
    );
    expect(
      InvestorEvidenceFamilyPolicy.isBreadthEligibleCoreFundamental(
        EvidenceFamily.competitiveDurability,
      ),
      isFalse,
    );

    expect(
      InvestorEvidenceFamilyPolicy.countCoreFundamentalFamilies([
        EvidenceFamily.profitabilityQuality,
        EvidenceFamily.competitiveDurability,
      ]),
      2,
    );
    expect(
      InvestorEvidenceFamilyPolicy.countBreadthEligibleCoreFundamentalFamilies([
        EvidenceFamily.profitabilityQuality,
        EvidenceFamily.competitiveDurability,
      ]),
      1,
    );
  });

  test('market and macro sensitivity remains contextual only', () {
    expect(
      InvestorEvidenceFamilyPolicy.contextualFamilies,
      contains(EvidenceFamily.marketContext),
    );
    expect(
      InvestorMacroSensitivityEvidenceProvider.eligibleForCoreBreadth,
      isFalse,
    );
    expect(
      InvestorMacroSensitivityEvidenceProvider.canCreateRecommendation,
      isFalse,
    );
  });

  test('Batch 6 still cannot activate Investor recommendations', () {
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
  });
}
