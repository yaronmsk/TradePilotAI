import 'dart:math' as math;

import '../../market/models/market_snapshot.dart';
import '../models/strategy_summary.dart';
import '../strategy/market_context_strategy_policy.dart';
import 'market_context_profile.dart';
import 'market_context_target.dart';
import 'strategy_timeframe_plan.dart';

class MarketContextProfileService {
  const MarketContextProfileService();

  MarketContextProfile evaluate({
    required MarketContextTarget target,
    required MarketSnapshot stockConfirmation,
    required MarketSnapshot stockRegime,
    required MarketSnapshot marketConfirmation,
    required MarketSnapshot marketRegime,
    required MarketSnapshot sectorConfirmation,
    required MarketSnapshot sectorRegime,
    StrategyType strategy = StrategyType.trader,
    StrategyTimeframePlan? plan,
  }) {
    final policy = MarketContextStrategyPolicy.forStrategy(strategy);

    if (policy == null) {
      return MarketContextProfile.unknown(target: target);
    }

    final confirmationSnapshots = [
      stockConfirmation,
      marketConfirmation,
      sectorConfirmation,
    ];

    final regimeSnapshots = [stockRegime, marketRegime, sectorRegime];

    if (confirmationSnapshots.any(
          (snapshot) =>
              snapshot.candles.length < policy.minimumConfirmationCandles,
        ) ||
        regimeSnapshots.any(
          (snapshot) => snapshot.candles.length < policy.minimumRegimeCandles,
        )) {
      return MarketContextProfile.unknown(target: target);
    }

    if (plan != null &&
        !_matchesPlan(
          plan: plan,
          stockConfirmation: stockConfirmation,
          stockRegime: stockRegime,
          marketConfirmation: marketConfirmation,
          marketRegime: marketRegime,
          sectorConfirmation: sectorConfirmation,
          sectorRegime: sectorRegime,
        )) {
      return MarketContextProfile.unknown(target: target);
    }

    final stockConfirmationReturn = _performance(stockConfirmation);
    final stockRegimeReturn = _performance(stockRegime);
    final marketConfirmationReturn = _performance(marketConfirmation);
    final marketRegimeReturn = _performance(marketRegime);
    final sectorConfirmationReturn = _performance(sectorConfirmation);
    final sectorRegimeReturn = _performance(sectorRegime);

    final stockVsMarketPercent =
        ((stockConfirmationReturn - marketConfirmationReturn) *
            policy.confirmationWeight) +
        ((stockRegimeReturn - marketRegimeReturn) * policy.regimeWeight);

    final stockVsSectorPercent = target.hasSectorBenchmark
        ? ((stockConfirmationReturn - sectorConfirmationReturn) *
                  policy.confirmationWeight) +
              ((stockRegimeReturn - sectorRegimeReturn) * policy.regimeWeight)
        : stockVsMarketPercent;

    final sectorVsMarketPercent = target.hasSectorBenchmark
        ? ((sectorConfirmationReturn - marketConfirmationReturn) *
                  policy.confirmationWeight) +
              ((sectorRegimeReturn - marketRegimeReturn) * policy.regimeWeight)
        : 0.0;

    final stockVsMarketScore =
        (_normalizedDifference(
              stockConfirmationReturn - marketConfirmationReturn,
              stockConfirmation,
              marketConfirmation,
            ) *
            0.55) +
        (_normalizedDifference(
              stockRegimeReturn - marketRegimeReturn,
              stockRegime,
              marketRegime,
            ) *
            0.45);

    final stockVsSectorScore = target.hasSectorBenchmark
        ? (_normalizedDifference(
                    stockConfirmationReturn - sectorConfirmationReturn,
                    stockConfirmation,
                    sectorConfirmation,
                  ) *
                  0.55) +
              (_normalizedDifference(
                    stockRegimeReturn - sectorRegimeReturn,
                    stockRegime,
                    sectorRegime,
                  ) *
                  0.45)
        : stockVsMarketScore;

    final sectorVsMarketScore = target.hasSectorBenchmark
        ? (_normalizedDifference(
                    sectorConfirmationReturn - marketConfirmationReturn,
                    sectorConfirmation,
                    marketConfirmation,
                  ) *
                  0.55) +
              (_normalizedDifference(
                    sectorRegimeReturn - marketRegimeReturn,
                    sectorRegime,
                    marketRegime,
                  ) *
                  0.45)
        : 0.0;

    final marketTrendScore =
        (_normalizedReturn(marketConfirmationReturn, marketConfirmation) *
            0.55) +
        (_normalizedReturn(marketRegimeReturn, marketRegime) *
            policy.regimeWeight);

    final sectorTrendScore = target.hasSectorBenchmark
        ? (_normalizedReturn(sectorConfirmationReturn, sectorConfirmation) *
                  0.55) +
              (_normalizedReturn(sectorRegimeReturn, sectorRegime) *
                  policy.regimeWeight)
        : marketTrendScore;

    final directionScore =
        (target.hasSectorBenchmark || policy.preserveMissingSectorDuplication)
        ? ((stockVsMarketScore * 0.45) +
                  (stockVsSectorScore * 0.35) +
                  (sectorVsMarketScore * 0.10) +
                  (marketTrendScore * 0.10))
              .clamp(-100.0, 100.0)
        : ((stockVsMarketScore * 0.80) + (marketTrendScore * 0.20)).clamp(
            -100.0,
            100.0,
          );

    final backdropScore =
        ((marketTrendScore * 0.55) + (sectorTrendScore * 0.45)).clamp(
          -100.0,
          100.0,
        );

    final relativeStrengthScore =
        ((stockVsMarketScore * 0.55) + (stockVsSectorScore * 0.45)).clamp(
          -100.0,
          100.0,
        );

    final confirmationRelative =
        stockConfirmationReturn - marketConfirmationReturn;
    final regimeRelative = stockRegimeReturn - marketRegimeReturn;
    final relativeAgreement = confirmationRelative == 0 || regimeRelative == 0
        ? 0.5
        : confirmationRelative.sign == regimeRelative.sign
        ? 1.0
        : 0.35;

    final reliability =
        (policy.reliabilityBase +
                (target.hasSectorBenchmark
                    ? policy.sectorReliabilityBonus
                    : 0) +
                (relativeAgreement * policy.agreementReliabilityBonus))
            .clamp(0.60, 0.95);

    return MarketContextProfile(
      target: target,
      backdrop: _backdrop(backdropScore),
      relativeStrength: _relativeStrength(relativeStrengthScore),
      directionScore: directionScore,
      reliability: reliability,
      stockVsMarketPercent: stockVsMarketPercent,
      stockVsSectorPercent: stockVsSectorPercent,
      sectorVsMarketPercent: sectorVsMarketPercent,
      marketCompositeReturnPercent:
          (marketConfirmationReturn * policy.confirmationWeight) +
          (marketRegimeReturn * policy.regimeWeight),
      sectorCompositeReturnPercent:
          (sectorConfirmationReturn * policy.confirmationWeight) +
          (sectorRegimeReturn * policy.regimeWeight),
    );
  }

  bool _matchesPlan({
    required StrategyTimeframePlan plan,
    required MarketSnapshot stockConfirmation,
    required MarketSnapshot stockRegime,
    required MarketSnapshot marketConfirmation,
    required MarketSnapshot marketRegime,
    required MarketSnapshot sectorConfirmation,
    required MarketSnapshot sectorRegime,
  }) {
    return stockConfirmation.timeframe == plan.confirmationTimeframe &&
        marketConfirmation.timeframe == plan.confirmationTimeframe &&
        sectorConfirmation.timeframe == plan.confirmationTimeframe &&
        stockRegime.timeframe == plan.regimeTimeframe &&
        marketRegime.timeframe == plan.regimeTimeframe &&
        sectorRegime.timeframe == plan.regimeTimeframe;
  }

  double _performance(MarketSnapshot snapshot) {
    final first = snapshot.candles.first.close;
    final last = snapshot.candles.last.close;

    if (first <= 0) {
      return 0;
    }

    return ((last - first) / first) * 100;
  }

  double _normalizedDifference(
    double difference,
    MarketSnapshot first,
    MarketSnapshot second,
  ) {
    final scale = math.max(
      0.75,
      ((_windowScale(first) + _windowScale(second)) / 2),
    );

    return ((difference / scale) * 100).clamp(-100.0, 100.0);
  }

  double _normalizedReturn(double value, MarketSnapshot snapshot) {
    final scale = math.max(0.75, _windowScale(snapshot));
    return ((value / scale) * 100).clamp(-100.0, 100.0);
  }

  double _windowScale(MarketSnapshot snapshot) {
    double totalRangePercent = 0;
    var count = 0;

    for (final candle in snapshot.candles) {
      if (candle.close <= 0) {
        continue;
      }

      totalRangePercent +=
          ((candle.high - candle.low) / candle.close).abs() * 100;
      count++;
    }

    if (count == 0) {
      return 1;
    }

    final averageRangePercent = totalRangePercent / count;
    return averageRangePercent * math.sqrt(count) * 1.6;
  }

  MarketBackdrop _backdrop(double score) {
    if (score >= 20) {
      return MarketBackdrop.supportive;
    }

    if (score <= -20) {
      return MarketBackdrop.challenging;
    }

    return MarketBackdrop.neutral;
  }

  RelativeStrengthState _relativeStrength(double score) {
    if (score >= 20) {
      return RelativeStrengthState.outperforming;
    }

    if (score <= -20) {
      return RelativeStrengthState.underperforming;
    }

    return RelativeStrengthState.inLine;
  }
}
