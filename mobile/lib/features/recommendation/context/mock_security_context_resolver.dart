import 'market_context_target.dart';
import 'security_context_resolver.dart';

class MockSecurityContextResolver implements SecurityContextResolver {
  const MockSecurityContextResolver();

  @override
  MarketContextTarget resolve(String symbol) {
    switch (symbol.trim().toUpperCase()) {
      case 'BULL':
      case 'AAPL':
      case 'MSFT':
      case 'NVDA':
      case 'AMD':
      case 'PLTR':
        return const MarketContextTarget(
          marketSymbol: 'SPY',
          sectorSymbol: 'XLK',
          sectorName: 'Technology',
          hasSectorBenchmark: true,
        );
      case 'GOOG':
        return const MarketContextTarget(
          marketSymbol: 'SPY',
          sectorSymbol: 'XLC',
          sectorName: 'Communication Services',
          hasSectorBenchmark: true,
        );
      case 'TSLA':
        return const MarketContextTarget(
          marketSymbol: 'SPY',
          sectorSymbol: 'XLY',
          sectorName: 'Consumer Discretionary',
          hasSectorBenchmark: true,
        );
      default:
        return const MarketContextTarget(
          marketSymbol: 'SPY',
          sectorSymbol: 'SPY',
          sectorName: 'Sector benchmark unavailable',
          hasSectorBenchmark: false,
        );
    }
  }
}
