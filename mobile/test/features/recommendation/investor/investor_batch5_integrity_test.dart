import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/investor/models/investor_metric_explainability_catalog.dart';
import 'package:mobile/features/recommendation/investor/providers/investor_competitive_durability_evidence_provider.dart';
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

  test('durability cannot yet inflate independent Investor core breadth', () {
    expect(
      InvestorCompetitiveDurabilityEvidenceProvider
          .eligibleForIndependentBreadthInBatch5,
      isFalse,
    );
  });

  test('Batch 5 still cannot activate Investor recommendations', () {
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
