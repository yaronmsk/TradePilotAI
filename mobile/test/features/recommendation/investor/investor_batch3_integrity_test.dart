import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/engines/consensus_engine.dart';
import 'package:mobile/features/recommendation/investor/models/investor_data_contracts.dart';
import 'package:mobile/features/recommendation/investor/models/investor_metric_explainability_catalog.dart';
import 'package:mobile/features/recommendation/investor/providers/investor_capital_allocation_evidence_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/investor_financial_strength_evidence_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/investor_growth_evidence_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/investor_profitability_quality_evidence_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_fundamental_data_provider.dart';
import 'package:mobile/features/recommendation/models/evidence_report.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/strategy/recommendation_strategy_policy.dart';
import 'package:mobile/features/recommendation/strategy/strategy_analysis_policy.dart';
import 'package:mobile/features/recommendation/strategy/strategy_analysis_policy_catalog.dart';

void main() {
  const dataProvider = MockInvestorFundamentalDataProvider();
  final analysisTime = DateTime(2026, 9, 1);

  Future<InvestorPointInTimeSnapshot> snapshot(String symbol) async {
    final fundamentals = await dataProvider.loadHistory(
      symbol: symbol,
      asOf: analysisTime,
    );

    return InvestorPointInTimeSnapshot(
      symbol: symbol,
      analysisTime: analysisTime,
      fundamentals: fundamentals,
    );
  }

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

  test(
    'four implemented core families remain four independent votes',
    () async {
      final input = await snapshot('IVBULL');

      final results = [
        const InvestorGrowthEvidenceProvider().evaluate(input).evidence,
        const InvestorProfitabilityQualityEvidenceProvider()
            .evaluate(input)
            .evidence,
        const InvestorFinancialStrengthEvidenceProvider()
            .evaluate(input)
            .evidence,
        const InvestorCapitalAllocationEvidenceProvider()
            .evaluate(input)
            .evidence,
      ];

      final consensus = const ConsensusEngine().calculate(
        EvidenceReport.fromResults(
          results: results,
          expectedProviderCount: results.length,
        ),
      );

      expect(consensus.independentFamilyCount, 4);
    },
  );

  test('Batch 3 still cannot activate Investor recommendations', () {
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
