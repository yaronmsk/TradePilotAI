import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/investor/models/investor_data_contracts.dart';
import 'package:mobile/features/recommendation/investor/models/investor_metric_explainability_catalog.dart';
import 'package:mobile/features/recommendation/investor/providers/investor_macro_sensitivity_evidence_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_macro_data_provider.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/metric_explainability.dart';

void main() {
  const provider = InvestorMacroSensitivityEvidenceProvider();
  const dataProvider = MockInvestorMacroDataProvider();
  final analysisTime = DateTime(2026, 9, 1);

  Future<InvestorPointInTimeSnapshot> snapshot(String symbol) async {
    final history = await dataProvider.loadSensitivityHistory(
      symbol: symbol,
      asOf: analysisTime,
    );
    final macro = await dataProvider.loadContext(
      symbol: symbol,
      asOf: analysisTime,
    );

    return InvestorPointInTimeSnapshot(
      symbol: symbol,
      analysisTime: analysisTime,
      macro: macro,
      sensitivityHistory: history,
    );
  }

  test('validated sensitivities can support current context', () async {
    final result = provider.evaluate(await snapshot('IVBULL'));

    expect(result.evidence.status, EvidenceStatus.available);
    expect(result.evidence.definition.family, EvidenceFamily.marketContext);
    expect(result.evidence.direction, EvidenceDirection.bullish);
    expect(result.metricsHaveCompleteExplainability, isTrue);
  });

  test(
    'same current context can oppose stock with opposite sensitivities',
    () async {
      final result = provider.evaluate(await snapshot('IVBEAR'));

      expect(result.evidence.status, EvidenceStatus.available);
      expect(result.evidence.direction, EvidenceDirection.bearish);
    },
  );

  test('weak unstable relationships do not invent direction', () async {
    final result = provider.evaluate(await snapshot('IVFLAT'));

    expect(result.evidence.status, EvidenceStatus.available);
    expect(result.evidence.direction, EvidenceDirection.neutral);

    final directional = result.metrics.where(
      (metric) =>
          metric.kind != InvestorMetricKind.marketImpliedVolatilityContext,
    );

    expect(directional.where((metric) => metric.isAvailable), isEmpty);
  });

  test(
    'VIX context is confidence risk only and contributes zero direction',
    () async {
      final result = provider.evaluate(await snapshot('IVBULL'));

      final vix = result.metrics.firstWhere(
        (metric) =>
            metric.kind == InvestorMetricKind.marketImpliedVolatilityContext,
      );

      expect(vix.isAvailable, isTrue);
      expect(vix.direction, EvidenceDirection.neutral);
      expect(vix.signedScore, 0);
      expect(
        vix.explainability.semanticRole,
        MetricSemanticRole.confidenceRiskOnly,
      );
      expect(
        InvestorMacroSensitivityEvidenceProvider
            .marketImpliedVolatilityDirectional,
        isFalse,
      );
    },
  );

  test('future-known sensitivity history fails point-in-time safety', () async {
    final base = await snapshot('IVBULL');
    final history = base.sensitivityHistory.toList(growable: false);
    final last = history.last;

    history[history.length - 1] = InvestorSensitivityObservation(
      stockReturnPercent: last.stockReturnPercent,
      factorChanges: last.factorChanges,
      metadata: InvestorDataMetadata(
        sourceName: 'Future sensitivity point',
        sourceType: InvestorDataSourceType.marketSeries,
        observedAt: analysisTime,
        availableAt: analysisTime.add(const Duration(days: 1)),
      ),
    );

    final result = provider.evaluate(
      InvestorPointInTimeSnapshot(
        symbol: base.symbol,
        analysisTime: analysisTime,
        sensitivityHistory: history,
      ),
    );

    expect(result.evidence.status, EvidenceStatus.unavailable);
    expect(result.evidence.direction, EvidenceDirection.unknown);
  });

  test('highly collinear factors cannot both survive', () {
    final history = <InvestorSensitivityObservation>[];

    for (var index = 0; index < 60; index++) {
      final change = index == 59
          ? 3.0
          : index.isEven
          ? 1.0
          : -1.0;

      history.add(
        InvestorSensitivityObservation(
          stockReturnPercent: index == 59 ? 0 : change * 2,
          factorChanges: {
            InvestorSensitivityFactor.broadMarket: change,
            InvestorSensitivityFactor.sector: change * 2,
            InvestorSensitivityFactor.marketImpliedVolatility: index.isEven
                ? 1
                : -1,
          },
          metadata: InvestorDataMetadata(
            sourceName: 'Synthetic collinearity test',
            sourceType: InvestorDataSourceType.synthetic,
            observedAt: analysisTime.subtract(Duration(days: (59 - index) * 7)),
            availableAt: analysisTime.subtract(
              Duration(days: (59 - index) * 7),
            ),
            isSynthetic: true,
          ),
        ),
      );
    }

    final result = provider.evaluate(
      InvestorPointInTimeSnapshot(
        symbol: 'COLLINEAR',
        analysisTime: analysisTime,
        sensitivityHistory: history,
      ),
    );

    final marketAndSector = result.metrics.where(
      (metric) =>
          metric.kind == InvestorMetricKind.broadMarketSensitivity ||
          metric.kind == InvestorMetricKind.sectorSensitivity,
    );

    expect(marketAndSector.where((metric) => metric.isAvailable).length, 1);
  });

  test('latest stock return is not used to fit its own sensitivity', () {
    final history = <InvestorSensitivityObservation>[];

    for (var index = 0; index < 60; index++) {
      final isCurrent = index == 59;
      final factorChange = isCurrent
          ? 3.0
          : index.isEven
          ? 1.0
          : -1.0;

      history.add(
        InvestorSensitivityObservation(
          stockReturnPercent: isCurrent ? -100 : factorChange,
          factorChanges: {InvestorSensitivityFactor.broadMarket: factorChange},
          metadata: InvestorDataMetadata(
            sourceName: 'Synthetic no-leakage test',
            sourceType: InvestorDataSourceType.synthetic,
            observedAt: analysisTime.subtract(Duration(days: (59 - index) * 7)),
            availableAt: analysisTime.subtract(
              Duration(days: (59 - index) * 7),
            ),
            isSynthetic: true,
          ),
        ),
      );
    }

    final result = provider.evaluate(
      InvestorPointInTimeSnapshot(
        symbol: 'NOLEAK',
        analysisTime: analysisTime,
        sensitivityHistory: history,
      ),
    );

    final market = result.metrics.firstWhere(
      (metric) => metric.kind == InvestorMetricKind.broadMarketSensitivity,
    );

    expect(market.isAvailable, isTrue);
    expect(market.direction, EvidenceDirection.bullish);
    expect(result.evidence.direction, EvidenceDirection.bullish);
  });

  test('minimum historical sample gate is enforced', () {
    final history = <InvestorSensitivityObservation>[];

    for (var index = 0; index < 30; index++) {
      history.add(
        InvestorSensitivityObservation(
          stockReturnPercent: index.isEven ? 1 : -1,
          factorChanges: {
            InvestorSensitivityFactor.broadMarket: index.isEven ? 1 : -1,
          },
          metadata: InvestorDataMetadata(
            sourceName: 'Synthetic short history',
            sourceType: InvestorDataSourceType.synthetic,
            observedAt: analysisTime.subtract(Duration(days: (29 - index) * 7)),
            availableAt: analysisTime.subtract(
              Duration(days: (29 - index) * 7),
            ),
            isSynthetic: true,
          ),
        ),
      );
    }

    final result = provider.evaluate(
      InvestorPointInTimeSnapshot(
        symbol: 'SHORT',
        analysisTime: analysisTime,
        sensitivityHistory: history,
      ),
    );

    expect(result.evidence.status, EvidenceStatus.insufficientData);
    expect(result.evidence.direction, EvidenceDirection.unknown);
  });
}
