import '../models/strategy_summary.dart';
import 'external_context_profile.dart';
import 'market_context_target.dart';

abstract interface class ExternalContextProvider {
  Future<ExternalContextProfile> load({
    required String symbol,
    required StrategyType strategy,
    required String primaryTimeframe,
    required MarketContextTarget target,
  });
}
