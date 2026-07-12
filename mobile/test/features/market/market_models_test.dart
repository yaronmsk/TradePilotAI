import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';

void main() {
  test('MarketCandle calculates bullish candle values correctly', () {
    final candle = MarketCandle(
      timestamp: DateTime(2026, 7, 12, 10),
      open: 100,
      high: 108,
      low: 98,
      close: 106,
      volume: 1500000,
    );

    expect(candle.isBullish, isTrue);
    expect(candle.isBearish, isFalse);
    expect(candle.range, 10);
    expect(candle.bodySize, 6);
  });

  test('MarketCandle calculates bearish candle values correctly', () {
    final candle = MarketCandle(
      timestamp: DateTime(2026, 7, 12, 10, 5),
      open: 106,
      high: 107,
      low: 99,
      close: 101,
      volume: 1250000,
    );

    expect(candle.isBullish, isFalse);
    expect(candle.isBearish, isTrue);
    expect(candle.range, 8);
    expect(candle.bodySize, 5);
  });

  test('MarketSnapshot exposes latest candle and candle count', () {
    final candles = [
      MarketCandle(
        timestamp: DateTime(2026, 7, 12, 10),
        open: 100,
        high: 103,
        low: 99,
        close: 102,
        volume: 1000000,
      ),
      MarketCandle(
        timestamp: DateTime(2026, 7, 12, 10, 5),
        open: 102,
        high: 106,
        low: 101,
        close: 105,
        volume: 1400000,
      ),
    ];

    final snapshot = MarketSnapshot(
      symbol: 'AAPL',
      timeframe: '5m',
      timestamp: DateTime(2026, 7, 12, 10, 5),
      currentPrice: 105,
      currentVolume: 1400000,
      candles: candles,
    );

    expect(snapshot.candleCount, 2);
    expect(snapshot.hasCandles, isTrue);
    expect(snapshot.latestCandle, same(candles.last));
  });

  test('MarketSnapshot handles an empty candle list', () {
    final snapshot = MarketSnapshot(
      symbol: 'AAPL',
      timeframe: '5m',
      timestamp: DateTime(2026, 7, 12),
      currentPrice: 0,
      currentVolume: 0,
      candles: const [],
    );

    expect(snapshot.candleCount, 0);
    expect(snapshot.hasCandles, isFalse);
    expect(snapshot.latestCandle, isNull);
  });
}