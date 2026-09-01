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
      add(InvestorFundamentalMetric.netIncome, profile.netIncome[index]);
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
      add(InvestorFundamentalMetric.cashAndEquivalents, profile.cash[index]);
      add(InvestorFundamentalMetric.totalDebt, profile.debt[index]);
      add(
        InvestorFundamentalMetric.interestExpense,
        profile.interestExpense[index],
      );
      add(
        InvestorFundamentalMetric.sharesOutstanding,
        profile.sharesOutstanding[index],
      );
      add(
        InvestorFundamentalMetric.stockBasedCompensation,
        profile.stockBasedCompensation[index],
      );
      add(
        InvestorFundamentalMetric.dividendsPaid,
        profile.dividendsPaid[index],
      );
      add(
        InvestorFundamentalMetric.shareRepurchases,
        profile.shareRepurchases[index],
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
        netIncome: [10, 14, 19, 25],
        grossMargin: [40, 42, 44, 46],
        operatingMargin: [15, 17, 20, 23],
        freeCashFlowMargin: [12, 14, 16.3, 18.8],
        roic: [12, 14, 17, 20],
        cash: [20, 25, 35, 50],
        debt: [40, 35, 30, 25],
        interestExpense: [2.0, 1.8, 1.5, 1.2],
        sharesOutstanding: [100, 99, 97, 95],
        stockBasedCompensation: [2.0, 2.2, 2.4, 2.5],
        dividendsPaid: [1.0, 1.2, 1.5, 2.0],
        shareRepurchases: [3, 4, 6, 8],
      ),
      'IVBEAR' => const _MockFundamentalProfile(
        revenue: [160, 150, 135, 115],
        eps: [4.0, 3.2, 2.0, 0.8],
        freeCashFlow: [25, 20, 12, 5],
        netIncome: [20, 15, 8, 3],
        grossMargin: [48, 45, 41, 36],
        operatingMargin: [22, 18, 12, 5],
        freeCashFlowMargin: [15.6, 13.3, 8.9, 4.3],
        roic: [20, 16, 10, 4],
        cash: [30, 25, 20, 12],
        debt: [40, 55, 75, 100],
        interestExpense: [2, 3, 5, 8],
        sharesOutstanding: [100, 105, 112, 120],
        stockBasedCompensation: [4, 5, 7, 10],
        dividendsPaid: [3, 4, 5, 6],
        shareRepurchases: [2, 3, 4, 5],
      ),
      'IVMIX' => const _MockFundamentalProfile(
        revenue: [100, 110, 122, 135],
        eps: [2.0, 2.2, 2.3, 2.4],
        freeCashFlow: [12, 13, 13, 14],
        netIncome: [12, 12, 12, 12],
        grossMargin: [46, 44, 42, 40],
        operatingMargin: [18, 16, 14, 12],
        freeCashFlowMargin: [12, 11.5, 10.7, 10.4],
        roic: [16, 14, 12, 10],
        cash: [20, 20, 18, 15],
        debt: [30, 35, 42, 50],
        interestExpense: [1.5, 2.0, 2.5, 3.0],
        sharesOutstanding: [100, 102, 105, 109],
        stockBasedCompensation: [3, 4, 5, 6],
        dividendsPaid: [0, 0, 0, 0],
        shareRepurchases: [0, 1, 1, 1],
      ),
      _ => const _MockFundamentalProfile(
        revenue: [100, 101, 102, 103],
        eps: [2.0, 2.02, 2.04, 2.06],
        freeCashFlow: [10, 10.1, 10.2, 10.3],
        netIncome: [10, 10.1, 10.2, 10.3],
        grossMargin: [40, 40.1, 40.0, 40.1],
        operatingMargin: [12, 12.1, 12.0, 12.1],
        freeCashFlowMargin: [10, 10.0, 10.1, 10.0],
        roic: [11, 11.1, 11.0, 11.1],
        cash: [20, 20, 20, 20],
        debt: [30, 30, 30, 30],
        interestExpense: [2, 2, 2, 2],
        sharesOutstanding: [100, 100.2, 100.4, 100.6],
        stockBasedCompensation: [2.5, 2.5, 2.5, 2.5],
        dividendsPaid: [1, 1, 1, 1],
        shareRepurchases: [1, 1, 1, 1],
      ),
    };
  }
}

class _MockFundamentalProfile {
  const _MockFundamentalProfile({
    required this.revenue,
    required this.eps,
    required this.freeCashFlow,
    required this.netIncome,
    required this.grossMargin,
    required this.operatingMargin,
    required this.freeCashFlowMargin,
    required this.roic,
    required this.cash,
    required this.debt,
    required this.interestExpense,
    required this.sharesOutstanding,
    required this.stockBasedCompensation,
    required this.dividendsPaid,
    required this.shareRepurchases,
  });

  final List<double> revenue;
  final List<double> eps;
  final List<double> freeCashFlow;
  final List<double> netIncome;
  final List<double> grossMargin;
  final List<double> operatingMargin;
  final List<double> freeCashFlowMargin;
  final List<double> roic;
  final List<double> cash;
  final List<double> debt;
  final List<double> interestExpense;
  final List<double> sharesOutstanding;
  final List<double> stockBasedCompensation;
  final List<double> dividendsPaid;
  final List<double> shareRepurchases;
}
