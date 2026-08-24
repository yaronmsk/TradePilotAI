import 'dart:math' as math;

import '../../market/models/market_candle.dart';
import '../../market/models/market_snapshot.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';
import '../models/strategy_summary.dart';
import '../strategy/candle_trend_strategy_policy.dart';
import 'evidence_provider.dart';

class CandleTrendEvidenceProvider implements StrategyAwareEvidenceProvider {
  const CandleTrendEvidenceProvider();

  static const int _traderTargetCandleCount = 48;

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    kind: EvidenceKind.candleTrend,
    family: EvidenceFamily.trend,
    name: 'Candle Trend',
    description:
        'Measures whether recent price movement is rising, falling or mostly sideways.',
    whyItMatters:
        'A clean sustained price move can indicate persistent buying or selling pressure.',
    calculation:
        'Measures net closing-price movement across the active strategy window and evaluates reliability from sample size and trend consistency. Strategy-specific calibration may also normalize movement for recent volatility.',
  );

  @override
  String get name => kDefinition.name;

  @override
  EvidenceDefinition get definition => kDefinition;

  /// Existing callers continue to receive the validated Trader calculation.
  @override
  EvidenceResult evaluate(MarketSnapshot snapshot) {
    return _evaluateTrader(snapshot);
  }

  @override
  EvidenceResult evaluateForStrategy(
    MarketSnapshot snapshot, {
    required StrategyType strategy,
  }) {
    return switch (strategy) {
      StrategyType.trader => _evaluateTrader(snapshot),
      StrategyType.swing => _evaluateSwing(snapshot),
      StrategyType.investor => _unsupportedStrategyResult(
        'Candle Trend has not been calibrated for Investor yet.',
      ),
    };
  }

  EvidenceResult _evaluateTrader(MarketSnapshot snapshot) {
    if (snapshot.candles.length < 2) {
      return EvidenceResult(
        providerName: name,
        definition: definition,
        status: EvidenceStatus.insufficientData,
        direction: EvidenceDirection.unknown,
        strength: EvidenceStrength.veryWeak,
        score: 0,
        baseWeight: 1,
        dynamicWeight: 1,
        reliability: 0,
        currentValue: 'Not available',
        baselineValue: 'At least 2 candles required',
        relativeValue: 'Not available',
        explanation:
            'There is not enough candle history to evaluate the trend.',
        unavailableReason: 'At least two candles are required.',
      );
    }

    final firstClose = snapshot.candles.first.close;
    final lastClose = snapshot.candles.last.close;

    if (firstClose <= 0) {
      return EvidenceResult(
        providerName: name,
        definition: definition,
        status: EvidenceStatus.error,
        direction: EvidenceDirection.unknown,
        strength: EvidenceStrength.veryWeak,
        score: 0,
        baseWeight: 1,
        dynamicWeight: 1,
        reliability: 0,
        currentValue: 'Invalid candle data',
        baselineValue: 'First close must be above zero',
        relativeValue: 'Not available',
        explanation: 'The candle trend could not be calculated.',
        unavailableReason: 'The first closing price is invalid.',
      );
    }

    final changePercent = ((lastClose - firstClose) / firstClose) * 100;

    final reliabilityMetrics = _calculateTraderReliability(snapshot);

    if (changePercent >= 5) {
      return _availableTraderResult(
        changePercent: changePercent,
        direction: EvidenceDirection.bullish,
        strength: EvidenceStrength.exceptional,
        score: 95,
        reliabilityMetrics: reliabilityMetrics,
        explanation:
            'The recent candle sequence shows a strong upward price trend.',
      );
    }

    if (changePercent >= 2) {
      return _availableTraderResult(
        changePercent: changePercent,
        direction: EvidenceDirection.bullish,
        strength: EvidenceStrength.strong,
        score: 80,
        reliabilityMetrics: reliabilityMetrics,
        explanation:
            'The recent candle sequence shows a moderate upward price trend.',
      );
    }

    if (changePercent <= -5) {
      return _availableTraderResult(
        changePercent: changePercent,
        direction: EvidenceDirection.bearish,
        strength: EvidenceStrength.exceptional,
        score: 95,
        reliabilityMetrics: reliabilityMetrics,
        explanation:
            'The recent candle sequence shows a strong downward price trend.',
      );
    }

    if (changePercent <= -2) {
      return _availableTraderResult(
        changePercent: changePercent,
        direction: EvidenceDirection.bearish,
        strength: EvidenceStrength.strong,
        score: 80,
        reliabilityMetrics: reliabilityMetrics,
        explanation:
            'The recent candle sequence shows a moderate downward price trend.',
      );
    }

    return _availableTraderResult(
      changePercent: changePercent,
      direction: EvidenceDirection.neutral,
      strength: EvidenceStrength.moderate,
      score: 50,
      reliabilityMetrics: reliabilityMetrics,
      explanation: 'The recent candle sequence is moving mostly sideways.',
    );
  }

  EvidenceResult _evaluateSwing(MarketSnapshot snapshot) {
    final policy = CandleTrendStrategyPolicy.forStrategy(
      strategy: StrategyType.swing,
      timeframe: snapshot.timeframe,
    );

    if (policy == null) {
      return _unsupportedStrategyResult(
        'Swing Candle Trend supports only the approved 1D and 4H primary intervals.',
      );
    }

    if (snapshot.candles.length < policy.minimumCandleCount) {
      return EvidenceResult(
        providerName: name,
        definition: definition,
        status: EvidenceStatus.insufficientData,
        direction: EvidenceDirection.unknown,
        strength: EvidenceStrength.veryWeak,
        score: 0,
        baseWeight: 1,
        dynamicWeight: 1,
        reliability: 0,
        currentValue: 'Not enough Swing history',
        baselineValue:
            'At least ${policy.minimumCandleCount} ${_timeframeLabel(snapshot.timeframe)} candles required',
        relativeValue: 'Not available',
        explanation:
            'There is not enough recent price history to evaluate Swing Candle Trend reliably.',
        unavailableReason:
            'At least ${policy.minimumCandleCount} candles are required for this Swing interval.',
      );
    }

    final window = snapshot.candles.length > policy.targetCandleCount
        ? snapshot.candles.sublist(
            snapshot.candles.length - policy.targetCandleCount,
          )
        : snapshot.candles;

    if (window.any((candle) => candle.close <= 0)) {
      return EvidenceResult(
        providerName: name,
        definition: definition,
        status: EvidenceStatus.error,
        direction: EvidenceDirection.unknown,
        strength: EvidenceStrength.veryWeak,
        score: 0,
        baseWeight: 1,
        dynamicWeight: 1,
        reliability: 0,
        currentValue: 'Invalid candle data',
        baselineValue: 'Closing prices must be above zero',
        relativeValue: 'Not available',
        explanation: 'Swing Candle Trend could not be calculated.',
        unavailableReason:
            'All closing prices in the Swing trend window must be valid.',
      );
    }

    final firstClose = window.first.close;
    final lastClose = window.last.close;

    final changePercent = ((lastClose - firstClose) / firstClose) * 100;

    final metrics = _calculateSwingMetrics(
      candles: window,
      policy: policy,
      changePercent: changePercent,
    );

    final absoluteNormalizedMove = metrics.normalizedMove.abs();

    if (absoluteNormalizedMove < policy.directionalThreshold) {
      return _availableSwingResult(
        snapshot: snapshot,
        metrics: metrics,
        changePercent: changePercent,
        direction: EvidenceDirection.neutral,
        strength: EvidenceStrength.weak,
        score: 35,
        conclusion:
            'The recent move is not large enough relative to this stock\'s recent volatility to establish a reliable Swing trend.',
      );
    }

    final direction = changePercent > 0
        ? EvidenceDirection.bullish
        : EvidenceDirection.bearish;

    if (absoluteNormalizedMove >= policy.exceptionalThreshold) {
      return _availableSwingResult(
        snapshot: snapshot,
        metrics: metrics,
        changePercent: changePercent,
        direction: direction,
        strength: EvidenceStrength.exceptional,
        score: 95,
        conclusion: direction == EvidenceDirection.bullish
            ? 'Price is rising strongly and cleanly relative to its recent volatility.'
            : 'Price is falling strongly and cleanly relative to its recent volatility.',
      );
    }

    if (absoluteNormalizedMove >= policy.strongThreshold) {
      return _availableSwingResult(
        snapshot: snapshot,
        metrics: metrics,
        changePercent: changePercent,
        direction: direction,
        strength: EvidenceStrength.strong,
        score: 80,
        conclusion: direction == EvidenceDirection.bullish
            ? 'Price shows a meaningful upward Swing trend relative to recent volatility.'
            : 'Price shows a meaningful downward Swing trend relative to recent volatility.',
      );
    }

    return _availableSwingResult(
      snapshot: snapshot,
      metrics: metrics,
      changePercent: changePercent,
      direction: direction,
      strength: EvidenceStrength.moderate,
      score: 60,
      conclusion: direction == EvidenceDirection.bullish
          ? 'Price shows a developing upward Swing trend, although the move is only moderately strong relative to recent volatility.'
          : 'Price shows a developing downward Swing trend, although the move is only moderately strong relative to recent volatility.',
    );
  }

  EvidenceResult _availableTraderResult({
    required double changePercent,
    required EvidenceDirection direction,
    required EvidenceStrength strength,
    required double score,
    required _TraderReliabilityMetrics reliabilityMetrics,
    required String explanation,
  }) {
    final consistencyPercent = (reliabilityMetrics.trendEfficiency * 100)
        .toStringAsFixed(0);

    final reliabilityPercent = (reliabilityMetrics.reliability * 100)
        .toStringAsFixed(0);

    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: strength,
      score: score,
      baseWeight: 1,
      dynamicWeight: 1,
      reliability: reliabilityMetrics.reliability,
      currentValue: '${changePercent.toStringAsFixed(2)}%',
      baselineValue: 'First candle close',
      relativeValue: '${changePercent.toStringAsFixed(2)}%',
      explanation:
          '$explanation Reliability is $reliabilityPercent%, based on '
          '${reliabilityMetrics.candleCount} candles and '
          '$consistencyPercent% trend consistency.',
    );
  }

  EvidenceResult _availableSwingResult({
    required MarketSnapshot snapshot,
    required _SwingTrendMetrics metrics,
    required double changePercent,
    required EvidenceDirection direction,
    required EvidenceStrength strength,
    required double score,
    required String conclusion,
  }) {
    final consistencyPercent = (metrics.trendEfficiency * 100).toStringAsFixed(
      0,
    );

    final reliabilityPercent = (metrics.reliability * 100).toStringAsFixed(0);

    final normalizedText = metrics.normalizedMove.abs().toStringAsFixed(2);

    final directionLabel = switch (direction) {
      EvidenceDirection.bullish => 'Rising',
      EvidenceDirection.bearish => 'Falling',
      EvidenceDirection.neutral => 'Mostly sideways',
      EvidenceDirection.unknown => 'Unknown',
    };

    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: strength,
      score: score,
      baseWeight: 1,
      dynamicWeight: 1,
      reliability: metrics.reliability,
      currentValue: '$directionLabel • ${changePercent.toStringAsFixed(2)}%',
      baselineValue:
          '${metrics.candleCount} ${_timeframeLabel(snapshot.timeframe)} candles • '
          'expected volatility move ${metrics.expectedNoisePercent.toStringAsFixed(2)}%',
      relativeValue: '$normalizedText× volatility-normalized',
      explanation:
          '$conclusion Price moved ${changePercent.toStringAsFixed(2)}% across '
          'the most recent ${metrics.candleCount} '
          '${_timeframeLabel(snapshot.timeframe)} candles. '
          'That move is $normalizedText× the volatility-normalized movement '
          'baseline. Trend consistency is $consistencyPercent% and data '
          'reliability is $reliabilityPercent%.',
    );
  }

  EvidenceResult _unsupportedStrategyResult(String reason) {
    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.unavailable,
      direction: EvidenceDirection.unknown,
      strength: EvidenceStrength.veryWeak,
      score: 0,
      baseWeight: 1,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'Strategy-specific calibration required',
      relativeValue: 'Not available',
      explanation: reason,
      unavailableReason: reason,
    );
  }

  _TraderReliabilityMetrics _calculateTraderReliability(
    MarketSnapshot snapshot,
  ) {
    final candles = snapshot.candles;

    final sampleFactor = (candles.length / _traderTargetCandleCount).clamp(
      0.0,
      1.0,
    );

    double totalPathDistance = 0;

    for (var index = 1; index < candles.length; index++) {
      totalPathDistance += (candles[index].close - candles[index - 1].close)
          .abs();
    }

    final netPriceChange = (candles.last.close - candles.first.close).abs();

    final trendEfficiency = totalPathDistance == 0
        ? 0.0
        : (netPriceChange / totalPathDistance).clamp(0.0, 1.0);

    final reliability =
        (0.10 + (sampleFactor * 0.40) + (trendEfficiency * 0.45)).clamp(
          0.10,
          0.95,
        );

    return _TraderReliabilityMetrics(
      reliability: reliability,
      trendEfficiency: trendEfficiency,
      candleCount: candles.length,
    );
  }

  _SwingTrendMetrics _calculateSwingMetrics({
    required List<MarketCandle> candles,
    required CandleTrendStrategyPolicy policy,
    required double changePercent,
  }) {
    final periods = candles.length - 1;

    final returns = <double>[];
    double totalPathDistance = 0;
    double trueRangePercentTotal = 0;

    for (var index = 1; index < candles.length; index++) {
      final previous = candles[index - 1];
      final current = candles[index];

      final closeChange = current.close - previous.close;

      totalPathDistance += closeChange.abs();

      returns.add((closeChange / previous.close) * 100);

      final highLow = current.high - current.low;
      final highGap = (current.high - previous.close).abs();
      final lowGap = (current.low - previous.close).abs();

      final trueRange = math.max(highLow, math.max(highGap, lowGap));

      trueRangePercentTotal += (trueRange / previous.close) * 100;
    }

    final returnMean = returns.isEmpty
        ? 0.0
        : returns.reduce((a, b) => a + b) / returns.length;

    final returnVariance = returns.isEmpty
        ? 0.0
        : returns
                  .map((value) => math.pow(value - returnMean, 2).toDouble())
                  .reduce((a, b) => a + b) /
              returns.length;

    final returnVolatilityPercent = math.sqrt(returnVariance);

    final averageTrueRangePercent = periods <= 0
        ? 0.0
        : trueRangePercentTotal / periods;

    final oneCandleNoisePercent = math.max(
      policy.volatilityFloorPercent,
      math.max(
        returnVolatilityPercent,
        averageTrueRangePercent * policy.atrNoiseFactor,
      ),
    );

    final expectedNoisePercent =
        oneCandleNoisePercent * math.sqrt(math.max(1, periods));

    final normalizedMove = expectedNoisePercent <= 0
        ? 0.0
        : changePercent / expectedNoisePercent;

    final netPriceChange = (candles.last.close - candles.first.close).abs();

    final trendEfficiency = totalPathDistance == 0
        ? 0.0
        : (netPriceChange / totalPathDistance).clamp(0.0, 1.0);

    final sampleFactor = (candles.length / policy.targetCandleCount).clamp(
      0.0,
      1.0,
    );

    final reliability =
        (0.15 + (sampleFactor * 0.40) + (trendEfficiency * 0.40)).clamp(
          0.15,
          0.95,
        );

    return _SwingTrendMetrics(
      reliability: reliability,
      trendEfficiency: trendEfficiency,
      normalizedMove: normalizedMove,
      expectedNoisePercent: expectedNoisePercent,
      averageTrueRangePercent: averageTrueRangePercent,
      returnVolatilityPercent: returnVolatilityPercent,
      candleCount: candles.length,
    );
  }

  String _timeframeLabel(String timeframe) {
    return switch (timeframe.toLowerCase()) {
      '1d' => 'daily',
      '4h' => '4-hour',
      _ => timeframe,
    };
  }
}

class _TraderReliabilityMetrics {
  const _TraderReliabilityMetrics({
    required this.reliability,
    required this.trendEfficiency,
    required this.candleCount,
  });

  final double reliability;
  final double trendEfficiency;
  final int candleCount;
}

class _SwingTrendMetrics {
  const _SwingTrendMetrics({
    required this.reliability,
    required this.trendEfficiency,
    required this.normalizedMove,
    required this.expectedNoisePercent,
    required this.averageTrueRangePercent,
    required this.returnVolatilityPercent,
    required this.candleCount,
  });

  final double reliability;
  final double trendEfficiency;

  /// Signed move relative to expected noise over this window.
  final double normalizedMove;

  final double expectedNoisePercent;
  final double averageTrueRangePercent;
  final double returnVolatilityPercent;
  final int candleCount;
}
