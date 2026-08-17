import 'market_context_target.dart';

abstract interface class SecurityContextResolver {
  MarketContextTarget resolve(String symbol);
}
