import '../models/market_candle.dart';
import '../models/market_history_range.dart';

abstract interface class MarketHistoryProvider {
  Future<List<MarketCandle>> fetchHistory({
    required String symbol,
    required MarketHistoryRange range,
    required double endPrice,
  });
}
