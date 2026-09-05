import '../../models/evidence_family.dart';
import '../models/investor_historical_validation_case.dart';
import 'investor_data_providers.dart';

class MockInvestorHistoricalDataProvider
    implements InvestorHistoricalDataProvider {
  const MockInvestorHistoricalDataProvider();

  @override
  Future<List<InvestorHistoricalValidationCase>> loadValidationCases({
    required String symbol,
    required DateTime asOf,
  }) async {
    final normalized = symbol.toUpperCase();
    final directionSign = normalized == 'IVBEAR' ? -1.0 : 1.0;
    final historicalCases = <InvestorHistoricalValidationCase>[];

    for (var index = 0; index < 48; index++) {
      final setupTime = asOf.subtract(Duration(days: 840 + (index * 120)));

      final isSimilar = index.isEven;
      final isAligned = isSimilar
          ? switch (normalized) {
              'IVOPPOSE' => index % 8 == 0,
              'IVMIX' => index % 4 < 2,
              _ => index % 5 != 0,
            }
          : index % 4 < 2;

      final familyScores = isSimilar
          ? _similarFamilyScores(directionSign, index)
          : _controlFamilyScores(directionSign, index);

      final outcomes = <InvestorHistoricalHorizon, InvestorHistoricalOutcome>{};

      for (final horizon in InvestorHistoricalHorizon.values) {
        final horizonEnd = setupTime.add(
          Duration(days: horizon.approximateCalendarDays),
        );

        if (horizonEnd.isAfter(asOf)) {
          continue;
        }

        final stockReturn = _stockReturn(
          directionSign: directionSign,
          aligned: isAligned,
          horizon: horizon,
          index: index,
        );
        final benchmarkReturn = _benchmarkReturn(
          horizon: horizon,
          index: index,
        );

        outcomes[horizon] = InvestorHistoricalOutcome(
          horizon: horizon,
          stockReturnPercent: stockReturn,
          benchmarkReturnPercent: benchmarkReturn,
          horizonEnd: horizonEnd,
          availableAt: horizonEnd,
        );
      }

      historicalCases.add(
        InvestorHistoricalValidationCase(
          symbol: normalized,
          setupTime: setupTime,
          setupAvailableAt: setupTime,
          familySignedScores: familyScores,
          directionScore: isSimilar ? 68 * directionSign : 28 * directionSign,
          confidence: isSimilar ? 72 : 65,
          coreFamilyCount: 6,
          outcomes: outcomes,
          isSynthetic: true,
          sourceLabel: 'Synthetic Investor historical validation cases',
        ),
      );
    }

    return List.unmodifiable(historicalCases);
  }

  Map<EvidenceFamily, double> _similarFamilyScores(
    double directionSign,
    int index,
  ) {
    final adjustment = (index % 5) - 2;

    return {
      EvidenceFamily.growth: directionSign * (72 + adjustment),
      EvidenceFamily.profitabilityQuality: directionSign * (68 - adjustment),
      EvidenceFamily.financialStrength: directionSign * (64 + adjustment),
      EvidenceFamily.valuation: directionSign * (70 - adjustment),
      EvidenceFamily.revisions: directionSign * (66 + adjustment),
      EvidenceFamily.capitalAllocation: directionSign * (62 - adjustment),
    };
  }

  Map<EvidenceFamily, double> _controlFamilyScores(
    double directionSign,
    int index,
  ) {
    final adjustment = (index % 3) - 1;

    return {
      EvidenceFamily.growth: directionSign * (52 + adjustment),
      EvidenceFamily.profitabilityQuality: directionSign * (48 - adjustment),
      EvidenceFamily.financialStrength: -directionSign * (48 + adjustment),
      EvidenceFamily.valuation: directionSign * (50 - adjustment),
      EvidenceFamily.revisions: -directionSign * (46 - adjustment),
      EvidenceFamily.capitalAllocation: directionSign * (44 + adjustment),
    };
  }

  double _stockReturn({
    required double directionSign,
    required bool aligned,
    required InvestorHistoricalHorizon horizon,
    required int index,
  }) {
    final magnitude = switch (horizon) {
      InvestorHistoricalHorizon.sixMonths => 10.0,
      InvestorHistoricalHorizon.twelveMonths => 18.0,
      InvestorHistoricalHorizon.twentyFourMonths => 30.0,
    };

    final variation = (index % 4) * 0.8;
    final signed = aligned ? magnitude + variation : -(magnitude * 0.55);

    return signed * directionSign;
  }

  double _benchmarkReturn({
    required InvestorHistoricalHorizon horizon,
    required int index,
  }) {
    final base = switch (horizon) {
      InvestorHistoricalHorizon.sixMonths => 4.0,
      InvestorHistoricalHorizon.twelveMonths => 8.0,
      InvestorHistoricalHorizon.twentyFourMonths => 15.0,
    };

    return base + ((index % 3) * 0.5);
  }
}
