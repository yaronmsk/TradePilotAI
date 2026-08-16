import '../models/market_candle.dart';
import '../models/market_history_range.dart';
import '../providers/market_history_provider.dart';

class MarketHistoryService {
  const MarketHistoryService(this._provider);

  final MarketHistoryProvider _provider;

  Future<List<MarketCandle>> loadHistory({
    required String symbol,
    required MarketHistoryRange range,
    required double endPrice,
  }) {
    return _provider.fetchHistory(
      symbol: symbol,
      range: range,
      endPrice: endPrice,
    );
  }
}
