import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/investor/models/investor_metric_explainability_catalog.dart';
import 'package:mobile/features/recommendation/investor/providers/investor_ownership_positioning_evidence_provider.dart';
import 'package:mobile/features/recommendation/investor/strategy/investor_evidence_family_policy.dart';
import 'package:mobile/features/recommendation/investor/strategy/investor_market_expectations.dart';
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

  test('Ownership & Positioning remains contextual and not core breadth', () {
    expect(
      InvestorEvidenceFamilyPolicy.contextualFamilies,
      contains(EvidenceFamily.ownershipPositioning),
    );
    expect(
      InvestorEvidenceFamilyPolicy.isCoreFundamental(
        EvidenceFamily.ownershipPositioning,
      ),
      isFalse,
    );
    expect(
      InvestorOwnershipPositioningEvidenceProvider.eligibleForCoreBreadth,
      isFalse,
    );
  });

  test('Market Expectations cannot become a hidden evidence vote', () {
    expect(InvestorMarketExpectationsService.addsEvidenceVotes, isFalse);
    expect(InvestorMarketExpectationsService.addsDirectionPoints, isFalse);
    expect(InvestorMarketExpectationsService.addsConfidencePoints, isFalse);
  });

  test('Batch 7 still cannot activate Investor recommendations', () {
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
