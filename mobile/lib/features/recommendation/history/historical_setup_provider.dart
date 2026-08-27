import '../models/strategy_summary.dart';
import 'historical_setup_case.dart';
import 'historical_setup_fingerprint.dart';

abstract interface class HistoricalSetupProvider {
  /// Loads historical outcomes measured over exactly [forwardBars] of the
  /// requested [primaryTimeframe].
  ///
  /// Implementations must keep the supplied strategy/timeframe context
  /// consistent with [currentFingerprint]. A provider must not silently
  /// substitute a different outcome horizon because Historical Validation
  /// scoring is calibrated to the requested strategy-specific window.
  Future<HistoricalSetupDataset> loadDataset({
    required String symbol,
    required StrategyType strategy,
    required String primaryTimeframe,
    required HistoricalSetupFingerprint currentFingerprint,
    required int forwardBars,
  });
}
