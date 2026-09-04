import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/investor/models/investor_data_contracts.dart';
import 'package:mobile/features/recommendation/investor/models/investor_metric_explainability_catalog.dart';
import 'package:mobile/features/recommendation/investor/providers/investor_ownership_positioning_evidence_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_ownership_positioning_provider.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';

void main() {
  const provider = InvestorOwnershipPositioningEvidenceProvider();
  const dataProvider = MockInvestorOwnershipPositioningProvider();
  final analysisTime = DateTime(2026, 9, 1);

  Future<InvestorPointInTimeSnapshot> snapshot(String symbol) async {
    final positioning = await dataProvider.loadPositioning(
      symbol: symbol,
      asOf: analysisTime,
    );

    return InvestorPointInTimeSnapshot(
      symbol: symbol,
      analysisTime: analysisTime,
      positioning: positioning,
    );
  }

  test(
    'broadening ownership and falling short interest support context',
    () async {
      final result = provider.evaluate(await snapshot('IVBULL'));

      expect(result.evidence.status, EvidenceStatus.available);
      expect(
        result.evidence.definition.family,
        EvidenceFamily.ownershipPositioning,
      );
      expect(result.evidence.direction, EvidenceDirection.bullish);
      expect(result.metrics.length, 4);
      expect(result.metricsHaveCompleteExplainability, isTrue);
    },
  );

  test(
    'weakening ownership and rising short interest oppose context',
    () async {
      final result = provider.evaluate(await snapshot('IVBEAR'));

      expect(result.evidence.status, EvidenceStatus.available);
      expect(result.evidence.direction, EvidenceDirection.bearish);
    },
  );

  test('raw insider net shares remain explicitly non-directional', () async {
    final result = provider.evaluate(await snapshot('IVBULL'));

    final insider = result.metrics.firstWhere(
      (metric) => metric.kind == InvestorMetricKind.insiderTransactionContext,
    );

    expect(insider.isAvailable, isFalse);
    expect(insider.direction, EvidenceDirection.unknown);
    expect(insider.signedScore, 0);
    expect(
      InvestorOwnershipPositioningEvidenceProvider.insiderNetSharesDirectional,
      isFalse,
    );
  });

  test('absolute short-interest level is not directly directional', () {
    final positioning = <InvestorMetricPoint<InvestorPositioningMetric>>[
      for (var index = 0; index < 3; index++)
        InvestorMetricPoint(
          metric: InvestorPositioningMetric.shortInterestPercentFloat,
          value: [20.0, 18.0, 16.0][index],
          metadata: InvestorDataMetadata(
            sourceName: 'Synthetic high short-interest trend',
            sourceType: InvestorDataSourceType.synthetic,
            observedAt: analysisTime.subtract(
              Duration(days: [35, 20, 5][index]),
            ),
            availableAt: analysisTime.subtract(
              Duration(days: [30, 15, 0][index]),
            ),
            isSynthetic: true,
          ),
        ),
      for (var index = 0; index < 3; index++)
        InvestorMetricPoint(
          metric: InvestorPositioningMetric.institutionalOwnershipPercent,
          value: [50.0, 52.0, 54.0][index],
          metadata: InvestorDataMetadata(
            sourceName: 'Synthetic institutional trend',
            sourceType: InvestorDataSourceType.synthetic,
            observedAt: analysisTime.subtract(
              Duration(days: [190, 100, 55][index]),
            ),
            availableAt: analysisTime.subtract(
              Duration(days: [145, 55, 10][index]),
            ),
            isSynthetic: true,
          ),
        ),
    ];

    final result = provider.evaluate(
      InvestorPointInTimeSnapshot(
        symbol: 'HIGHSHORT',
        analysisTime: analysisTime,
        positioning: positioning,
      ),
    );

    final short = result.metrics.firstWhere(
      (metric) => metric.kind == InvestorMetricKind.shortInterestTrend,
    );

    expect(short.isAvailable, isTrue);
    expect(short.direction, EvidenceDirection.bullish);
    expect(
      InvestorOwnershipPositioningEvidenceProvider
          .absoluteShortInterestDirectional,
      isFalse,
    );
  });

  test('future-known ownership filing fails point-in-time safety', () async {
    final base = await snapshot('IVBULL');
    final positioning = base.positioning.toList(growable: false);
    final first = positioning.first;

    positioning[0] = InvestorMetricPoint(
      metric: first.metric,
      value: first.value,
      metadata: InvestorDataMetadata(
        sourceName: 'Future ownership filing',
        sourceType: InvestorDataSourceType.ownershipFiling,
        observedAt: first.metadata.observedAt,
        availableAt: analysisTime.add(const Duration(days: 1)),
      ),
    );

    final result = provider.evaluate(
      InvestorPointInTimeSnapshot(
        symbol: base.symbol,
        analysisTime: analysisTime,
        positioning: positioning,
      ),
    );

    expect(result.evidence.status, EvidenceStatus.unavailable);
    expect(result.evidence.direction, EvidenceDirection.unknown);
  });

  test('ownership family remains contextual only', () {
    expect(
      InvestorOwnershipPositioningEvidenceProvider.eligibleForCoreBreadth,
      isFalse,
    );
    expect(
      InvestorOwnershipPositioningEvidenceProvider.canCreateRecommendation,
      isFalse,
    );
  });
}
