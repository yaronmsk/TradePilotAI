import '../../../core/data/data_provenance.dart';

class MarketCandle {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final DataProvenance provenance;

  const MarketCandle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    this.provenance = const DataProvenance.synthetic(),
  });

  bool get isBullish => close > open;

  bool get isBearish => close < open;

  double get range => high - low;

  double get bodySize => (close - open).abs();
}
