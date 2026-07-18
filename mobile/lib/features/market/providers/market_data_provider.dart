import '../models/market_snapshot.dart';

abstract interface class MarketDataProvider {
  Future<MarketSnapshot> fetchSnapshot({
    required String symbol,
    required String timeframe,
    required int candleCount,
  });
} 