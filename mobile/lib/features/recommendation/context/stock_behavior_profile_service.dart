import 'dart:math' as math;

import '../../market/models/market_candle.dart';
import '../../market/models/market_snapshot.dart';
import 'historical_stock_profile.dart';
import 'historical_stock_profile_service.dart';
import 'stock_behavior_profile.dart';

class StockBehaviorProfileService {
  const StockBehaviorProfileService({
    this.atrPeriod = 14,
    this.volumeLookback = 20,
    this.historicalStockProfileService = const HistoricalStockProfileService(),
  });

  final int atrPeriod;
  final int volumeLookback;
  final HistoricalStockProfileService historicalStockProfileService;

  StockBehaviorProfile evaluate(
    MarketSnapshot snapshot, {
    List<MarketCandle> historicalDailyCandles = const [],
  }) {
    final candles = snapshot.candles;

    if (candles.isEmpty || snapshot.currentPrice <= 0) {
      return const StockBehaviorProfile.unknown();
    }

    final averageVolume = _averageHistoricalVolume(candles);
    final relativeVolume = averageVolume <= 0
        ? 1.0
        : snapshot.currentVolume / averageVolume;

    final trueRanges = _trueRanges(candles);
    final trendEfficiency = _trendEfficiency(candles);

    double atrPercent = 0;
    double baselineAtrPercent = 0;
    double volatilityRatio = 1;

    if (trueRanges.isNotEmpty) {
      final recentCount = math.min(atrPeriod, trueRanges.length);
      final recentRanges = trueRanges.sublist(trueRanges.length - recentCount);

      final recentAtr = _average(recentRanges);
      final baselineAtr = _average(trueRanges);

      atrPercent = (recentAtr / snapshot.currentPrice) * 100;
      baselineAtrPercent = (baselineAtr / snapshot.currentPrice) * 100;
      volatilityRatio = baselineAtrPercent <= 0
          ? 1.0
          : atrPercent / baselineAtrPercent;
    }

    final historicalProfile = historicalStockProfileService.evaluate(
      historicalDailyCandles,
    );

    if (historicalProfile.hasSufficientData) {
      return _buildHistoricalProfile(
        snapshot: snapshot,
        historicalProfile: historicalProfile,
        averageVolume: averageVolume,
        relativeVolume: relativeVolume,
        atrPercent: atrPercent,
        baselineAtrPercent: baselineAtrPercent,
        volatilityRatio: volatilityRatio,
        trendEfficiency: trendEfficiency,
      );
    }

    if (candles.length < 3) {
      return const StockBehaviorProfile.unknown();
    }

    return StockBehaviorProfile(
      behaviorType: _snapshotBehaviorType(
        timeframe: snapshot.timeframe,
        baselineAtrPercent: baselineAtrPercent,
      ),
      volatilityRegime: _snapshotVolatilityRegime(volatilityRatio),
      averageVolume: averageVolume,
      relativeVolume: relativeVolume,
      atrPercent: atrPercent,
      baselineAtrPercent: baselineAtrPercent,
      volatilityRatio: volatilityRatio,
      trendEfficiency: trendEfficiency,
      sampleSize: candles.length,
    );
  }

  StockBehaviorProfile _buildHistoricalProfile({
    required MarketSnapshot snapshot,
    required HistoricalStockProfile historicalProfile,
    required double averageVolume,
    required double relativeVolume,
    required double atrPercent,
    required double baselineAtrPercent,
    required double volatilityRatio,
    required double trendEfficiency,
  }) {
    return StockBehaviorProfile(
      behaviorType: _historicalBehaviorType(historicalProfile),
      volatilityRegime: _historicalVolatilityRegime(historicalProfile),
      averageVolume: averageVolume,
      relativeVolume: relativeVolume,
      atrPercent: atrPercent,
      baselineAtrPercent: baselineAtrPercent,
      volatilityRatio: volatilityRatio,
      trendEfficiency: trendEfficiency,
      sampleSize: snapshot.candles.length,
      baselineSource: StockBaselineSource.oneYearDailyHistory,
      historicalSampleSize: historicalProfile.sampleSize,
      typicalDailyAtrPercent: historicalProfile.typicalAtrPercent,
      recentRealizedVolatilityPercent:
          historicalProfile.recentRealizedVolatilityPercent,
      typicalRealizedVolatilityPercent:
          historicalProfile.typicalRealizedVolatilityPercent,
      volatilityPercentile: historicalProfile.volatilityPercentile,
      averageDailyVolume20: historicalProfile.averageDailyVolume20,
      averageDailyVolume60: historicalProfile.averageDailyVolume60,
      volumeTrendRatio: historicalProfile.volumeTrendRatio,
      volumeVariability: historicalProfile.volumeVariability,
      historicalTrendEfficiency20: historicalProfile.trendEfficiency20,
      historicalTrendEfficiency60: historicalProfile.trendEfficiency60,
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

  StockBehaviorType _snapshotBehaviorType({
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

  VolatilityRegime _snapshotVolatilityRegime(double volatilityRatio) {
    if (volatilityRatio < 0.80) {
      return VolatilityRegime.calm;
    }

    if (volatilityRatio <= 1.25) {
      return VolatilityRegime.normal;
    }

    return VolatilityRegime.elevated;
  }

  StockBehaviorType _historicalBehaviorType(
    HistoricalStockProfile historicalProfile,
  ) {
    final atr = historicalProfile.typicalAtrPercent;
    final realizedVolatility =
        historicalProfile.typicalRealizedVolatilityPercent;

    if (atr <= 1.80 && realizedVolatility <= 30) {
      return StockBehaviorType.steady;
    }

    if (atr >= 3.00 || realizedVolatility >= 50) {
      return StockBehaviorType.volatile;
    }

    return StockBehaviorType.balanced;
  }

  VolatilityRegime _historicalVolatilityRegime(
    HistoricalStockProfile historicalProfile,
  ) {
    final percentile = historicalProfile.volatilityPercentile;

    if (percentile <= 25) {
      return VolatilityRegime.calm;
    }

    if (percentile >= 75) {
      return VolatilityRegime.elevated;
    }

    return VolatilityRegime.normal;
  }
}
