import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/providers/mock_market_data_provider.dart';

void main() {
  const provider = MockMarketDataProvider();

  group('MockMarketDataProvider', () {
    test('returns the requested number of five-minute candles', () async {
      final snapshot = await provider.fetchSnapshot(
        symbol: 'aapl',
        timeframe: '5m',
        candleCount: 48,
      );

      expect(snapshot.symbol, 'AAPL');
      expect(snapshot.timeframe, '5m');
      expect(snapshot.candleCount, 48);
      expect(snapshot.hasCandles, isTrue);
      expect(snapshot.latestCandle, isNotNull);
      expect(snapshot.currentPrice, snapshot.latestCandle!.close);
      expect(snapshot.currentVolume, snapshot.latestCandle!.volume);
    });

    test('creates candles in chronological order', () async {
      final snapshot = await provider.fetchSnapshot(
        symbol: 'AAPL',
        timeframe: '5m',
        candleCount: 3,
      );

      expect(
        snapshot.candles[0].timestamp.isBefore(
          snapshot.candles[1].timestamp,
        ),
        isTrue,
      );

      expect(
        snapshot.candles[1].timestamp.isBefore(
          snapshot.candles[2].timestamp,
        ),
        isTrue,
      );
    });

    test('rejects unsupported timeframe', () {
      expect(
        () => provider.fetchSnapshot(
          symbol: 'AAPL',
          timeframe: '30m',
          candleCount: 48,
        ),
        throwsArgumentError,
      );
    });

    test('rejects empty symbol', () {
      expect(
        () => provider.fetchSnapshot(
          symbol: '   ',
          timeframe: '5m',
          candleCount: 48,
        ),
        throwsArgumentError,
      );
    });

    test('rejects invalid candle count', () {
      expect(
        () => provider.fetchSnapshot(
          symbol: 'AAPL',
          timeframe: '5m',
          candleCount: 0,
        ),
        throwsArgumentError,
      );
    });
  });
}