import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/recommendation/context/historical_stock_profile_service.dart';

void main() {
  const service = HistoricalStockProfileService();

  List<MarketCandle> buildHistory({
    required int count,
    required double quietMovePercent,
    double? recentMovePercent,
    int recentPeriod = 0,
    double rangePercent = 0.004,
    double baseVolume = 1000000,
    double volumeVariation = 0,
    double recentVolumeMultiplier = 1,
  }) {
    var close = 100.0;
    final candles = <MarketCandle>[];

    for (var index = 0; index < count; index++) {
      final isRecent =
          recentMovePercent != null &&
          recentPeriod > 0 &&
          index >= count - recentPeriod;
      final movePercent = isRecent ? recentMovePercent : quietMovePercent;
      final signedMove = index.isEven ? movePercent : -movePercent * 0.92;
      final open = close;
      close = open * (1 + signedMove);

      final volumeWave = index.isEven ? volumeVariation : -volumeVariation;
      final recentVolume = index >= count - 20 ? recentVolumeMultiplier : 1.0;
      final volume = baseVolume * (1 + volumeWave) * recentVolume;

      candles.add(
        MarketCandle(
          timestamp: DateTime(2025, 1, 1).add(Duration(days: index)),
          open: open,
          high: (open > close ? open : close) * (1 + rangePercent),
          low: (open < close ? open : close) * (1 - rangePercent),
          close: close,
          volume: volume,
        ),
      );
    }

    return candles;
  }

  test('builds a stable long-term baseline from one year of daily data', () {
    final profile = service.evaluate(
      buildHistory(
        count: 252,
        quietMovePercent: 0.003,
        rangePercent: 0.003,
        volumeVariation: 0.05,
      ),
    );

    expect(profile.hasSufficientData, isTrue);
    expect(profile.sampleSize, 252);
    expect(profile.typicalAtrPercent, lessThan(1.6));
    expect(profile.typicalRealizedVolatilityPercent, lessThan(30));
    expect(profile.volumeVariability, lessThan(0.25));
  });

  test('detects an inherently volatile daily history', () {
    final profile = service.evaluate(
      buildHistory(
        count: 252,
        quietMovePercent: 0.04,
        rangePercent: 0.02,
        volumeVariation: 0.55,
      ),
    );

    expect(profile.typicalAtrPercent, greaterThan(3));
    expect(profile.typicalRealizedVolatilityPercent, greaterThan(50));
    expect(profile.volumeVariability, greaterThan(0.40));
  });

  test('detects elevated recent volatility versus the stock own history', () {
    final profile = service.evaluate(
      buildHistory(
        count: 252,
        quietMovePercent: 0.003,
        recentMovePercent: 0.03,
        recentPeriod: 30,
        rangePercent: 0.004,
      ),
    );

    expect(profile.volatilityPercentile, greaterThanOrEqualTo(75));
    expect(
      profile.recentRealizedVolatilityPercent,
      greaterThan(profile.typicalRealizedVolatilityPercent),
    );
  });

  test('tracks recent daily volume versus the longer baseline', () {
    final profile = service.evaluate(
      buildHistory(
        count: 252,
        quietMovePercent: 0.005,
        recentVolumeMultiplier: 1.8,
      ),
    );

    expect(profile.volumeTrendRatio, greaterThan(1));
    expect(
      profile.averageDailyVolume20,
      greaterThan(profile.averageDailyVolume60),
    );
  });

  test('marks a short daily sample as insufficient for Stock DNA', () {
    final profile = service.evaluate(
      buildHistory(count: 30, quietMovePercent: 0.005),
    );

    expect(profile.hasSufficientData, isFalse);
    expect(profile.sampleSize, 30);
  });
}
