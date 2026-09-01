import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/investor/models/investor_data_contracts.dart';
import 'package:mobile/features/recommendation/investor/models/investor_metric_explainability_catalog.dart';
import 'package:mobile/features/recommendation/investor/providers/investor_valuation_evidence_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_fundamental_data_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_valuation_data_provider.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';

void main() {
  const provider = InvestorValuationEvidenceProvider();
  const fundamentalProvider = MockInvestorFundamentalDataProvider();
  const valuationProvider = MockInvestorValuationDataProvider();
  final analysisTime = DateTime(2026, 9, 1);

  Future<InvestorPointInTimeSnapshot> snapshot(String symbol) async {
    final fundamentals = await fundamentalProvider.loadHistory(
      symbol: symbol,
      asOf: analysisTime,
    );
    final valuation = await valuationProvider.loadValuationContext(
      symbol: symbol,
      asOf: analysisTime,
    );

    return InvestorPointInTimeSnapshot(
      symbol: symbol,
      analysisTime: analysisTime,
      fundamentals: fundamentals,
      market: valuation.market,
      valuationReferences: valuation.references,
    );
  }

  test('discounted relative multiples support Valuation', () async {
    final result = provider.evaluate(await snapshot('IVBULL'));

    expect(result.evidence.status, EvidenceStatus.available);
    expect(result.evidence.definition.family, EvidenceFamily.valuation);
    expect(result.evidence.direction, EvidenceDirection.bullish);
    expect(result.metrics.length, 3);
    expect(result.metricsHaveCompleteExplainability, isTrue);
  });

  test('premium relative multiples oppose Valuation', () async {
    final result = provider.evaluate(await snapshot('IVBEAR'));

    expect(result.evidence.status, EvidenceStatus.available);
    expect(result.evidence.direction, EvidenceDirection.bearish);
  });

  test('negative earnings make P/E unavailable instead of cheap', () async {
    final base = await snapshot('IVBULL');

    final replacement = base.fundamentals
        .map((point) {
          if (point.metric != InvestorFundamentalMetric.netIncome) {
            return point;
          }

          return InvestorMetricPoint(
            metric: point.metric,
            value: -5,
            metadata: point.metadata,
          );
        })
        .toList(growable: false);

    final result = provider.evaluate(
      InvestorPointInTimeSnapshot(
        symbol: base.symbol,
        analysisTime: base.analysisTime,
        fundamentals: replacement,
        market: base.market,
        valuationReferences: base.valuationReferences,
      ),
    );

    final pe = result.metrics.firstWhere(
      (metric) => metric.kind == InvestorMetricKind.priceToEarningsRelative,
    );

    expect(pe.isAvailable, isFalse);
    expect(pe.direction, EvidenceDirection.unknown);
    expect(result.evidence.status, EvidenceStatus.available);
  });

  test(
    'financial and REIT classifications use specialized guardrail',
    () async {
      final base = await snapshot('IVBULL');

      for (final classification in [
        ('Financial Services', 'Banks'),
        ('Real Estate', 'REIT'),
      ]) {
        final guarded = InvestorPointInTimeSnapshot(
          symbol: base.symbol,
          analysisTime: base.analysisTime,
          fundamentals: base.fundamentals,
          market: base.market,
          valuationReferences: base.valuationReferences,
          peerClassification: InvestorPeerClassification(
            symbol: base.symbol,
            sector: classification.$1,
            industry: classification.$2,
            peerSymbols: const [],
            metadata: InvestorDataMetadata(
              sourceName: 'Synthetic classification',
              sourceType: InvestorDataSourceType.synthetic,
              observedAt: analysisTime,
              availableAt: analysisTime,
              isSynthetic: true,
            ),
          ),
        );

        final result = provider.evaluate(guarded);
        expect(result.evidence.status, EvidenceStatus.unavailable);
        expect(result.metrics, isEmpty);
      }
    },
  );

  test('future-known valuation references fail point-in-time safety', () async {
    final base = await snapshot('IVBULL');

    final unsafeReferences = base.valuationReferences
        .map((reference) {
          return InvestorValuationReference(
            multiple: reference.multiple,
            ownHistoryMedian: reference.ownHistoryMedian,
            peerMedian: reference.peerMedian,
            metadata: InvestorDataMetadata(
              sourceName: 'Future valuation benchmark',
              sourceType: InvestorDataSourceType.marketSeries,
              observedAt: analysisTime,
              availableAt: analysisTime.add(const Duration(days: 1)),
            ),
          );
        })
        .toList(growable: false);

    final result = provider.evaluate(
      InvestorPointInTimeSnapshot(
        symbol: base.symbol,
        analysisTime: base.analysisTime,
        fundamentals: base.fundamentals,
        market: base.market,
        valuationReferences: unsafeReferences,
      ),
    );

    expect(result.evidence.status, EvidenceStatus.unavailable);
    expect(result.evidence.direction, EvidenceDirection.unknown);
  });
}
