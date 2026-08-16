import 'dart:math' as math;

import '../../market/models/market_candle.dart';
import '../../market/models/market_snapshot.dart';
import 'stock_behavior_profile.dart';

class StockBehaviorProfileService {
  const StockBehaviorProfileService({
    this.atrPeriod = 14,
    this.volumeLookback = 20,
  });

  final int atrPeriod;
  final int volumeLookback;

  StockBehaviorProfile evaluate(MarketSnapshot snapshot) {
    final candles = snapshot.candles;

    if (candles.length < 3 || snapshot.currentPrice <= 0) {
      return const StockBehaviorProfile.unknown();
    }

    final averageVolume = _averageHistoricalVolume(candles);
    final relativeVolume = averageVolume <= 0
        ? 1.0
        : snapshot.currentVolume / averageVolume;

    final trueRanges = _trueRanges(candles);

    if (trueRanges.isEmpty) {
      return StockBehaviorProfile(
        behaviorType: StockBehaviorType.unknown,
        volatilityRegime: VolatilityRegime.unknown,
        averageVolume: averageVolume,
        relativeVolume: relativeVolume,
        atrPercent: 0,
        baselineAtrPercent: 0,
        volatilityRatio: 1,
        trendEfficiency: _trendEfficiency(candles),
        sampleSize: candles.length,
      );
    }

    final recentCount = math.min(atrPeriod, trueRanges.length);
    final recentRanges = trueRanges.sublist(trueRanges.length - recentCount);

    final recentAtr = _average(recentRanges);
    final baselineAtr = _average(trueRanges);

    final atrPercent = (recentAtr / snapshot.currentPrice) * 100;
    final baselineAtrPercent = (baselineAtr / snapshot.currentPrice) * 100;
    final volatilityRatio = baselineAtrPercent <= 0
        ? 1.0
        : atrPercent / baselineAtrPercent;

    return StockBehaviorProfile(
      behaviorType: _behaviorType(
        timeframe: snapshot.timeframe,
        baselineAtrPercent: baselineAtrPercent,
      ),
      volatilityRegime: _volatilityRegime(volatilityRatio),
      averageVolume: averageVolume,
      relativeVolume: relativeVolume,
      atrPercent: atrPercent,
      baselineAtrPercent: baselineAtrPercent,
      volatilityRatio: volatilityRatio,
      trendEfficiency: _trendEfficiency(candles),
      sampleSize: candles.length,
    );
  }

  double _averageHistoricalVolume(List<MarketCandle> candles) {
    final availableHistory = candles.length - 1;
    final count = math.min(volumeLookback, availableHistory);

    if (count <= 0) {
      return 0;
    }

    double total = 0;
    final start = candles.length - 1 - count;

    for (var index = start; index < candles.length - 1; index++) {
      total += candles[index].volume;
    }

    return total / count;
  }

  List<double> _trueRanges(List<MarketCandle> candles) {
    final result = <double>[];

    for (var index = 1; index < candles.length; index++) {
      final candle = candles[index];
      final previousClose = candles[index - 1].close;

      final highLow = candle.high - candle.low;
      final highPrevious = (candle.high - previousClose).abs();
      final lowPrevious = (candle.low - previousClose).abs();

      result.add(math.max(highLow, math.max(highPrevious, lowPrevious)));
    }

    return result;
  }

  double _trendEfficiency(List<MarketCandle> candles) {
    if (candles.length < 2) {
      return 0;
    }

    double pathDistance = 0;

    for (var index = 1; index < candles.length; index++) {
      pathDistance += (candles[index].close - candles[index - 1].close).abs();
    }

    if (pathDistance == 0) {
      return 0;
    }

    final netMovement = (candles.last.close - candles.first.close).abs();

    return (netMovement / pathDistance).clamp(0.0, 1.0);
  }

  double _average(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }

    final total = values.fold<double>(0, (sum, value) => sum + value);
    return total / values.length;
  }

  StockBehaviorType _behaviorType({
    required String timeframe,
    required double baselineAtrPercent,
  }) {
    final steadyThreshold = switch (timeframe) {
      '1m' => 0.30,
      '5m' => 0.65,
      '10m' => 0.85,
      '15m' => 1.00,
      '1h' => 1.80,
      '1d' => 3.00,
      _ => 1.00,
    };

    final volatileThreshold = steadyThreshold * 1.8;

    if (baselineAtrPercent <= steadyThreshold) {
      return StockBehaviorType.steady;
    }

    if (baselineAtrPercent < volatileThreshold) {
      return StockBehaviorType.balanced;
    }

    return StockBehaviorType.volatile;
  }

  VolatilityRegime _volatilityRegime(double volatilityRatio) {
    if (volatilityRatio < 0.80) {
      return VolatilityRegime.calm;
    }

    if (volatilityRatio <= 1.25) {
      return VolatilityRegime.normal;
    }

    return VolatilityRegime.elevated;
  }
}
