import 'dart:math' as math;

import '../../market/models/market_candle.dart';
import '../../market/models/market_snapshot.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';
import '../models/strategy_summary.dart';
import '../strategy/relative_volume_strategy_policy.dart';
import 'evidence_provider.dart';

class RelativeVolumeEvidenceProvider implements StrategyAwareEvidenceProvider {
  const RelativeVolumeEvidenceProvider({this.lookback = 20});

  final int lookback;

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    kind: EvidenceKind.relativeVolume,
    family: EvidenceFamily.participation,
    name: 'Relative Volume',
    description:
        'Compares the current trading volume with the stock\'s recent average volume.',
    whyItMatters:
        'Price moves accompanied by unusually high volume can carry more information than moves occurring on normal or weak participation.',
    calculation:
        'Current candle volume divided by an appropriate historical volume baseline. Trader preserves the recent-candle calculation. Swing daily analysis compares daily volume with prior daily candles, while 4H Swing requires comparable session-position history before RVOL is allowed to participate.',
  );

  @override
  String get name => kDefinition.name;

  @override
  EvidenceDefinition get definition => kDefinition;

  @override
  EvidenceResult evaluate(MarketSnapshot snapshot) {
    final candles = snapshot.candles;

    if (lookback <= 0) {
      return _errorResult('Volume lookback must be greater than zero.');
    }

    if (candles.length < 3) {
      return EvidenceResult(
        providerName: name,
        definition: definition,
        status: EvidenceStatus.insufficientData,
        direction: EvidenceDirection.unknown,
        strength: EvidenceStrength.veryWeak,
        score: 0,
        baseWeight: 0.90,
        dynamicWeight: 1,
        reliability: 0,
        currentValue: 'Not available',
        baselineValue: 'Recent average volume',
        relativeValue: 'Not available',
        explanation:
            'There is not enough volume history to compare current trading activity with a meaningful baseline.',
        unavailableReason: 'At least three candles are required.',
      );
    }

    final sampleCount = math.min(lookback, candles.length - 1);
    final startIndex = candles.length - 1 - sampleCount;

    double totalVolume = 0;

    for (var index = startIndex; index < candles.length - 1; index++) {
      final volume = candles[index].volume;

      if (volume < 0) {
        return _errorResult('Volume cannot be negative.');
      }

      totalVolume += volume;
    }

    final averageVolume = totalVolume / sampleCount;

    if (averageVolume <= 0) {
      return _errorResult(
        'Average historical volume must be greater than zero.',
      );
    }

    final currentVolume = snapshot.currentVolume;

    if (currentVolume < 0) {
      return _errorResult('Current volume cannot be negative.');
    }

    final ratio = currentVolume / averageVolume;
    final latestCandle = candles.last;
    final direction = _directionForLatestCandle(latestCandle);
    final reliability =
        (0.55 + ((sampleCount / lookback).clamp(0.0, 1.0) * 0.40)).clamp(
          0.55,
          0.95,
        );

    if (ratio >= 2) {
      return _availableResult(
        ratio: ratio,
        averageVolume: averageVolume,
        currentVolume: currentVolume,
        direction: direction,
        strength: EvidenceStrength.exceptional,
        score: 95,
        reliability: reliability,
        explanation:
            'Trading activity is exceptionally high relative to the recent baseline and materially strengthens the significance of the latest price move.',
      );
    }

    if (ratio >= 1.5) {
      return _availableResult(
        ratio: ratio,
        averageVolume: averageVolume,
        currentVolume: currentVolume,
        direction: direction,
        strength: EvidenceStrength.strong,
        score: 80,
        reliability: reliability,
        explanation:
            'Trading activity is materially above average and provides meaningful confirmation for the latest price move.',
      );
    }

    if (ratio >= 1.2) {
      return _availableResult(
        ratio: ratio,
        averageVolume: averageVolume,
        currentVolume: currentVolume,
        direction: direction,
        strength: EvidenceStrength.moderate,
        score: 65,
        reliability: reliability,
        explanation:
            'Trading activity is moderately above average and adds some confirmation to the latest price move.',
      );
    }

    if (ratio <= 0.7) {
      return _availableResult(
        ratio: ratio,
        averageVolume: averageVolume,
        currentVolume: currentVolume,
        direction: EvidenceDirection.neutral,
        strength: EvidenceStrength.weak,
        score: 35,
        reliability: reliability,
        explanation:
            'Trading activity is unusually light, so the latest price move has weaker participation and should receive less conviction.',
      );
    }

    return _availableResult(
      ratio: ratio,
      averageVolume: averageVolume,
      currentVolume: currentVolume,
      direction: EvidenceDirection.neutral,
      strength: EvidenceStrength.moderate,
      score: 50,
      reliability: reliability,
      explanation:
          'Trading activity is close to its recent average and does not provide unusually strong confirmation in either direction.',
    );
  }

  @override
  EvidenceResult evaluateForStrategy(
    MarketSnapshot snapshot, {
    required StrategyType strategy,
  }) {
    return switch (strategy) {
      StrategyType.trader => evaluate(snapshot),
      StrategyType.swing => _evaluateSwing(snapshot),
      StrategyType.investor => _strategyUnavailable(
        'Relative Volume has not been calibrated for Investor yet.',
      ),
    };
  }

  EvidenceResult _evaluateSwing(MarketSnapshot snapshot) {
    final policy = RelativeVolumeStrategyPolicy.forStrategy(
      strategy: StrategyType.swing,
      timeframe: snapshot.timeframe,
    );

    if (policy == null) {
      return _strategyUnavailable(
        'Swing Relative Volume supports only the approved 1D and 4H primary intervals.',
      );
    }

    if (policy.requiresComparableSessionPositionHistory) {
      return _strategyUnavailable(
        '4H Swing Relative Volume requires historical 4-hour candles from '
        'the same session position across prior trading sessions. '
        'Ordinary sequential 4H candles are not a valid baseline because '
        'intraday volume naturally changes through the trading day.',
      );
    }

    return _evaluateSwingDaily(snapshot, policy);
  }

  EvidenceResult _evaluateSwingDaily(
    MarketSnapshot snapshot,
    RelativeVolumeStrategyPolicy policy,
  ) {
    final candles = snapshot.candles;

    if (candles.length < policy.minimumHistoricalCandles + 1) {
      return EvidenceResult(
        providerName: name,
        definition: definition,
        status: EvidenceStatus.insufficientData,
        direction: EvidenceDirection.unknown,
        strength: EvidenceStrength.veryWeak,
        score: 0,
        baseWeight: 0.90,
        dynamicWeight: 1,
        reliability: 0,
        currentValue: 'Not available',
        baselineValue: 'Historical daily volume baseline',
        relativeValue: 'Not available',
        explanation:
            'There is not enough completed daily volume history to establish '
            'a reliable Swing Relative Volume baseline.',
        unavailableReason:
            'At least ${policy.minimumHistoricalCandles} prior daily candles '
            'are required.',
      );
    }

    final sampleCount = math.min(policy.lookback, candles.length - 1);

    double totalVolume = 0;

    for (
      var index = candles.length - 1 - sampleCount;
      index < candles.length - 1;
      index++
    ) {
      final volume = candles[index].volume;

      if (volume < 0) {
        return _errorResult('Volume cannot be negative.');
      }

      totalVolume += volume;
    }

    final averageVolume = totalVolume / sampleCount;

    if (averageVolume <= 0) {
      return _errorResult(
        'Average historical daily volume must be greater than zero.',
      );
    }

    final currentVolume = snapshot.currentVolume;

    if (currentVolume < 0) {
      return _errorResult('Current volume cannot be negative.');
    }

    final ratio = currentVolume / averageVolume;

    final direction = _directionForLatestCandle(candles.last);

    final sampleFactor = (sampleCount / policy.targetHistoricalCandles)
        .clamp(0.0, 1.0)
        .toDouble();

    // Daily RVOL receives a conservative reliability cap because the
    // current MarketSnapshot model does not yet identify whether the latest
    // daily candle is complete or still forming.
    final reliability = (0.50 + (sampleFactor * 0.35))
        .clamp(0.50, 0.85)
        .toDouble();

    if (ratio >= policy.exceptionalRatio) {
      return _availableSwingDailyResult(
        ratio: ratio,
        averageVolume: averageVolume,
        currentVolume: currentVolume,
        sampleCount: sampleCount,
        direction: direction,
        strength: EvidenceStrength.exceptional,
        score: 95,
        reliability: reliability,
        explanation:
            'Daily trading participation is exceptionally high and strongly '
            'confirms the direction of the latest daily price candle.',
      );
    }

    if (ratio >= policy.strongRatio) {
      return _availableSwingDailyResult(
        ratio: ratio,
        averageVolume: averageVolume,
        currentVolume: currentVolume,
        sampleCount: sampleCount,
        direction: direction,
        strength: EvidenceStrength.strong,
        score: 80,
        reliability: reliability,
        explanation:
            'Daily trading participation is materially above its recent '
            'baseline and confirms the latest daily price move.',
      );
    }

    if (ratio >= policy.moderateRatio) {
      return _availableSwingDailyResult(
        ratio: ratio,
        averageVolume: averageVolume,
        currentVolume: currentVolume,
        sampleCount: sampleCount,
        direction: direction,
        strength: EvidenceStrength.moderate,
        score: 65,
        reliability: reliability,
        explanation:
            'Daily trading participation is moderately above its recent '
            'baseline and adds some confirmation to the latest price move.',
      );
    }

    if (ratio <= policy.weakParticipationRatio) {
      return _availableSwingDailyResult(
        ratio: ratio,
        averageVolume: averageVolume,
        currentVolume: currentVolume,
        sampleCount: sampleCount,
        direction: EvidenceDirection.neutral,
        strength: EvidenceStrength.weak,
        score: 35,
        reliability: reliability,
        explanation:
            'Daily participation is unusually light. This weakens conviction '
            'in the latest move but does not create evidence in the opposite '
            'direction.',
      );
    }

    return _availableSwingDailyResult(
      ratio: ratio,
      averageVolume: averageVolume,
      currentVolume: currentVolume,
      sampleCount: sampleCount,
      direction: EvidenceDirection.neutral,
      strength: EvidenceStrength.moderate,
      score: 50,
      reliability: reliability,
      explanation:
          'Daily trading participation is close to its recent baseline and '
          'does not provide unusual directional confirmation.',
    );
  }

  EvidenceResult _availableSwingDailyResult({
    required double ratio,
    required double averageVolume,
    required double currentVolume,
    required int sampleCount,
    required EvidenceDirection direction,
    required EvidenceStrength strength,
    required double score,
    required double reliability,
    required String explanation,
  }) {
    final percentageDifference = (ratio - 1) * 100;

    final relativeText = percentageDifference >= 0
        ? '${percentageDifference.toStringAsFixed(0)}% above daily average'
        : '${percentageDifference.abs().toStringAsFixed(0)}% below daily average';

    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: strength,
      score: score,
      baseWeight: 0.90,
      dynamicWeight: 1,
      reliability: reliability,
      currentValue: '${ratio.toStringAsFixed(2)}x',
      baselineValue:
          '${_formatVolume(averageVolume)} • '
          '$sampleCount-day average',
      relativeValue: relativeText,
      explanation:
          '$explanation Current daily volume is '
          '${_formatVolume(currentVolume)} versus a '
          '$sampleCount-day average of ${_formatVolume(averageVolume)}. '
          'If the latest daily candle is still forming, the ratio can '
          'understate eventual full-session volume.',
    );
  }

  EvidenceResult _strategyUnavailable(String reason) {
    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.unavailable,
      direction: EvidenceDirection.unknown,
      strength: EvidenceStrength.veryWeak,
      score: 0,
      baseWeight: 0.90,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'Strategy-appropriate volume history required',
      relativeValue: 'Not available',
      explanation: reason,
      unavailableReason: reason,
    );
  }

  EvidenceResult _availableResult({
    required double ratio,
    required double averageVolume,
    required double currentVolume,
    required EvidenceDirection direction,
    required EvidenceStrength strength,
    required double score,
    required double reliability,
    required String explanation,
  }) {
    final percentageDifference = (ratio - 1) * 100;
    final relativeText = percentageDifference >= 0
        ? '${percentageDifference.toStringAsFixed(0)}% above average'
        : '${percentageDifference.abs().toStringAsFixed(0)}% below average';

    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: strength,
      score: score,
      baseWeight: 0.90,
      dynamicWeight: 1,
      reliability: reliability,
      currentValue: '${ratio.toStringAsFixed(2)}x',
      baselineValue: _formatVolume(averageVolume),
      relativeValue: relativeText,
      explanation:
          '$explanation Current volume is ${_formatVolume(currentVolume)} versus an average of ${_formatVolume(averageVolume)}.',
    );
  }

  EvidenceResult _errorResult(String reason) {
    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.error,
      direction: EvidenceDirection.unknown,
      strength: EvidenceStrength.veryWeak,
      score: 0,
      baseWeight: 0.90,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'Recent average volume',
      relativeValue: 'Not available',
      explanation: 'Relative volume could not be calculated.',
      unavailableReason: reason,
    );
  }

  EvidenceDirection _directionForLatestCandle(MarketCandle candle) {
    if (candle.close > candle.open) {
      return EvidenceDirection.bullish;
    }

    if (candle.close < candle.open) {
      return EvidenceDirection.bearish;
    }

    return EvidenceDirection.neutral;
  }

  String _formatVolume(double volume) {
    if (volume >= 1000000000) {
      return '${(volume / 1000000000).toStringAsFixed(2)}B';
    }

    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(2)}M';
    }

    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    }

    return volume.toStringAsFixed(0);
  }
}
