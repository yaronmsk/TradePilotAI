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

class InvestorEstimatePoint {
  const InvestorEstimatePoint({
    required this.metric,
    required this.value,
    required this.targetPeriodEnd,
    required this.metadata,
  });

  final InvestorEstimateMetric metric;
  final double value;

  /// Fiscal/forecast period this consensus estimate refers to.
  ///
  /// Revision analysis must compare historical vintages only when this target
  /// period matches. Comparing FY1 with FY2 would create a false revision.
  final DateTime targetPeriodEnd;

  final InvestorDataMetadata metadata;
}

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

enum InvestorSensitivityFactor {
  broadMarket,
  sector,
  longTermYield,
  financialConditions,
  usdIndex,
  marketImpliedVolatility,
}

class InvestorSensitivityObservation {
  InvestorSensitivityObservation({
    required this.stockReturnPercent,
    required Map<InvestorSensitivityFactor, double> factorChanges,
    required this.metadata,
  }) : factorChanges = Map.unmodifiable(factorChanges);

  /// Stock return aligned to the observation period.
  final double stockReturnPercent;

  /// Already-aligned weekly factor changes.
  ///
  /// Examples:
  /// - broad market / sector: weekly percentage return
  /// - long-term yield: weekly yield change
  /// - financial conditions: weekly index change
  /// - USD: weekly index/percentage change from the selected provider
  /// - implied volatility: weekly index change
  ///
  /// Using changes avoids pretending raw levels across unlike factors are
  /// directly comparable. The evidence provider standardizes each factor
  /// against its own historical distribution.
  final Map<InvestorSensitivityFactor, double> factorChanges;

  final InvestorDataMetadata metadata;
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
    List<InvestorEstimatePoint> estimates = const [],
    List<InvestorMetricPoint<InvestorMarketMetric>> market = const [],
    List<InvestorValuationReference> valuationReferences = const [],
    List<InvestorMetricPoint<InvestorMacroMetric>> macro = const [],
    List<InvestorSensitivityObservation> sensitivityHistory = const [],
    List<InvestorMetricPoint<InvestorPositioningMetric>> positioning = const [],
    this.peerClassification,
  }) : fundamentals = List.unmodifiable(fundamentals),
       estimates = List.unmodifiable(estimates),
       market = List.unmodifiable(market),
       valuationReferences = List.unmodifiable(valuationReferences),
       macro = List.unmodifiable(macro),
       sensitivityHistory = List.unmodifiable(sensitivityHistory),
       positioning = List.unmodifiable(positioning);

  final String symbol;
  final DateTime analysisTime;

  final List<InvestorMetricPoint<InvestorFundamentalMetric>> fundamentals;
  final List<InvestorEstimatePoint> estimates;
  final List<InvestorMetricPoint<InvestorMarketMetric>> market;
  final List<InvestorValuationReference> valuationReferences;
  final List<InvestorMetricPoint<InvestorMacroMetric>> macro;
  final List<InvestorSensitivityObservation> sensitivityHistory;
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
    for (final observation in sensitivityHistory) {
      yield observation.metadata;
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
