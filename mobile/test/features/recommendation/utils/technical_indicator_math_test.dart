import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/recommendation/utils/technical_indicator_math.dart';

void main() {
  test('EMA follows a rising sequence and remains below latest value', () {
    final values = List<double>.generate(20, (index) => 100 + index.toDouble());

    final ema = TechnicalIndicatorMath.ema(values, 9);

    expect(ema, greaterThan(values.first));
    expect(ema, lessThan(values.last));
  });

  test('window VWAP weights higher-volume candles more heavily', () {
    final candles = [
      MarketCandle(
        timestamp: DateTime(2026, 8, 18, 10),
        open: 100,
        high: 100,
        low: 100,
        close: 100,
        volume: 100,
      ),
      MarketCandle(
        timestamp: DateTime(2026, 8, 18, 10, 5),
        open: 110,
        high: 110,
        low: 110,
        close: 110,
        volume: 900,
      ),
    ];

    final vwap = TechnicalIndicatorMath.windowVwap(candles);

    expect(vwap, closeTo(109, 0.001));
  });

  test('ATR returns positive normalized range input for valid candles', () {
    final candles = List<MarketCandle>.generate(20, (index) {
      final close = 100 + (index * 0.1);
      return MarketCandle(
        timestamp: DateTime(2026, 8, 18, 10).add(Duration(minutes: index * 5)),
        open: close,
        high: close + 1,
        low: close - 1,
        close: close,
        volume: 1000,
      );
    });

    expect(TechnicalIndicatorMath.atr(candles), greaterThan(0));
  });
}
