enum InvestorDataSourceType {
  regulatoryFiling,
  analystConsensus,
  marketSeries,
  macroSeries,
  ownershipFiling,
  synthetic,
}

class InvestorDataMetadata {
  const InvestorDataMetadata({
    required this.sourceName,
    required this.sourceType,
    required this.observedAt,
    required this.availableAt,
    this.isSynthetic = false,
  });

  final String sourceName;
  final InvestorDataSourceType sourceType;

  /// When the underlying economic/market observation occurred.
  final DateTime observedAt;

  /// Earliest time the observation was actually available to the analysis.
  ///
  /// Historical Investor analysis must gate on this field rather than using
  /// fiscal-period or portfolio-period dates as though the data were already
  /// public.
  final DateTime availableAt;

  final bool isSynthetic;

  bool isAvailableAt(DateTime analysisTime) =>
      !availableAt.isAfter(analysisTime);
}

class InvestorMetricPoint<M extends Enum> {
  const InvestorMetricPoint({
    required this.metric,
    required this.value,
    required this.metadata,
  });

  final M metric;
  final double value;
  final InvestorDataMetadata metadata;
}

enum InvestorFundamentalMetric {
  revenue,
  dilutedEps,
  freeCashFlow,
  netIncome,
  grossMargin,
  operatingMargin,
  freeCashFlowMargin,
  returnOnInvestedCapital,
  cashAndEquivalents,
  totalDebt,
  interestExpense,
  sharesOutstanding,
  stockBasedCompensation,

  /// Positive cash amounts used for capital-allocation analysis.
  dividendsPaid,
  shareRepurchases,
}

enum InvestorEstimateMetric { revenue, dilutedEps, freeCashFlow }

enum InvestorMarketMetric { marketCapitalization, enterpriseValue }

enum InvestorValuationMultiple {
  priceToEarnings,
  priceToFreeCashFlow,
  enterpriseValueToOperatingProfit,
}

class InvestorValuationReference {
  const InvestorValuationReference({
    required this.multiple,
    required this.metadata,
    this.ownHistoryMedian,
    this.peerMedian,
  });

  final InvestorValuationMultiple multiple;
  final double? ownHistoryMedian;
  final double? peerMedian;
  final InvestorDataMetadata metadata;
}

class InvestorValuationContext {
  InvestorValuationContext({
    List<InvestorMetricPoint<InvestorMarketMetric>> market = const [],
    List<InvestorValuationReference> references = const [],
  }) : market = List.unmodifiable(market),
       references = List.unmodifiable(references);

  final List<InvestorMetricPoint<InvestorMarketMetric>> market;
  final List<InvestorValuationReference> references;
}

enum InvestorMacroMetric {
  policyRate,
  longTermYield,
  yieldCurveSpread,
  financialConditions,
  inflationRate,
  usdIndex,
  marketImpliedVolatility,
}

enum InvestorPositioningMetric {
  institutionalOwnershipPercent,
  institutionalHolderCount,
  shortInterestPercentFloat,
  insiderNetShares,
}

class InvestorPeerClassification {
  InvestorPeerClassification({
    required this.symbol,
    required this.sector,
    required this.industry,
    required List<String> peerSymbols,
    required this.metadata,
  }) : peerSymbols = List.unmodifiable(peerSymbols);

  final String symbol;
  final String sector;
  final String industry;
  final List<String> peerSymbols;
  final InvestorDataMetadata metadata;
}

class InvestorPointInTimeSnapshot {
  InvestorPointInTimeSnapshot({
    required this.symbol,
    required this.analysisTime,
    List<InvestorMetricPoint<InvestorFundamentalMetric>> fundamentals =
        const [],
    List<InvestorMetricPoint<InvestorEstimateMetric>> estimates = const [],
    List<InvestorMetricPoint<InvestorMarketMetric>> market = const [],
    List<InvestorValuationReference> valuationReferences = const [],
    List<InvestorMetricPoint<InvestorMacroMetric>> macro = const [],
    List<InvestorMetricPoint<InvestorPositioningMetric>> positioning = const [],
    this.peerClassification,
  }) : fundamentals = List.unmodifiable(fundamentals),
       estimates = List.unmodifiable(estimates),
       market = List.unmodifiable(market),
       valuationReferences = List.unmodifiable(valuationReferences),
       macro = List.unmodifiable(macro),
       positioning = List.unmodifiable(positioning);

  final String symbol;
  final DateTime analysisTime;

  final List<InvestorMetricPoint<InvestorFundamentalMetric>> fundamentals;
  final List<InvestorMetricPoint<InvestorEstimateMetric>> estimates;
  final List<InvestorMetricPoint<InvestorMarketMetric>> market;
  final List<InvestorValuationReference> valuationReferences;
  final List<InvestorMetricPoint<InvestorMacroMetric>> macro;
  final List<InvestorMetricPoint<InvestorPositioningMetric>> positioning;
  final InvestorPeerClassification? peerClassification;

  Iterable<InvestorDataMetadata> get allMetadata sync* {
    for (final point in fundamentals) {
      yield point.metadata;
    }
    for (final point in estimates) {
      yield point.metadata;
    }
    for (final point in market) {
      yield point.metadata;
    }
    for (final reference in valuationReferences) {
      yield reference.metadata;
    }
    for (final point in macro) {
      yield point.metadata;
    }
    for (final point in positioning) {
      yield point.metadata;
    }
    if (peerClassification case final classification?) {
      yield classification.metadata;
    }
  }

  bool get isPointInTimeSafe =>
      allMetadata.every((metadata) => metadata.isAvailableAt(analysisTime));

  bool get containsSyntheticData =>
      allMetadata.any((metadata) => metadata.isSynthetic);
}
