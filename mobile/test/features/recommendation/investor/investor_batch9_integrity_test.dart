import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/history/historical_setup_validation.dart';
import 'package:mobile/features/recommendation/investor/history/investor_historical_validation_explainability.dart';
import 'package:mobile/features/recommendation/investor/history/investor_historical_validation_service.dart';
import 'package:mobile/features/recommendation/investor/models/investor_historical_validation_case.dart';
import 'package:mobile/features/recommendation/models/metric_explainability.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/strategy/recommendation_strategy_policy.dart';
import 'package:mobile/features/recommendation/strategy/strategy_analysis_policy.dart';
import 'package:mobile/features/recommendation/strategy/strategy_analysis_policy_catalog.dart';

void main() {
  test('Investor historical validation is confidence-only and capped', () {
    expect(InvestorHistoricalValidationService.affectsDirection, isFalse);
    expect(InvestorHistoricalValidationService.affectsCoreBreadth, isFalse);
    expect(InvestorHistoricalValidationService.addsEvidenceVote, isFalse);
    expect(
      InvestorHistoricalValidationService.maximumConfidenceImpactPoints,
      HistoricalSetupValidation.maximumConfidenceImpactPoints,
    );
    expect(
      InvestorHistoricalValidationService.maximumConfidenceImpactPoints,
      8,
    );
  });

  test('6m 12m 24m horizon weights form one overlay', () {
    expect(
      InvestorHistoricalHorizon.values.fold<double>(
        0,
        (sum, horizon) => sum + horizon.policyWeight,
      ),
      closeTo(1, 0.000001),
    );
    expect(InvestorHistoricalHorizon.sixMonths.policyWeight, 0.25);
    expect(InvestorHistoricalHorizon.twelveMonths.policyWeight, 0.50);
    expect(InvestorHistoricalHorizon.twentyFourMonths.policyWeight, 0.25);
  });

  test(
    'historical validation explainability is complete and confidence-only',
    () {
      final explainability =
          InvestorHistoricalValidationExplainability.definition;

      expect(explainability.isComplete, isTrue);
      expect(
        explainability.semanticRole,
        MetricSemanticRole.confidenceRiskOnly,
      );
      expect(explainability.allowsDirectionalInfluence, isFalse);
    },
  );

  test('Batch 9 still does not activate generic Investor UI orchestration', () {
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
