import '../models/market_candle.dart';
import '../models/market_snapshot.dart';
import 'market_data_provider.dart';

class MockMarketDataProvider implements MarketDataProvider {
  const MockMarketDataProvider();

  @override
  Future<MarketSnapshot> fetchSnapshot({
    required String symbol,
    required String timeframe,
    required int candleCount,
  }) async {
    final normalizedSymbol = symbol.trim().toUpperCase();

    if (normalizedSymbol.isEmpty) {
      throw ArgumentError.value(
        symbol,
        'symbol',
        'Symbol cannot be empty.',
      );
    }

    if (candleCount <= 0) {
      throw ArgumentError.value(
        candleCount,
        'candleCount',
        'Candle count must be greater than zero.',
      );
    }

    final intervalMinutes = _intervalMinutes(timeframe);
    final now = DateTime.now();

    final candles = List<MarketCandle>.generate(
      candleCount,
      (index) {
        final timestamp = now.subtract(
          Duration(
            minutes: intervalMinutes * (candleCount - index - 1),
          ),
        );

        final open = 100.0 + (index * 0.25);
        final close = open + (index.isEven ? 0.80 : -0.35);
        final high = (open > close ? open : close) + 0.40;
        final low = (open < close ? open : close) - 0.40;
        final volume = 900000.0 + (index * 25000.0);

        return MarketCandle(
          timestamp: timestamp,
          open: open,
          high: high,
          low: low,
          close: close,
          volume: volume,
        );
      },
      growable: false,
    );

    final latestCandle = candles.last;

    return MarketSnapshot(
      symbol: normalizedSymbol,
      timeframe: timeframe,
      timestamp: latestCandle.timestamp,
      currentPrice: latestCandle.close,
      currentVolume: latestCandle.volume,
      candles: List<MarketCandle>.unmodifiable(candles),
    );
  }

  int _intervalMinutes(String timeframe) {
    switch (timeframe) {
      case '1m':
        return 1;
      case '5m':
        return 5;
      case '10m':
        return 10;
      case '15m':
        return 15;
      case '1h':
        return 60;
      case '1d':
        return 1440;
      default:
        throw ArgumentError.value(
          timeframe,
          'timeframe',
          'Unsupported timeframe.',
        );
    }
  }
}