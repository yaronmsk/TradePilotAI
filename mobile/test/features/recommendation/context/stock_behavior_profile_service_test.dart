import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/context/stock_behavior_profile.dart';
import 'package:mobile/features/recommendation/context/stock_behavior_profile_service.dart';

void main() {
  const service = StockBehaviorProfileService();

  MarketSnapshot createSnapshot({
    required List<double> closes,
    required double rangePadding,
    List<double>? volumes,
  }) {
    final candles = List<MarketCandle>.generate(closes.length, (index) {
      final close = closes[index];
      final volume = volumes?[index] ?? 1000000;

      return MarketCandle(
        timestamp: DateTime(2026, 8, 16, 10).add(Duration(minutes: index * 5)),
        open: close,
        high: close + rangePadding,
        low: close - rangePadding,
        close: close,
        volume: volume,
      );
    }, growable: false);

    return MarketSnapshot(
      symbol: 'TEST',
      timeframe: '5m',
      timestamp: candles.last.timestamp,
      currentPrice: candles.last.close,
      currentVolume: candles.last.volume,
      candles: candles,
    );
  }

  test('classifies a low-range stock as steady', () {
    final profile = service.evaluate(
      createSnapshot(
        closes: List<double>.generate(20, (index) => 100 + (index * 0.05)),
        rangePadding: 0.10,
      ),
    );

    expect(profile.behaviorType, StockBehaviorType.steady);
    expect(profile.hasSufficientData, isTrue);
  });

  test('classifies a wide-range stock as volatile', () {
    final profile = service.evaluate(
      createSnapshot(
        closes: List<double>.generate(20, (index) => 100 + (index * 0.20)),
        rangePadding: 1.50,
      ),
    );

    expect(profile.behaviorType, StockBehaviorType.volatile);
  });

  test('compares current volume against recent average', () {
    final volumes = List<double>.filled(20, 1000000)..[19] = 2000000;

    final profile = service.evaluate(
      createSnapshot(
        closes: List<double>.generate(20, (index) => 100 + (index * 0.05)),
        rangePadding: 0.10,
        volumes: volumes,
      ),
    );

    expect(profile.averageVolume, 1000000);
    expect(profile.relativeVolume, 2);
  });

  test('returns unknown profile when data is insufficient', () {
    final candle = MarketCandle(
      timestamp: DateTime(2026, 8, 16),
      open: 100,
      high: 101,
      low: 99,
      close: 100,
      volume: 1000000,
    );

    final profile = service.evaluate(
      MarketSnapshot(
        symbol: 'TEST',
        timeframe: '5m',
        timestamp: candle.timestamp,
        currentPrice: 100,
        currentVolume: 1000000,
        candles: [candle],
      ),
    );

    expect(profile.behaviorType, StockBehaviorType.unknown);
    expect(profile.hasSufficientData, isFalse);
  });
}
