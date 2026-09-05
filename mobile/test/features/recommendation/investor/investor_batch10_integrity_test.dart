import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/services/strategy_summary_service.dart';
import 'package:mobile/features/recommendation/strategy/recommendation_strategy_policy.dart';
import 'package:mobile/features/recommendation/strategy/strategy_analysis_policy.dart';
import 'package:mobile/features/recommendation/strategy/strategy_analysis_policy_catalog.dart';

void main() {
  test(
    'dedicated Investor UI availability does not activate generic engine',
    () {
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

  test('Strategy Summary can expose dedicated Investor backend safely', () {
    final summaries = const StrategySummaryService().build(
      recommendations: const [],
      dedicatedAvailableStrategies: const {StrategyType.investor},
    );

    final investor = summaries.singleWhere(
      (summary) => summary.type == StrategyType.investor,
    );

    expect(investor.status, StrategyStatus.active);
    expect(investor.recommendation, 'Ready to analyze');
    expect(investor.confidence, isNull);
  });
}
