import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/investor/models/investor_data_contracts.dart';
import 'package:mobile/features/recommendation/investor/models/investor_metric_explainability_catalog.dart';
import 'package:mobile/features/recommendation/investor/providers/investor_capital_allocation_evidence_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_fundamental_data_provider.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';

void main() {
  const provider = InvestorCapitalAllocationEvidenceProvider();
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

  test('net share reduction and funded returns support allocation', () async {
    final result = provider.evaluate(await snapshot('IVBULL'));

    expect(result.evidence.status, EvidenceStatus.available);
    expect(result.evidence.definition.family, EvidenceFamily.capitalAllocation);
    expect(result.evidence.direction, EvidenceDirection.bullish);
    expect(result.metrics.length, 3);
    expect(result.metricsHaveCompleteExplainability, isTrue);
  });

  test('dilution and over-funded distributions oppose allocation', () async {
    final result = provider.evaluate(await snapshot('IVBEAR'));

    expect(result.evidence.status, EvidenceStatus.available);
    expect(result.evidence.direction, EvidenceDirection.bearish);
  });

  test('gross buybacks cannot hide rising net share count', () async {
    final result = provider.evaluate(await snapshot('IVBEAR'));

    final shareMetric = result.metrics.firstWhere(
      (metric) => metric.kind == InvestorMetricKind.netShareCountChange,
    );

    expect(shareMetric.direction, EvidenceDirection.bearish);
    expect(shareMetric.currentValue, startsWith('+'));
  });
}
