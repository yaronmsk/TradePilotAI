import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/investor/models/investor_data_contracts.dart';
import 'package:mobile/features/recommendation/investor/providers/investor_competitive_durability_evidence_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_fundamental_data_provider.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';

void main() {
  const provider = InvestorCompetitiveDurabilityEvidenceProvider();
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

  test('persistent economics support observed durability', () async {
    final result = provider.evaluate(await snapshot('IVBULL'));

    expect(result.evidence.status, EvidenceStatus.available);
    expect(
      result.evidence.definition.family,
      EvidenceFamily.competitiveDurability,
    );
    expect(result.evidence.direction, EvidenceDirection.bullish);
    expect(result.metrics.length, 3);
    expect(result.metricsHaveCompleteExplainability, isTrue);
  });

  test('severe economic erosion opposes observed durability', () async {
    final result = provider.evaluate(await snapshot('IVBEAR'));

    expect(result.evidence.status, EvidenceStatus.available);
    expect(result.evidence.direction, EvidenceDirection.bearish);
  });

  test(
    'durability is explicitly correlated with Profitability and Quality',
    () {
      expect(
        InvestorCompetitiveDurabilityEvidenceProvider
            .sharesInputsWithProfitabilityQuality,
        isTrue,
      );
      expect(
        InvestorCompetitiveDurabilityEvidenceProvider
            .eligibleForIndependentBreadthInBatch5,
        isFalse,
      );
    },
  );

  test('definition does not claim structural moat identification', () {
    final explanation = InvestorCompetitiveDurabilityEvidenceProvider
        .kDefinition
        .explainability!
        .limitations
        .toLowerCase();

    expect(explanation, contains('not a moat rating'));
    expect(explanation, contains('network effects'));
  });
}
