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
        snapshot.candles[0].timestamp.isBefore(snapshot.candles[1].timestamp),
        isTrue,
      );

      expect(
        snapshot.candles[1].timestamp.isBefore(snapshot.candles[2].timestamp),
        isTrue,
      );
    });

    test(
      'supports strategy analysis intervals beyond the default 5m',
      () async {
        for (final timeframe in <String>['30m', '4h', '1w', '1mo', '3mo']) {
          final snapshot = await provider.fetchSnapshot(
            symbol: 'AAPL',
            timeframe: timeframe,
            candleCount: 12,
          );

          expect(snapshot.timeframe, timeframe);
          expect(snapshot.candleCount, 12);
        }
      },
    );

    test('rejects unsupported timeframe', () {
      expect(
        () => provider.fetchSnapshot(
          symbol: 'AAPL',
          timeframe: '2m',
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

    test(
      'uses different deterministic trends across Trader timeframes',
      () async {
        final shortTerm = await provider.fetchSnapshot(
          symbol: 'PLTR',
          timeframe: '5m',
          candleCount: 48,
        );
        final confirmation = await provider.fetchSnapshot(
          symbol: 'PLTR',
          timeframe: '1h',
          candleCount: 48,
        );
        final regime = await provider.fetchSnapshot(
          symbol: 'PLTR',
          timeframe: '1d',
          candleCount: 48,
        );

        expect(shortTerm.currentPrice, lessThan(shortTerm.candles.first.close));
        expect(
          confirmation.currentPrice,
          greaterThan(confirmation.candles.first.close),
        );
        expect(regime.currentPrice, greaterThan(regime.candles.first.close));
      },
    );

    test('provides explicit broad-market and sector proxy behavior', () async {
      final spy = await provider.fetchSnapshot(
        symbol: 'SPY',
        timeframe: '1d',
        candleCount: 48,
      );
      final xlk = await provider.fetchSnapshot(
        symbol: 'XLK',
        timeframe: '1d',
        candleCount: 48,
      );

      expect(spy.symbol, 'SPY');
      expect(xlk.symbol, 'XLK');
      expect(spy.currentPrice, greaterThan(spy.candles.first.close));
      expect(xlk.currentPrice, greaterThan(xlk.candles.first.close));
    });
  });
}
