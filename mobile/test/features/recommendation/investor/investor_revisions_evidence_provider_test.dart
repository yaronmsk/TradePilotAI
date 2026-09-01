import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/investor/models/investor_data_contracts.dart';
import 'package:mobile/features/recommendation/investor/providers/investor_revisions_evidence_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_estimate_provider.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';

void main() {
  const provider = InvestorRevisionsEvidenceProvider();
  const estimateProvider = MockInvestorEstimateProvider();
  final analysisTime = DateTime(2026, 9, 1);

  Future<InvestorPointInTimeSnapshot> snapshot(String symbol) async {
    final estimates = await estimateProvider.loadEstimates(
      symbol: symbol,
      asOf: analysisTime,
    );

    return InvestorPointInTimeSnapshot(
      symbol: symbol,
      analysisTime: analysisTime,
      estimates: estimates,
    );
  }

  test('upward estimate vintages support Revisions', () async {
    final result = provider.evaluate(await snapshot('IVBULL'));

    expect(result.evidence.status, EvidenceStatus.available);
    expect(result.evidence.definition.family, EvidenceFamily.revisions);
    expect(result.evidence.direction, EvidenceDirection.bullish);
    expect(result.metrics.length, 3);
    expect(result.metricsHaveCompleteExplainability, isTrue);
  });

  test('downward estimate vintages oppose Revisions', () async {
    final result = provider.evaluate(await snapshot('IVBEAR'));

    expect(result.evidence.status, EvidenceStatus.available);
    expect(result.evidence.direction, EvidenceDirection.bearish);
  });

  test(
    'mixed estimate vintages do not become artificial breadth votes',
    () async {
      final result = provider.evaluate(await snapshot('IVMIX'));

      expect(result.metrics.length, 3);
      expect(result.evidence.definition.family, EvidenceFamily.revisions);
    },
  );

  test(
    'different target fiscal periods are never compared as revisions',
    () async {
      final base = await snapshot('IVBULL');
      final estimates = <InvestorEstimatePoint>[
        InvestorEstimatePoint(
          metric: InvestorEstimateMetric.revenue,
          value: 100,
          targetPeriodEnd: DateTime(2027, 12, 31),
          metadata: InvestorDataMetadata(
            sourceName: 'Synthetic',
            sourceType: InvestorDataSourceType.synthetic,
            observedAt: analysisTime.subtract(const Duration(days: 90)),
            availableAt: analysisTime.subtract(const Duration(days: 90)),
            isSynthetic: true,
          ),
        ),
        InvestorEstimatePoint(
          metric: InvestorEstimateMetric.revenue,
          value: 200,
          targetPeriodEnd: DateTime(2028, 12, 31),
          metadata: InvestorDataMetadata(
            sourceName: 'Synthetic',
            sourceType: InvestorDataSourceType.synthetic,
            observedAt: analysisTime,
            availableAt: analysisTime,
            isSynthetic: true,
          ),
        ),
      ];

      final result = provider.evaluate(
        InvestorPointInTimeSnapshot(
          symbol: base.symbol,
          analysisTime: analysisTime,
          estimates: estimates,
        ),
      );

      expect(result.evidence.status, EvidenceStatus.insufficientData);
      expect(result.evidence.direction, EvidenceDirection.unknown);
    },
  );
}
