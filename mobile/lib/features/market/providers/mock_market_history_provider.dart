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

    final hash = normalizedSymbol.codeUnits.fold<int>(
      0,
      (value, character) => value + character,
    );

    final pointCount = range.pointCount;
    final interval = range.interval;
    final endTime = DateTime.now();

    final direction = hash.isEven ? 1.0 : -1.0;
    final totalMovePercent = _movePercentForRange(range) * direction;

    final startPrice = endPrice / (1 + totalMovePercent);
    final phase = (hash % 17) / 3;
    final volatility = _volatilityForRange(range);

    final candles = <MarketCandle>[];

    double previousClose = startPrice;

    for (var index = 0; index < pointCount; index++) {
      final progress = pointCount == 1 ? 1.0 : index / (pointCount - 1);

      final baseline = startPrice + ((endPrice - startPrice) * progress);

      final wave = math.sin((index * 0.55) + phase) * endPrice * volatility;

      var close = baseline + wave;

      if (index == pointCount - 1) {
        close = endPrice;
      }

      final open = index == 0 ? close : previousClose;

      final padding = endPrice * (0.0015 + ((hash % 4) * 0.0004));

      final high = math.max(open, close) + padding;
      final low = math.max(0.01, math.min(open, close) - padding);

      final timestamp = endTime.subtract(
        Duration(
          microseconds: interval.inMicroseconds * (pointCount - index - 1),
        ),
      );

      final volume = 900000.0 + ((hash % 8) * 70000) + ((index % 11) * 45000);

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

  double _movePercentForRange(MarketHistoryRange range) {
    switch (range) {
      case MarketHistoryRange.oneDay:
        return 0.018;
      case MarketHistoryRange.fiveDays:
        return 0.045;
      case MarketHistoryRange.oneMonth:
        return 0.08;
      case MarketHistoryRange.threeMonths:
        return 0.14;
      case MarketHistoryRange.oneYear:
        return 0.28;
    }
  }

  double _volatilityForRange(MarketHistoryRange range) {
    switch (range) {
      case MarketHistoryRange.oneDay:
        return 0.003;
      case MarketHistoryRange.fiveDays:
        return 0.006;
      case MarketHistoryRange.oneMonth:
        return 0.009;
      case MarketHistoryRange.threeMonths:
        return 0.014;
      case MarketHistoryRange.oneYear:
        return 0.022;
    }
  }
}
