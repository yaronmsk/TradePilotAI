import 'dart:math' as math;

import '../models/investor_data_contracts.dart';
import 'investor_data_providers.dart';

class MockInvestorMacroDataProvider
    implements MacroContextProvider, InvestorSensitivityDataProvider {
  const MockInvestorMacroDataProvider();

  @override
  Future<List<InvestorMetricPoint<InvestorMacroMetric>>> loadContext({
    required String symbol,
    required DateTime asOf,
  }) async {
    final metadata = InvestorDataMetadata(
      sourceName: 'Synthetic Investor macro context',
      sourceType: InvestorDataSourceType.synthetic,
      observedAt: asOf,
      availableAt: asOf,
      isSynthetic: true,
    );

    const values = {
      InvestorMacroMetric.policyRate: 4.50,
      InvestorMacroMetric.longTermYield: 4.10,
      InvestorMacroMetric.yieldCurveSpread: 0.50,
      InvestorMacroMetric.financialConditions: -0.20,
      InvestorMacroMetric.inflationRate: 2.70,
      InvestorMacroMetric.usdIndex: 101.0,
      InvestorMacroMetric.marketImpliedVolatility: 22.0,
    };

    return List.unmodifiable(
      values.entries.map(
        (entry) => InvestorMetricPoint(
          metric: entry.key,
          value: entry.value,
          metadata: metadata,
        ),
      ),
    );
  }

  @override
  Future<List<InvestorSensitivityObservation>> loadSensitivityHistory({
    required String symbol,
    required DateTime asOf,
  }) async {
    const observationCount = 80;
    final profile = symbol.toUpperCase();
    final observations = <InvestorSensitivityObservation>[];

    for (var index = 0; index < observationCount; index++) {
      var broadMarketChange =
          (1.10 * math.sin(index * 0.61)) + (0.55 * math.cos(index * 0.17));
      var sectorChange =
          math.sin((index * 0.43) + 1.10) + (0.50 * math.cos(index * 0.73));
      var longYieldChange =
          0.12 *
          (math.sin((index * 0.89) + 0.40) + (0.50 * math.cos(index * 0.37)));
      var financialConditionsChange =
          0.15 *
          (math.sin((index * 1.13) + 0.70) + (0.50 * math.cos(index * 0.29)));
      var usdChange =
          0.50 *
          (math.sin((index * 0.97) + 0.20) + (0.40 * math.cos(index * 0.41)));
      var volatilityChange =
          2.0 *
          (math.sin((index * 0.71) + 0.20) + (0.50 * math.cos(index * 0.37)));

      if (index == observationCount - 1) {
        // Deterministic current-week shock used only after the historical
        // sensitivity is fitted from the earlier observations.
        broadMarketChange = 2.20;
        sectorChange = 2.00;
        longYieldChange = -0.32;
        financialConditionsChange = -0.40;
        usdChange = 0.25;
        volatilityChange = 6.00;
      }

      final noise =
          (0.12 * math.sin(index * 0.37)) + (0.06 * math.cos(index * 0.19));

      final bullishProfileReturn =
          (0.70 * broadMarketChange) +
          (0.60 * sectorChange) -
          (0.75 * (longYieldChange / 0.12)) -
          (0.55 * (financialConditionsChange / 0.15)) -
          (0.10 * (usdChange / 0.50)) +
          noise;

      final stockReturnPercent = switch (profile) {
        'IVBULL' => bullishProfileReturn,
        'IVBEAR' => -bullishProfileReturn,
        'IVMIX' =>
          (0.60 * broadMarketChange) -
              (0.50 * sectorChange) -
              (0.65 * (longYieldChange / 0.12)) +
              (0.40 * (financialConditionsChange / 0.15)) +
              noise,
        _ => noise,
      };

      final observedAt = asOf.subtract(
        Duration(days: (observationCount - 1 - index) * 7),
      );

      observations.add(
        InvestorSensitivityObservation(
          stockReturnPercent: stockReturnPercent,
          factorChanges: {
            InvestorSensitivityFactor.broadMarket: broadMarketChange,
            InvestorSensitivityFactor.sector: sectorChange,
            InvestorSensitivityFactor.longTermYield: longYieldChange,
            InvestorSensitivityFactor.financialConditions:
                financialConditionsChange,
            InvestorSensitivityFactor.usdIndex: usdChange,
            InvestorSensitivityFactor.marketImpliedVolatility: volatilityChange,
          },
          metadata: InvestorDataMetadata(
            sourceName: 'Synthetic Investor weekly sensitivity history',
            sourceType: InvestorDataSourceType.synthetic,
            observedAt: observedAt,
            availableAt: observedAt,
            isSynthetic: true,
          ),
        ),
      );
    }

    return List.unmodifiable(observations);
  }
}
