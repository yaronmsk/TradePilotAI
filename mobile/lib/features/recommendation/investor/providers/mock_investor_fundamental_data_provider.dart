import '../models/investor_data_contracts.dart';
import 'investor_data_providers.dart';

class MockInvestorFundamentalDataProvider implements FundamentalDataProvider {
  const MockInvestorFundamentalDataProvider();

  @override
  Future<List<InvestorMetricPoint<InvestorFundamentalMetric>>> loadHistory({
    required String symbol,
    required DateTime asOf,
  }) async {
    final profile = _profileFor(symbol.toUpperCase());

    // Use the most recent fiscal year whose synthetic filing would already
    // have been published by the requested analysis date.
    final latestFiscalYear = asOf.month >= 3 ? asOf.year - 1 : asOf.year - 2;

    final points = <InvestorMetricPoint<InvestorFundamentalMetric>>[];

    for (var index = 0; index < 4; index++) {
      final fiscalYear = latestFiscalYear - 3 + index;
      final observedAt = DateTime(fiscalYear, 12, 31);
      final availableAt = DateTime(fiscalYear + 1, 3, 1);

      InvestorDataMetadata metadata() => InvestorDataMetadata(
        sourceName: 'Synthetic Investor fundamentals',
        sourceType: InvestorDataSourceType.synthetic,
        observedAt: observedAt,
        availableAt: availableAt,
        isSynthetic: true,
      );

      void add(InvestorFundamentalMetric metric, double value) {
        points.add(
          InvestorMetricPoint(
            metric: metric,
            value: value,
            metadata: metadata(),
          ),
        );
      }

      add(InvestorFundamentalMetric.revenue, profile.revenue[index]);
      add(InvestorFundamentalMetric.dilutedEps, profile.eps[index]);
      add(InvestorFundamentalMetric.freeCashFlow, profile.freeCashFlow[index]);
      add(InvestorFundamentalMetric.grossMargin, profile.grossMargin[index]);
      add(
        InvestorFundamentalMetric.operatingMargin,
        profile.operatingMargin[index],
      );
      add(
        InvestorFundamentalMetric.freeCashFlowMargin,
        profile.freeCashFlowMargin[index],
      );
      add(
        InvestorFundamentalMetric.returnOnInvestedCapital,
        profile.roic[index],
      );
    }

    return List.unmodifiable(points);
  }

  _MockFundamentalProfile _profileFor(String symbol) {
    return switch (symbol) {
      'IVBULL' => const _MockFundamentalProfile(
        revenue: [100, 115, 135, 160],
        eps: [2.0, 2.4, 3.0, 4.0],
        freeCashFlow: [12, 16, 22, 30],
        grossMargin: [40, 42, 44, 46],
        operatingMargin: [15, 17, 20, 23],
        freeCashFlowMargin: [12, 14, 16.3, 18.8],
        roic: [12, 14, 17, 20],
      ),
      'IVBEAR' => const _MockFundamentalProfile(
        revenue: [160, 150, 135, 115],
        eps: [4.0, 3.2, 2.0, 0.8],
        freeCashFlow: [25, 20, 12, 5],
        grossMargin: [48, 45, 41, 36],
        operatingMargin: [22, 18, 12, 5],
        freeCashFlowMargin: [15.6, 13.3, 8.9, 4.3],
        roic: [20, 16, 10, 4],
      ),
      'IVMIX' => const _MockFundamentalProfile(
        revenue: [100, 110, 122, 135],
        eps: [2.0, 2.2, 2.3, 2.4],
        freeCashFlow: [12, 13, 13, 14],
        grossMargin: [46, 44, 42, 40],
        operatingMargin: [18, 16, 14, 12],
        freeCashFlowMargin: [12, 11.5, 10.7, 10.4],
        roic: [16, 14, 12, 10],
      ),
      _ => const _MockFundamentalProfile(
        revenue: [100, 101, 102, 103],
        eps: [2.0, 2.02, 2.04, 2.06],
        freeCashFlow: [10, 10.1, 10.2, 10.3],
        grossMargin: [40, 40.1, 40.0, 40.1],
        operatingMargin: [12, 12.1, 12.0, 12.1],
        freeCashFlowMargin: [10, 10.0, 10.1, 10.0],
        roic: [11, 11.1, 11.0, 11.1],
      ),
    };
  }
}

class _MockFundamentalProfile {
  const _MockFundamentalProfile({
    required this.revenue,
    required this.eps,
    required this.freeCashFlow,
    required this.grossMargin,
    required this.operatingMargin,
    required this.freeCashFlowMargin,
    required this.roic,
  });

  final List<double> revenue;
  final List<double> eps;
  final List<double> freeCashFlow;
  final List<double> grossMargin;
  final List<double> operatingMargin;
  final List<double> freeCashFlowMargin;
  final List<double> roic;
}
