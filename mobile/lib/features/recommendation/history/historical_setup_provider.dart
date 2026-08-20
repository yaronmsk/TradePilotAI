import '../models/strategy_summary.dart';
import 'historical_setup_case.dart';
import 'historical_setup_fingerprint.dart';

abstract interface class HistoricalSetupProvider {
  Future<HistoricalSetupDataset> loadDataset({
    required String symbol,
    required StrategyType strategy,
    required String primaryTimeframe,
    required HistoricalSetupFingerprint currentFingerprint,
    required int forwardBars,
  });
}
