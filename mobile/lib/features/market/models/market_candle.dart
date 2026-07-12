class MarketCandle {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const MarketCandle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  bool get isBullish => close > open;

  bool get isBearish => close < open;

  double get range => high - low;

  double get bodySize => (close - open).abs();
}