import '../models/market_snapshot.dart';
import '../providers/market_data_provider.dart';

class MarketService {
  const MarketService(this._provider);

  final MarketDataProvider _provider;

  Future<MarketSnapshot> loadSnapshot({
    required String symbol,
    required String timeframe,
    required int candleCount,
  }) {
    return _provider.fetchSnapshot(
      symbol: symbol,
      timeframe: timeframe,
      candleCount: candleCount,
    );
  }
}