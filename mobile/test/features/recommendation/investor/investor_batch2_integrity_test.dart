import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/engines/consensus_engine.dart';
import 'package:mobile/features/recommendation/investor/models/investor_data_contracts.dart';
import 'package:mobile/features/recommendation/investor/models/investor_metric_explainability_catalog.dart';
import 'package:mobile/features/recommendation/investor/providers/investor_growth_evidence_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/investor_profitability_quality_evidence_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_fundamental_data_provider.dart';
import 'package:mobile/features/recommendation/models/evidence_kind.dart';
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

  test('all Batch 2 metric explainability definitions are complete', () {
    expect(InvestorMetricExplainabilityCatalog.isComplete, isTrue);

    const batch2Kinds = {
      InvestorMetricKind.revenueCagr,
      InvestorMetricKind.dilutedEpsCagr,
      InvestorMetricKind.freeCashFlowCagr,
      InvestorMetricKind.grossMarginTrend,
      InvestorMetricKind.operatingMarginQuality,
      InvestorMetricKind.freeCashFlowMarginQuality,
      InvestorMetricKind.returnOnInvestedCapitalQuality,
    };

    for (final kind in batch2Kinds) {
      final explainability = InvestorMetricExplainabilityCatalog.forKind(kind);
      expect(explainability.isComplete, isTrue, reason: '$kind');
      expect(explainability.allowsDirectionalInfluence, isTrue);
    }
  });

  test('multiple metrics remain one vote per independent family', () async {
    const growthProvider = InvestorGrowthEvidenceProvider();
    const qualityProvider = InvestorProfitabilityQualityEvidenceProvider();

    final input = await snapshot('IVBULL');
    final growth = growthProvider.evaluate(input);
    final quality = qualityProvider.evaluate(input);

    expect(growth.metrics.length, 3);
    expect(quality.metrics.length, 4);

    final consensus = const ConsensusEngine().calculate(
      EvidenceReport.fromResults(
        results: [growth.evidence, quality.evidence],
        expectedProviderCount: 2,
      ),
    );

    expect(consensus.independentFamilyCount, 2);
  });

  test('Batch 2 does not classify or activate Investor recommendations', () {
    const growthProvider = InvestorGrowthEvidenceProvider();
    const qualityProvider = InvestorProfitabilityQualityEvidenceProvider();

    expect(growthProvider.definition.kind, EvidenceKind.generic);
    expect(qualityProvider.definition.kind, EvidenceKind.generic);

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
