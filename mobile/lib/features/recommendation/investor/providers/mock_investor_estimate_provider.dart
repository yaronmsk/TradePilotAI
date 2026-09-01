import '../models/investor_data_contracts.dart';
import 'investor_data_providers.dart';

class MockInvestorEstimateProvider implements AnalystEstimateProvider {
  const MockInvestorEstimateProvider();

  @override
  Future<List<InvestorEstimatePoint>> loadEstimates({
    required String symbol,
    required DateTime asOf,
  }) async {
    final profile = _profileFor(symbol.toUpperCase());
    final targetPeriodEnd = DateTime(asOf.year + 1, 12, 31);

    final vintages = [
      (
        daysAgo: 90,
        revenue: profile.revenue[0],
        eps: profile.eps[0],
        fcf: profile.fcf[0],
      ),
      (
        daysAgo: 30,
        revenue: profile.revenue[1],
        eps: profile.eps[1],
        fcf: profile.fcf[1],
      ),
      (
        daysAgo: 0,
        revenue: profile.revenue[2],
        eps: profile.eps[2],
        fcf: profile.fcf[2],
      ),
    ];

    final result = <InvestorEstimatePoint>[];

    for (final vintage in vintages) {
      final timestamp = asOf.subtract(Duration(days: vintage.daysAgo));

      InvestorDataMetadata metadata() => InvestorDataMetadata(
        sourceName: 'Synthetic Investor analyst estimates',
        sourceType: InvestorDataSourceType.synthetic,
        observedAt: timestamp,
        availableAt: timestamp,
        isSynthetic: true,
      );

      result.addAll([
        InvestorEstimatePoint(
          metric: InvestorEstimateMetric.revenue,
          value: vintage.revenue,
          targetPeriodEnd: targetPeriodEnd,
          metadata: metadata(),
        ),
        InvestorEstimatePoint(
          metric: InvestorEstimateMetric.dilutedEps,
          value: vintage.eps,
          targetPeriodEnd: targetPeriodEnd,
          metadata: metadata(),
        ),
        InvestorEstimatePoint(
          metric: InvestorEstimateMetric.freeCashFlow,
          value: vintage.fcf,
          targetPeriodEnd: targetPeriodEnd,
          metadata: metadata(),
        ),
      ]);
    }

    return List.unmodifiable(result);
  }

  _MockEstimateProfile _profileFor(String symbol) {
    return switch (symbol) {
      'IVBULL' => const _MockEstimateProfile(
        revenue: [170, 176, 182],
        eps: [4.20, 4.50, 4.85],
        fcf: [32, 34, 37],
      ),
      'IVBEAR' => const _MockEstimateProfile(
        revenue: [125, 118, 108],
        eps: [1.20, 0.95, 0.65],
        fcf: [8, 6.5, 4.5],
      ),
      'IVMIX' => const _MockEstimateProfile(
        revenue: [140, 144, 147],
        eps: [2.60, 2.45, 2.30],
        fcf: [15, 15.2, 15.0],
      ),
      _ => const _MockEstimateProfile(
        revenue: [105, 105.5, 106],
        eps: [2.10, 2.11, 2.12],
        fcf: [10.5, 10.55, 10.6],
      ),
    };
  }
}

class _MockEstimateProfile {
  const _MockEstimateProfile({
    required this.revenue,
    required this.eps,
    required this.fcf,
  });

  final List<double> revenue;
  final List<double> eps;
  final List<double> fcf;
}
