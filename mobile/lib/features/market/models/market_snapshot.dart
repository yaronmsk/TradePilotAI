import 'market_candle.dart';

class MarketSnapshot {
  final String symbol;
  final String timeframe;
  final DateTime timestamp;
  final double currentPrice;
  final double currentVolume;
  final List<MarketCandle> candles;

  const MarketSnapshot({
    required this.symbol,
    required this.timeframe,
    required this.timestamp,
    required this.currentPrice,
    required this.currentVolume,
    required this.candles,
  });

  int get candleCount => candles.length;

  bool get hasCandles => candles.isNotEmpty;

  MarketCandle? get latestCandle =>
      candles.isEmpty ? null : candles.last;
}