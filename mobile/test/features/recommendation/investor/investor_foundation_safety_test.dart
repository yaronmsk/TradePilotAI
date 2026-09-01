import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/strategy/recommendation_strategy_policy.dart';
import 'package:mobile/features/recommendation/strategy/strategy_analysis_policy.dart';
import 'package:mobile/features/recommendation/strategy/strategy_analysis_policy_catalog.dart';

void main() {
  test('Batch 1 keeps Investor recommendation generation unavailable', () {
    expect(
      RecommendationStrategyPolicy.forStrategy(StrategyType.investor),
      isNull,
    );

    final policy = StrategyAnalysisPolicyCatalog.investor;

    expect(policy.status, StrategyAnalysisPolicyStatus.planned);
    expect(policy.isRecommendationActive, isFalse);
    expect(policy.implementationReadyEvidenceKinds, isEmpty);
  });
}
