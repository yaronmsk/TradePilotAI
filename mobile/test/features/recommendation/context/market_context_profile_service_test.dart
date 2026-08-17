import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/context/market_context_profile.dart';
import 'package:mobile/features/recommendation/context/market_context_profile_service.dart';
import 'package:mobile/features/recommendation/context/market_context_target.dart';

void main() {
  const service = MarketContextProfileService();
  const target = MarketContextTarget(
    marketSymbol: 'SPY',
    sectorSymbol: 'XLK',
    sectorName: 'Technology',
    hasSectorBenchmark: true,
  );

  MarketSnapshot buildSnapshot({
    required String symbol,
    required String timeframe,
    required double start,
    required double end,
    int count = 48,
  }) {
    final candles = <MarketCandle>[];

    for (var index = 0; index < count; index++) {
      final progress = index / (count - 1);
      final close = start + ((end - start) * progress);
      candles.add(
        MarketCandle(
          timestamp: DateTime(2026, 1, 1).add(Duration(hours: index)),
          open: close - 0.05,
          high: close + 0.25,
          low: close - 0.25,
          close: close,
          volume: 1000000,
        ),
      );
    }

    return MarketSnapshot(
      symbol: symbol,
      timeframe: timeframe,
      timestamp: candles.last.timestamp,
      currentPrice: candles.last.close,
      currentVolume: candles.last.volume,
      candles: candles,
    );
  }

  test('recognizes stock leadership versus market and sector', () {
    final profile = service.evaluate(
      target: target,
      stockConfirmation: buildSnapshot(
        symbol: 'NVDA',
        timeframe: '1h',
        start: 100,
        end: 108,
      ),
      stockRegime: buildSnapshot(
        symbol: 'NVDA',
        timeframe: '1d',
        start: 100,
        end: 120,
      ),
      marketConfirmation: buildSnapshot(
        symbol: 'SPY',
        timeframe: '1h',
        start: 100,
        end: 102,
      ),
      marketRegime: buildSnapshot(
        symbol: 'SPY',
        timeframe: '1d',
        start: 100,
        end: 105,
      ),
      sectorConfirmation: buildSnapshot(
        symbol: 'XLK',
        timeframe: '1h',
        start: 100,
        end: 103,
      ),
      sectorRegime: buildSnapshot(
        symbol: 'XLK',
        timeframe: '1d',
        start: 100,
        end: 108,
      ),
    );

    expect(profile.hasSufficientData, isTrue);
    expect(profile.relativeStrength, RelativeStrengthState.outperforming);
    expect(profile.directionScore, greaterThan(0));
    expect(profile.stockVsMarketPercent, greaterThan(0));
    expect(profile.stockVsSectorPercent, greaterThan(0));
  });

  test('recognizes underperformance as a negative context input', () {
    final profile = service.evaluate(
      target: target,
      stockConfirmation: buildSnapshot(
        symbol: 'TEST',
        timeframe: '1h',
        start: 100,
        end: 96,
      ),
      stockRegime: buildSnapshot(
        symbol: 'TEST',
        timeframe: '1d',
        start: 100,
        end: 90,
      ),
      marketConfirmation: buildSnapshot(
        symbol: 'SPY',
        timeframe: '1h',
        start: 100,
        end: 102,
      ),
      marketRegime: buildSnapshot(
        symbol: 'SPY',
        timeframe: '1d',
        start: 100,
        end: 104,
      ),
      sectorConfirmation: buildSnapshot(
        symbol: 'XLK',
        timeframe: '1h',
        start: 100,
        end: 103,
      ),
      sectorRegime: buildSnapshot(
        symbol: 'XLK',
        timeframe: '1d',
        start: 100,
        end: 107,
      ),
    );

    expect(profile.relativeStrength, RelativeStrengthState.underperforming);
    expect(profile.directionScore, lessThan(0));
  });
}
