import 'dart:math' as math;

import '../../market/models/market_candle.dart';
import '../../market/models/market_snapshot.dart';
import '../models/evidence_result.dart';
import 'multi_timeframe_profile.dart';
import 'strategy_timeframe_plan.dart';

class MultiTimeframeProfileService {
  const MultiTimeframeProfileService();

  MultiTimeframeProfile evaluate({
    required MarketSnapshot primary,
    required MarketSnapshot confirmation,
    required MarketSnapshot regime,
    StrategyTimeframePlan plan = StrategyTimeframePlan.trader,
  }) {
    final primarySignal = _signal(
      snapshot: primary,
      role: TimeframeRole.primary,
    );
    final confirmationSignal = _signal(
      snapshot: confirmation,
      role: TimeframeRole.confirmation,
    );
    final regimeSignal = _signal(snapshot: regime, role: TimeframeRole.regime);

    final signals = [primarySignal, confirmationSignal, regimeSignal];

    if (signals.any((signal) => !signal.isAvailable)) {
      return MultiTimeframeProfile.unknown(plan: plan);
    }

    const roleWeights = <TimeframeRole, double>{
      TimeframeRole.primary: 0.45,
      TimeframeRole.confirmation: 0.35,
      TimeframeRole.regime: 0.20,
    };

    double weightedDirection = 0;
    double weightedEfficiency = 0;
    double totalWeight = 0;

    for (final signal in signals) {
      final weight = roleWeights[signal.role] ?? 0;
      final sign = _directionSign(signal.direction);
      weightedDirection += sign * signal.strengthScore * weight;
      weightedEfficiency += signal.trendEfficiency * weight;
      totalWeight += weight;
    }

    final directionScore = totalWeight == 0
        ? 0.0
        : (weightedDirection / totalWeight).clamp(-100.0, 100.0);

    final leadingDirection = directionScore > 5
        ? EvidenceDirection.bullish
        : directionScore < -5
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    double directionalWeight = 0;
    double supportingWeight = 0;

    for (final signal in signals) {
      if (signal.direction == EvidenceDirection.neutral) {
        continue;
      }

      final weight = roleWeights[signal.role] ?? 0;
      directionalWeight += weight;

      if (signal.direction == leadingDirection) {
        supportingWeight += weight;
      }
    }

    final agreement = directionalWeight == 0
        ? 0.5
        : (supportingWeight / directionalWeight).clamp(0.0, 1.0);

    final averageEfficiency = totalWeight == 0
        ? 0.0
        : (weightedEfficiency / totalWeight).clamp(0.0, 1.0);

    final reliability = (0.55 + (agreement * 0.25) + (averageEfficiency * 0.20))
        .clamp(0.45, 0.95);

    return MultiTimeframeProfile(
      plan: plan,
      primary: primarySignal,
      confirmation: confirmationSignal,
      regime: regimeSignal,
      alignment: _alignment(
        primary: primarySignal.direction,
        confirmation: confirmationSignal.direction,
        regime: regimeSignal.direction,
      ),
      directionScore: directionScore,
      agreement: agreement,
      reliability: reliability,
    );
  }

  TimeframeTrendSignal _signal({
    required MarketSnapshot snapshot,
    required TimeframeRole role,
  }) {
    final candles = snapshot.candles;

    if (candles.length < 3 || candles.first.close <= 0) {
      return TimeframeTrendSignal.unknown(
        role: role,
        timeframe: snapshot.timeframe,
      );
    }

    final movePercent =
        ((candles.last.close - candles.first.close) / candles.first.close) *
        100;
    final trendEfficiency = _trendEfficiency(candles);
    final averageRangePercent = _averageRangePercent(candles);
    final directionalThreshold = math.max(0.20, averageRangePercent * 1.35);
    final magnitudeRatio = movePercent.abs() / directionalThreshold;

    final direction = magnitudeRatio < 1
        ? EvidenceDirection.neutral
        : movePercent > 0
        ? EvidenceDirection.bullish
        : EvidenceDirection.bearish;

    final strengthScore = direction == EvidenceDirection.neutral
        ? (magnitudeRatio * 25).clamp(0.0, 25.0)
        : (35 + ((magnitudeRatio - 1) * 25)).clamp(35.0, 95.0);

    return TimeframeTrendSignal(
      role: role,
      timeframe: snapshot.timeframe,
      direction: direction,
      movePercent: movePercent,
      strengthScore: strengthScore,
      trendEfficiency: trendEfficiency,
      sampleSize: candles.length,
    );
  }

  double _trendEfficiency(List<MarketCandle> candles) {
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

  double _averageRangePercent(List<MarketCandle> candles) {
    double total = 0;
    var count = 0;

    for (final candle in candles) {
      if (candle.close <= 0) {
        continue;
      }

      total += ((candle.high - candle.low) / candle.close).abs() * 100;
      count++;
    }

    return count == 0 ? 0 : total / count;
  }

  double _directionSign(EvidenceDirection direction) {
    switch (direction) {
      case EvidenceDirection.bullish:
        return 1;
      case EvidenceDirection.bearish:
        return -1;
      case EvidenceDirection.neutral:
      case EvidenceDirection.unknown:
        return 0;
    }
  }

  TimeframeAlignment _alignment({
    required EvidenceDirection primary,
    required EvidenceDirection confirmation,
    required EvidenceDirection regime,
  }) {
    if (primary == EvidenceDirection.unknown ||
        confirmation == EvidenceDirection.unknown ||
        regime == EvidenceDirection.unknown) {
      return TimeframeAlignment.unknown;
    }

    if (primary != EvidenceDirection.neutral &&
        confirmation == primary &&
        regime == primary) {
      return TimeframeAlignment.aligned;
    }

    if (primary != EvidenceDirection.neutral &&
        confirmation != EvidenceDirection.neutral &&
        regime != EvidenceDirection.neutral &&
        confirmation != primary &&
        regime != primary) {
      return TimeframeAlignment.opposed;
    }

    return TimeframeAlignment.mixed;
  }
}
