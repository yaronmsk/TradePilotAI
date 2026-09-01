import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/investor/models/investor_data_contracts.dart';
import 'package:mobile/features/recommendation/investor/providers/investor_financial_strength_evidence_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_fundamental_data_provider.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';

void main() {
  const provider = InvestorFinancialStrengthEvidenceProvider();
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

  test('strong balance-sheet fixture supports Financial Strength', () async {
    final result = provider.evaluate(await snapshot('IVBULL'));

    expect(result.evidence.status, EvidenceStatus.available);
    expect(result.evidence.definition.family, EvidenceFamily.financialStrength);
    expect(result.evidence.direction, EvidenceDirection.bullish);
    expect(result.metrics.length, 3);
    expect(result.metricsHaveCompleteExplainability, isTrue);
  });

  test('leveraged fixture opposes Financial Strength', () async {
    final result = provider.evaluate(await snapshot('IVBEAR'));

    expect(result.evidence.status, EvidenceStatus.available);
    expect(result.evidence.direction, EvidenceDirection.bearish);
  });

  test('identified financial-sector structures are withheld', () async {
    final base = await snapshot('IVBULL');

    final financial = InvestorPointInTimeSnapshot(
      symbol: base.symbol,
      analysisTime: base.analysisTime,
      fundamentals: base.fundamentals,
      peerClassification: InvestorPeerClassification(
        symbol: base.symbol,
        sector: 'Financial Services',
        industry: 'Banks',
        peerSymbols: const [],
        metadata: InvestorDataMetadata(
          sourceName: 'Synthetic classification',
          sourceType: InvestorDataSourceType.synthetic,
          observedAt: DateTime(2026, 8, 31),
          availableAt: DateTime(2026, 8, 31),
          isSynthetic: true,
        ),
      ),
    );

    final result = provider.evaluate(financial);

    expect(result.evidence.status, EvidenceStatus.unavailable);
    expect(result.evidence.direction, EvidenceDirection.unknown);
    expect(result.metrics, isEmpty);
  });
}
