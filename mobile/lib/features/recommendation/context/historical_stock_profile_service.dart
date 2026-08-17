import 'dart:math' as math;

import '../../market/models/market_candle.dart';
import 'historical_stock_profile.dart';

class HistoricalStockProfileService {
  const HistoricalStockProfileService({
    this.atrPeriod = 14,
    this.realizedVolatilityPeriod = 20,
  });

  final int atrPeriod;
  final int realizedVolatilityPeriod;

  HistoricalStockProfile evaluate(List<MarketCandle> candles) {
    if (candles.length < 3) {
      return HistoricalStockProfile.unknown(sampleSize: candles.length);
    }

    final validCandles = candles
        .where(
          (candle) =>
              candle.close > 0 &&
              candle.high >= candle.low &&
              candle.volume >= 0,
        )
        .toList(growable: false);

    if (validCandles.length < 3) {
      return HistoricalStockProfile.unknown(sampleSize: validCandles.length);
    }

    final atrSeries = _rollingAtrPercentSeries(validCandles);
    final volatilitySeries = _rollingRealizedVolatilitySeries(validCandles);

    final recentAtrPercent = atrSeries.isEmpty ? 0.0 : atrSeries.last;
    final typicalAtrPercent = _median(atrSeries);
    final atrPercentile = _percentileRank(atrSeries, recentAtrPercent);

    final recentRealizedVolatilityPercent = volatilitySeries.isEmpty
        ? 0.0
        : volatilitySeries.last;
    final typicalRealizedVolatilityPercent = _median(volatilitySeries);
    final volatilityPercentile = _percentileRank(
      volatilitySeries,
      recentRealizedVolatilityPercent,
    );

    final volume20 = _averageRecentVolume(validCandles, 20);
    final volume60 = _averageRecentVolume(validCandles, 60);
    final volumeTrendRatio = volume60 <= 0 ? 1.0 : volume20 / volume60;
    final volumeVariability = _volumeCoefficientOfVariation(validCandles, 60);

    return HistoricalStockProfile(
      sampleSize: validCandles.length,
      recentAtrPercent: recentAtrPercent,
      typicalAtrPercent: typicalAtrPercent,
      atrPercentile: atrPercentile,
      recentRealizedVolatilityPercent: recentRealizedVolatilityPercent,
      typicalRealizedVolatilityPercent: typicalRealizedVolatilityPercent,
      volatilityPercentile: volatilityPercentile,
      averageDailyVolume20: volume20,
      averageDailyVolume60: volume60,
      volumeTrendRatio: volumeTrendRatio,
      volumeVariability: volumeVariability,
      trendEfficiency20: _trendEfficiency(validCandles, 20),
      trendEfficiency60: _trendEfficiency(validCandles, 60),
    );
  }

  List<double> _rollingAtrPercentSeries(List<MarketCandle> candles) {
    if (candles.length <= atrPeriod) {
      return const [];
    }

    final trueRanges = <double>[];

    for (var index = 1; index < candles.length; index++) {
      final candle = candles[index];
      final previousClose = candles[index - 1].close;

      final highLow = candle.high - candle.low;
      final highPrevious = (candle.high - previousClose).abs();
      final lowPrevious = (candle.low - previousClose).abs();

      trueRanges.add(math.max(highLow, math.max(highPrevious, lowPrevious)));
    }

    if (trueRanges.length < atrPeriod) {
      return const [];
    }

    final result = <double>[];

    for (var end = atrPeriod - 1; end < trueRanges.length; end++) {
      final start = end - atrPeriod + 1;
      var total = 0.0;

      for (var index = start; index <= end; index++) {
        total += trueRanges[index];
      }

      final atr = total / atrPeriod;
      final close = candles[end + 1].close;

      if (close > 0) {
        result.add((atr / close) * 100);
      }
    }

    return result;
  }

  List<double> _rollingRealizedVolatilitySeries(List<MarketCandle> candles) {
    if (candles.length <= realizedVolatilityPeriod) {
      return const [];
    }

    final returns = <double>[];

    for (var index = 1; index < candles.length; index++) {
      final previousClose = candles[index - 1].close;
      final currentClose = candles[index].close;

      if (previousClose <= 0 || currentClose <= 0) {
        continue;
      }

      returns.add(math.log(currentClose / previousClose));
    }

    if (returns.length < realizedVolatilityPeriod) {
      return const [];
    }

    final result = <double>[];

    for (var end = realizedVolatilityPeriod - 1; end < returns.length; end++) {
      final start = end - realizedVolatilityPeriod + 1;
      final window = returns.sublist(start, end + 1);
      final standardDeviation = _standardDeviation(window);

      result.add(standardDeviation * math.sqrt(252) * 100);
    }

    return result;
  }

  double _averageRecentVolume(List<MarketCandle> candles, int period) {
    final count = math.min(period, candles.length);

    if (count == 0) {
      return 0;
    }

    var total = 0.0;
    final start = candles.length - count;

    for (var index = start; index < candles.length; index++) {
      total += candles[index].volume;
    }

    return total / count;
  }

  double _volumeCoefficientOfVariation(List<MarketCandle> candles, int period) {
    final count = math.min(period, candles.length);

    if (count < 2) {
      return 0;
    }

    final values = candles
        .sublist(candles.length - count)
        .map((candle) => candle.volume)
        .toList(growable: false);

    final average = _average(values);

    if (average <= 0) {
      return 0;
    }

    return _standardDeviation(values) / average;
  }

  double _trendEfficiency(List<MarketCandle> candles, int period) {
    final count = math.min(period, candles.length);

    if (count < 2) {
      return 0;
    }

    final recent = candles.sublist(candles.length - count);
    var pathDistance = 0.0;

    for (var index = 1; index < recent.length; index++) {
      pathDistance += (recent[index].close - recent[index - 1].close).abs();
    }

    if (pathDistance == 0) {
      return 0;
    }

    final netMovement = (recent.last.close - recent.first.close).abs();

    return (netMovement / pathDistance).clamp(0.0, 1.0);
  }

  double _percentileRank(List<double> values, double currentValue) {
    if (values.isEmpty) {
      return 50;
    }

    var belowOrEqual = 0;

    for (final value in values) {
      if (value <= currentValue) {
        belowOrEqual++;
      }
    }

    return ((belowOrEqual / values.length) * 100).clamp(0.0, 100.0);
  }

  double _median(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }

    final sorted = List<double>.from(values)..sort();
    final middle = sorted.length ~/ 2;

    if (sorted.length.isOdd) {
      return sorted[middle];
    }

    return (sorted[middle - 1] + sorted[middle]) / 2;
  }

  double _average(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }

    final total = values.fold<double>(0, (sum, value) => sum + value);
    return total / values.length;
  }

  double _standardDeviation(List<double> values) {
    if (values.length < 2) {
      return 0;
    }

    final average = _average(values);
    var squaredDifferenceTotal = 0.0;

    for (final value in values) {
      final difference = value - average;
      squaredDifferenceTotal += difference * difference;
    }

    return math.sqrt(squaredDifferenceTotal / values.length);
  }
}
