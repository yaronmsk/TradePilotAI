import '../../market/models/market_candle.dart';

class TechnicalIndicatorMath {
  const TechnicalIndicatorMath._();

  static double average(Iterable<double> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) {
      return 0;
    }
    return list.reduce((a, b) => a + b) / list.length;
  }

  static List<double> emaSeries(List<double> values, int period) {
    if (values.isEmpty || period <= 0) {
      return const [];
    }

    final multiplier = 2 / (period + 1);
    final result = <double>[values.first];

    for (var index = 1; index < values.length; index++) {
      final next = ((values[index] - result.last) * multiplier) + result.last;
      result.add(next);
    }

    return List<double>.unmodifiable(result);
  }

  static double ema(List<double> values, int period) {
    final series = emaSeries(values, period);
    return series.isEmpty ? 0 : series.last;
  }

  static double atr(List<MarketCandle> candles, {int period = 14}) {
    if (candles.length < 2 || period <= 0) {
      return 0;
    }

    final start = (candles.length - period)
        .clamp(1, candles.length - 1)
        .toInt();
    final ranges = <double>[];

    for (var index = start; index < candles.length; index++) {
      final candle = candles[index];
      final previousClose = candles[index - 1].close;
      final highLow = candle.high - candle.low;
      final highPrevious = (candle.high - previousClose).abs();
      final lowPrevious = (candle.low - previousClose).abs();
      ranges.add(
        [
          highLow,
          highPrevious,
          lowPrevious,
        ].reduce((value, candidate) => candidate > value ? candidate : value),
      );
    }

    return average(ranges);
  }

  static double windowVwap(List<MarketCandle> candles) {
    double weightedPrice = 0;
    double totalVolume = 0;

    for (final candle in candles) {
      if (candle.volume <= 0) {
        continue;
      }
      final typicalPrice = (candle.high + candle.low + candle.close) / 3;
      weightedPrice += typicalPrice * candle.volume;
      totalVolume += candle.volume;
    }

    return totalVolume <= 0 ? 0 : weightedPrice / totalVolume;
  }
}
