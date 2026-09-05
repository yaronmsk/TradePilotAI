import '../models/investor_data_contracts.dart';
import '../models/investor_historical_validation_case.dart';

/// Vendor-neutral source for reported company fundamentals.
///
/// Implementations must not return a point whose `availableAt` is later than
/// [asOf]. SEC/filing data becomes historically usable when it was published,
/// not retroactively at the fiscal-period end date.
abstract interface class FundamentalDataProvider {
  Future<List<InvestorMetricPoint<InvestorFundamentalMetric>>> loadHistory({
    required String symbol,
    required DateTime asOf,
  });
}

/// Vendor-neutral source for point-in-time analyst estimates/revisions.
///
/// Production use requires a provider that preserves historical estimate
/// vintages. A current consensus value must never be backfilled into history.
abstract interface class AnalystEstimateProvider {
  Future<List<InvestorEstimatePoint>> loadEstimates({
    required String symbol,
    required DateTime asOf,
  });
}

/// Resolves sector, industry and an appropriate comparison universe.
abstract interface class PeerClassificationProvider {
  Future<InvestorPeerClassification?> loadClassification({
    required String symbol,
    required DateTime asOf,
  });
}

/// Vendor-neutral source for point-in-time market valuation inputs and
/// comparison references.
///
/// Production implementations must preserve the market timestamp and must not
/// reconstruct historical peer/history medians with information that became
/// available only later.
abstract interface class MarketValuationDataProvider {
  Future<InvestorValuationContext> loadValuationContext({
    required String symbol,
    required DateTime asOf,
  });
}

/// Vendor-neutral source for aligned stock, market, sector and macro
/// history used to estimate stock-specific long-horizon sensitivities.
///
/// Production implementations must preserve observation/release timestamps and
/// must not backfill revised macro data into historical analysis.
abstract interface class InvestorSensitivityDataProvider {
  Future<List<InvestorSensitivityObservation>> loadSensitivityHistory({
    required String symbol,
    required DateTime asOf,
  });
}

/// Vendor-neutral source for long-horizon macro/global market context.
abstract interface class MacroContextProvider {
  Future<List<InvestorMetricPoint<InvestorMacroMetric>>> loadContext({
    required String symbol,
    required DateTime asOf,
  });
}

/// Vendor-neutral ownership/positioning source.
///
/// Filing-based holdings must preserve publication lag. For example, a 13F
/// portfolio-period observation cannot be treated as known before the filing
/// became public.
///
/// Production insider activity must preserve transaction-level classification
/// (for example, open-market purchase/sale versus grant, option exercise,
/// withholding or gift). Raw net-share totals are not directionally safe.
///
/// Short-interest implementations must use published aggregate position data,
/// not substitute daily short-sale volume as though the two were equivalent.
abstract interface class OwnershipPositioningProvider {
  Future<List<InvestorMetricPoint<InvestorPositioningMetric>>> loadPositioning({
    required String symbol,
    required DateTime asOf,
  });
}

/// Point-in-time historical Investor recommendation/outcome source.
///
/// Historical fingerprints must be reconstructed only from information that
/// was available at each setup timestamp. Later filing restatements, current
/// analyst estimates or future-known context must not be backfilled.
///
/// Forward outcomes may be returned only when their horizon has matured by
/// [asOf]. The validation service performs an additional maturity check.
abstract interface class InvestorHistoricalDataProvider {
  Future<List<InvestorHistoricalValidationCase>> loadValidationCases({
    required String symbol,
    required DateTime asOf,
  });
}
