import 'dart:math' as math;

import '../models/market_candle.dart';
import '../models/market_history_range.dart';
import 'market_history_provider.dart';

class MockMarketHistoryProvider implements MarketHistoryProvider {
  const MockMarketHistoryProvider();

  @override
  Future<List<MarketCandle>> fetchHistory({
    required String symbol,
    required MarketHistoryRange range,
    required double endPrice,
  }) async {
    final normalizedSymbol = symbol.trim().toUpperCase();

    if (normalizedSymbol.isEmpty) {
      throw ArgumentError.value(symbol, 'symbol', 'Symbol cannot be empty.');
    }

    if (endPrice <= 0) {
      throw ArgumentError.value(
        endPrice,
        'endPrice',
        'End price must be greater than zero.',
      );
    }

    final behavior = _behaviorForSymbol(normalizedSymbol);
    final hash = normalizedSymbol.codeUnits.fold<int>(
      0,
      (value, character) => value + character,
    );

    final pointCount = range.pointCount;
    final interval = range.interval;
    final endTime = DateTime.now();

    final totalMovePercent =
        behavior.annualMovePercent * _rangeMoveFactor(range);
    final startPrice = endPrice / (1 + totalMovePercent);
    final noiseScale = behavior.dailyCloseNoisePercent * _noiseScale(range);
    final rangeScale = behavior.dailyRangePercent * _rangeScale(range);

    final candles = <MarketCandle>[];
    double previousClose = startPrice;

    for (var index = 0; index < pointCount; index++) {
      final progress = pointCount == 1 ? 1.0 : index / (pointCount - 1);
      final baseline = startPrice + ((endPrice - startPrice) * progress);

      final noise = _deterministicNoise(index, hash);
      final secondaryNoise = _deterministicNoise(index + 17, hash + 31);

      var close = baseline * (1 + (noise * noiseScale));

      if (index == pointCount - 1) {
        close = endPrice;
      }

      close = math.max(0.01, close);

      final open = index == 0 ? close : previousClose;
      final rangePadding =
          ((open + close) / 2) *
          rangeScale *
          (0.75 + (secondaryNoise.abs() * 0.50));

      final high = math.max(open, close) + rangePadding;
      final low = math.max(0.01, math.min(open, close) - rangePadding);

      final timestamp = endTime.subtract(
        Duration(
          microseconds: interval.inMicroseconds * (pointCount - index - 1),
        ),
      );

      final volumeNoise = _deterministicNoise(index + 7, hash + 73);
      final gradualVolumeChange = 1 + (0.12 * progress);
      var volume =
          behavior.baseVolume *
          gradualVolumeChange *
          (1 + (volumeNoise * behavior.volumeVariability));

      if (behavior.volumeVariability >= 0.70 && index > 0 && index % 29 == 0) {
        volume *= 1.65;
      }

      volume = math.max(1000.0, volume);

      candles.add(
        MarketCandle(
          timestamp: timestamp,
          open: open,
          high: high,
          low: low,
          close: close,
          volume: volume,
        ),
      );

      previousClose = close;
    }

    return List<MarketCandle>.unmodifiable(candles);
  }

  _MockHistoryBehavior _behaviorForSymbol(String symbol) {
    switch (symbol) {
      case 'AAPL':
        return const _MockHistoryBehavior(
          annualMovePercent: 0.18,
          dailyCloseNoisePercent: 0.007,
          dailyRangePercent: 0.006,
          baseVolume: 52000000,
          volumeVariability: 0.18,
        );
      case 'MSFT':
        return const _MockHistoryBehavior(
          annualMovePercent: 0.20,
          dailyCloseNoisePercent: 0.0065,
          dailyRangePercent: 0.0055,
          baseVolume: 24000000,
          volumeVariability: 0.16,
        );
      case 'GOOG':
        return const _MockHistoryBehavior(
          annualMovePercent: 0.14,
          dailyCloseNoisePercent: 0.010,
          dailyRangePercent: 0.008,
          baseVolume: 28000000,
          volumeVariability: 0.28,
        );
      case 'NVDA':
        return const _MockHistoryBehavior(
          annualMovePercent: 0.48,
          dailyCloseNoisePercent: 0.020,
          dailyRangePercent: 0.016,
          baseVolume: 190000000,
          volumeVariability: 0.72,
        );
      case 'TSLA':
        return const _MockHistoryBehavior(
          annualMovePercent: -0.16,
          dailyCloseNoisePercent: 0.026,
          dailyRangePercent: 0.021,
          baseVolume: 125000000,
          volumeVariability: 0.90,
        );
      case 'PLTR':
        return const _MockHistoryBehavior(
          annualMovePercent: 0.34,
          dailyCloseNoisePercent: 0.023,
          dailyRangePercent: 0.019,
          baseVolume: 76000000,
          volumeVariability: 0.82,
        );
      case 'AMD':
        return const _MockHistoryBehavior(
          annualMovePercent: 0.26,
          dailyCloseNoisePercent: 0.017,
          dailyRangePercent: 0.014,
          baseVolume: 68000000,
          volumeVariability: 0.55,
        );
      default:
        return _behaviorFromSymbolHash(symbol);
    }
  }

  _MockHistoryBehavior _behaviorFromSymbolHash(String symbol) {
    final hash = symbol.codeUnits.fold<int>(
      0,
      (value, character) => value + character,
    );

    final volatilityBucket = hash % 3;

    return _MockHistoryBehavior(
      annualMovePercent: ((hash % 41) - 12) / 100,
      dailyCloseNoisePercent: switch (volatilityBucket) {
        0 => 0.008,
        1 => 0.014,
        _ => 0.022,
      },
      dailyRangePercent: switch (volatilityBucket) {
        0 => 0.007,
        1 => 0.012,
        _ => 0.018,
      },
      baseVolume: 8000000 + ((hash % 20) * 2500000),
      volumeVariability: switch (volatilityBucket) {
        0 => 0.20,
        1 => 0.45,
        _ => 0.78,
      },
    );
  }

  double _deterministicNoise(int index, int seed) {
    final value = (index * 37 + seed * 17 + index * index * 13) % 101;
    return (value / 50) - 1;
  }

  double _rangeMoveFactor(MarketHistoryRange range) {
    switch (range) {
      case MarketHistoryRange.oneDay:
        return 0.02;
      case MarketHistoryRange.fiveDays:
        return 0.05;
      case MarketHistoryRange.oneMonth:
        return 0.16;
      case MarketHistoryRange.threeMonths:
        return 0.38;
      case MarketHistoryRange.oneYear:
        return 1.00;
    }
  }

  double _noiseScale(MarketHistoryRange range) {
    switch (range) {
      case MarketHistoryRange.oneDay:
        return 0.10;
      case MarketHistoryRange.fiveDays:
        return 0.28;
      case MarketHistoryRange.oneMonth:
        return 0.65;
      case MarketHistoryRange.threeMonths:
        return 0.85;
      case MarketHistoryRange.oneYear:
        return 1.00;
    }
  }

  double _rangeScale(MarketHistoryRange range) {
    switch (range) {
      case MarketHistoryRange.oneDay:
        return 0.08;
      case MarketHistoryRange.fiveDays:
        return 0.22;
      case MarketHistoryRange.oneMonth:
        return 0.62;
      case MarketHistoryRange.threeMonths:
        return 0.82;
      case MarketHistoryRange.oneYear:
        return 1.00;
    }
  }
}

class _MockHistoryBehavior {
  const _MockHistoryBehavior({
    required this.annualMovePercent,
    required this.dailyCloseNoisePercent,
    required this.dailyRangePercent,
    required this.baseVolume,
    required this.volumeVariability,
  });

  final double annualMovePercent;
  final double dailyCloseNoisePercent;
  final double dailyRangePercent;
  final double baseVolume;
  final double volumeVariability;
}
