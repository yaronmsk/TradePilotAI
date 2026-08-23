import 'dart:math' as math;

import '../../market/models/market_candle.dart';
import '../../market/models/market_snapshot.dart';
import '../models/evidence_result.dart';
import '../models/strategy_summary.dart';
import 'multi_timeframe_profile.dart';
import 'strategy_timeframe_plan.dart';
import 'strategy_timeframe_role_policy.dart';

class MultiTimeframeProfileService {
  const MultiTimeframeProfileService();

  MultiTimeframeProfile evaluate({
    required MarketSnapshot primary,
    required MarketSnapshot confirmation,
    required MarketSnapshot regime,
    StrategyTimeframePlan plan = StrategyTimeframePlan.trader,
    StrategyType strategy = StrategyType.trader,
    StrategyTimeframeRolePolicy? rolePolicy,
  }) {
    final resolvedPolicy =
        rolePolicy ?? StrategyTimeframeRolePolicy.forStrategy(strategy);

    if (resolvedPolicy.strategy != strategy) {
      throw ArgumentError(
        'The timeframe role policy must belong to the requested strategy.',
      );
    }

    if (!resolvedPolicy.implementationReady) {
      return MultiTimeframeProfile.unknown(plan: plan);
    }

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

    final directionScore = resolvedPolicy.primaryAnchorsDirection
        ? _primaryAnchoredDirectionScore(
            signals: signals,
            policy: resolvedPolicy,
          )
        : _weightedConsensusDirectionScore(
            signals: signals,
            policy: resolvedPolicy,
          );

    final leadingDirection = directionScore > 5
        ? EvidenceDirection.bullish
        : directionScore < -5
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    final agreement = resolvedPolicy.primaryAnchorsDirection
        ? _primaryAnchoredAgreement(
            primary: primarySignal,
            confirmation: confirmationSignal,
            regime: regimeSignal,
            policy: resolvedPolicy,
          )
        : _weightedConsensusAgreement(
            signals: signals,
            leadingDirection: leadingDirection,
            policy: resolvedPolicy,
          );

    final averageEfficiency = _weightedEfficiency(
      signals: signals,
      policy: resolvedPolicy,
    );

    // Preserve the existing reliability model. Strategy-specific agreement
    // semantics change what "agreement" means, but the reliability envelope
    // remains stable and bounded.
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

  double _weightedConsensusDirectionScore({
    required List<TimeframeTrendSignal> signals,
    required StrategyTimeframeRolePolicy policy,
  }) {
    double weightedDirection = 0;
    double totalWeight = 0;

    for (final signal in signals) {
      final weight = policy.directionWeightFor(signal.role);
      final sign = _directionSign(signal.direction);

      weightedDirection += sign * signal.strengthScore * weight;
      totalWeight += weight;
    }

    return totalWeight == 0
        ? 0
        : (weightedDirection / totalWeight).clamp(-100.0, 100.0);
  }

  double _primaryAnchoredDirectionScore({
    required List<TimeframeTrendSignal> signals,
    required StrategyTimeframeRolePolicy policy,
  }) {
    final primary = signals.firstWhere(
      (signal) => signal.role == TimeframeRole.primary,
    );

    final primarySign = _directionSign(primary.direction);

    if (primarySign == 0) {
      return 0;
    }

    double supportingMagnitude = 0;
    double opposingMagnitude = 0;

    for (final signal in signals) {
      final weight = policy.directionWeightFor(signal.role);

      if (signal.role == TimeframeRole.primary ||
          signal.direction == primary.direction) {
        supportingMagnitude += signal.strengthScore * weight;
        continue;
      }

      if (signal.direction == EvidenceDirection.neutral ||
          signal.direction == EvidenceDirection.unknown) {
        continue;
      }

      opposingMagnitude += signal.strengthScore * weight;
    }

    final totalWeight = policy.totalDirectionWeight;

    if (totalWeight <= 0) {
      return 0;
    }

    // Higher timeframes may reduce the strength of the active setup all the
    // way to neutral, but cannot independently reverse the primary direction.
    final magnitude = ((supportingMagnitude - opposingMagnitude) / totalWeight)
        .clamp(0.0, 100.0);

    return primarySign * magnitude;
  }

  double _weightedConsensusAgreement({
    required List<TimeframeTrendSignal> signals,
    required EvidenceDirection leadingDirection,
    required StrategyTimeframeRolePolicy policy,
  }) {
    double directionalWeight = 0;
    double supportingWeight = 0;

    for (final signal in signals) {
      if (signal.direction == EvidenceDirection.neutral) {
        continue;
      }

      final weight = policy.agreementWeightFor(signal.role);
      directionalWeight += weight;

      if (signal.direction == leadingDirection) {
        supportingWeight += weight;
      }
    }

    return directionalWeight == 0
        ? 0.5
        : (supportingWeight / directionalWeight).clamp(0.0, 1.0);
  }

  double _primaryAnchoredAgreement({
    required TimeframeTrendSignal primary,
    required TimeframeTrendSignal confirmation,
    required TimeframeTrendSignal regime,
    required StrategyTimeframeRolePolicy policy,
  }) {
    if (primary.direction == EvidenceDirection.neutral ||
        primary.direction == EvidenceDirection.unknown) {
      return 0.5;
    }

    final broaderSignals = [confirmation, regime];

    double totalWeight = 0;
    double confirmationScore = 0;

    for (final signal in broaderSignals) {
      final weight = policy.agreementWeightFor(signal.role);

      if (weight <= 0) {
        continue;
      }

      totalWeight += weight;

      if (signal.direction == primary.direction) {
        confirmationScore += weight;
      } else if (signal.direction == EvidenceDirection.neutral) {
        // Neutral broader trend is partial confirmation rather than direct
        // opposition.
        confirmationScore += weight * 0.5;
      }
    }

    return totalWeight == 0
        ? 0.5
        : (confirmationScore / totalWeight).clamp(0.0, 1.0);
  }

  double _weightedEfficiency({
    required List<TimeframeTrendSignal> signals,
    required StrategyTimeframeRolePolicy policy,
  }) {
    double weightedEfficiency = 0;
    double totalWeight = 0;

    for (final signal in signals) {
      final weight = policy.directionWeightFor(signal.role);

      weightedEfficiency += signal.trendEfficiency * weight;
      totalWeight += weight;
    }

    return totalWeight == 0
        ? 0
        : (weightedEfficiency / totalWeight).clamp(0.0, 1.0);
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
    return switch (direction) {
      EvidenceDirection.bullish => 1,
      EvidenceDirection.bearish => -1,
      EvidenceDirection.neutral => 0,
      EvidenceDirection.unknown => 0,
    };
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
