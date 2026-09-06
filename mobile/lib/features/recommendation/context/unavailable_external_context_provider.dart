import '../models/strategy_summary.dart';
import 'external_context_profile.dart';
import 'external_context_provider.dart';
import 'market_context_target.dart';

class UnavailableExternalContextProvider implements ExternalContextProvider {
  const UnavailableExternalContextProvider();

  @override
  Future<ExternalContextProfile> load({
    required String symbol,
    required StrategyType strategy,
    required String primaryTimeframe,
    required MarketContextTarget target,
  }) async {
    return const ExternalContextProfile.unavailable();
  }
}
