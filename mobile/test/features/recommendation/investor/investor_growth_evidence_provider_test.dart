import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/investor/models/investor_data_contracts.dart';
import 'package:mobile/features/recommendation/investor/providers/investor_growth_evidence_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_fundamental_data_provider.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';

void main() {
  const provider = InvestorGrowthEvidenceProvider();
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

  test('bullish fixture produces supportive Growth family evidence', () async {
    final result = provider.evaluate(await snapshot('IVBULL'));

    expect(result.evidence.status, EvidenceStatus.available);
    expect(result.evidence.definition.family, EvidenceFamily.growth);
    expect(result.evidence.direction, EvidenceDirection.bullish);
    expect(result.metrics.length, 3);
    expect(result.metricsHaveCompleteExplainability, isTrue);
    expect(result.evidence.reliability, greaterThan(0));
  });

  test('bearish fixture produces opposing Growth family evidence', () async {
    final result = provider.evaluate(await snapshot('IVBEAR'));

    expect(result.evidence.status, EvidenceStatus.available);
    expect(result.evidence.direction, EvidenceDirection.bearish);
    expect(
      result.metrics.where((metric) => metric.isAvailable),
      everyElement(isA<Object>()),
    );
  });

  test('flat fixture remains neutral rather than forcing direction', () async {
    final result = provider.evaluate(await snapshot('IVFLAT'));

    expect(result.evidence.status, EvidenceStatus.available);
    expect(result.evidence.direction, EvidenceDirection.neutral);
  });

  test('future-known data is rejected before calculation', () {
    final unsafe = InvestorPointInTimeSnapshot(
      symbol: 'UNSAFE',
      analysisTime: DateTime(2026, 7, 1),
      fundamentals: [
        InvestorMetricPoint(
          metric: InvestorFundamentalMetric.revenue,
          value: 100,
          metadata: InvestorDataMetadata(
            sourceName: 'Future filing',
            sourceType: InvestorDataSourceType.regulatoryFiling,
            observedAt: DateTime(2026, 6, 30),
            availableAt: DateTime(2026, 8, 1),
          ),
        ),
      ],
    );

    final result = provider.evaluate(unsafe);

    expect(result.evidence.status, EvidenceStatus.unavailable);
    expect(result.evidence.direction, EvidenceDirection.unknown);
    expect(result.metrics, isEmpty);
  });
}
