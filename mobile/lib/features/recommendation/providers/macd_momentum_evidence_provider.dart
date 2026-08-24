import '../../market/models/market_snapshot.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';
import '../models/strategy_summary.dart';
import '../strategy/macd_momentum_strategy_policy.dart';
import '../utils/technical_indicator_math.dart';
import 'evidence_provider.dart';

class MacdMomentumEvidenceProvider implements StrategyAwareEvidenceProvider {
  const MacdMomentumEvidenceProvider({
    this.fastPeriod = 12,
    this.slowPeriod = 26,
    this.signalPeriod = 9,
  });

  final int fastPeriod;
  final int slowPeriod;
  final int signalPeriod;

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    kind: EvidenceKind.macdMomentum,
    family: EvidenceFamily.momentum,
    name: 'MACD Momentum',
    description:
        'Measures whether short-term momentum is strengthening or weakening by comparing fast and slow exponential moving averages and their signal line.',
    whyItMatters:
        'MACD can confirm acceleration, deceleration, and momentum transitions, but it overlaps with trend information and therefore belongs to the Momentum evidence group rather than acting as a completely independent vote.',
    calculation:
        'MACD = fast EMA minus slow EMA and the signal line is an EMA of MACD. Strategy-specific interpretation may also evaluate histogram strengthening or weakening, recent crossovers, zero-line context and volatility-normalized histogram magnitude.',
  );

  @override
  String get name => kDefinition.name;

  @override
  EvidenceDefinition get definition => kDefinition;

  @override
  EvidenceResult evaluate(MarketSnapshot snapshot) {
    final candles = snapshot.candles;
    final requiredCandles = slowPeriod + signalPeriod;

    if (fastPeriod <= 0 || slowPeriod <= fastPeriod || signalPeriod <= 0) {
      return _error('MACD periods are invalid.');
    }

    if (candles.length < requiredCandles) {
      return _insufficient(requiredCandles);
    }

    final closes = candles
        .map((candle) => candle.close)
        .toList(growable: false);
    final price = closes.last;

    if (price <= 0) {
      return _error('MACD requires a positive latest price.');
    }

    final fastSeries = TechnicalIndicatorMath.emaSeries(closes, fastPeriod);
    final slowSeries = TechnicalIndicatorMath.emaSeries(closes, slowPeriod);
    final macdSeries = List<double>.generate(
      closes.length,
      (index) => fastSeries[index] - slowSeries[index],
      growable: false,
    );
    final signalSeries = TechnicalIndicatorMath.emaSeries(
      macdSeries,
      signalPeriod,
    );

    final macd = macdSeries.last;
    final signal = signalSeries.last;
    final histogram = macd - signal;
    final histogramPercent = (histogram / price) * 100;

    final bullish = macd > signal && histogram > 0;
    final bearish = macd < signal && histogram < 0;
    final direction = bullish
        ? EvidenceDirection.bullish
        : bearish
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    final magnitude = histogramPercent.abs();
    final strength = direction == EvidenceDirection.neutral
        ? EvidenceStrength.weak
        : magnitude >= 0.35
        ? EvidenceStrength.exceptional
        : magnitude >= 0.15
        ? EvidenceStrength.strong
        : magnitude >= 0.05
        ? EvidenceStrength.moderate
        : EvidenceStrength.weak;

    final score = direction == EvidenceDirection.neutral
        ? 48.0
        : magnitude >= 0.35
        ? 90.0
        : magnitude >= 0.15
        ? 78.0
        : magnitude >= 0.05
        ? 66.0
        : 55.0;

    final reliability = (0.60 + ((candles.length / 60).clamp(0.0, 1.0) * 0.30))
        .clamp(0.60, 0.90);

    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: strength,
      score: score,
      baseWeight: 0.85,
      dynamicWeight: 1,
      reliability: reliability,
      currentValue: 'MACD ${macd.toStringAsFixed(3)}',
      baselineValue: 'Signal ${signal.toStringAsFixed(3)}',
      relativeValue:
          'Histogram ${histogram >= 0 ? '+' : ''}${histogram.toStringAsFixed(3)} (${histogramPercent >= 0 ? '+' : ''}${histogramPercent.toStringAsFixed(2)}%)',
      explanation:
          '${direction == EvidenceDirection.bullish
              ? 'Momentum is above its signal line.'
              : direction == EvidenceDirection.bearish
              ? 'Momentum is below its signal line.'
              : 'Momentum is mixed around its signal line.'} Histogram strength is normalized by price so the engine does not rely on raw MACD magnitude across differently priced stocks.',
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
        'MACD Momentum has not been calibrated for Investor yet.',
      ),
    };
  }

  EvidenceResult _evaluateSwing(MarketSnapshot snapshot) {
    final policy = MacdMomentumStrategyPolicy.forStrategy(
      strategy: StrategyType.swing,
      timeframe: snapshot.timeframe,
    );

    if (policy == null) {
      return _strategyUnavailable(
        'Swing MACD supports only the approved 1D and 4H primary intervals.',
      );
    }

    final candles = snapshot.candles;

    if (candles.length < policy.minimumCandleCount) {
      return _insufficient(policy.minimumCandleCount);
    }

    final closes = candles
        .map((candle) => candle.close)
        .toList(growable: false);

    if (closes.any((close) => close <= 0)) {
      return _error('Swing MACD requires valid positive closing prices.');
    }

    final fastSeries = TechnicalIndicatorMath.emaSeries(
      closes,
      policy.fastPeriod,
    );

    final slowSeries = TechnicalIndicatorMath.emaSeries(
      closes,
      policy.slowPeriod,
    );

    final macdSeries = List<double>.generate(
      closes.length,
      (index) => fastSeries[index] - slowSeries[index],
      growable: false,
    );

    final signalSeries = TechnicalIndicatorMath.emaSeries(
      macdSeries,
      policy.signalPeriod,
    );

    final histogramSeries = List<double>.generate(
      closes.length,
      (index) => macdSeries[index] - signalSeries[index],
      growable: false,
    );

    final latestIndex = closes.length - 1;

    final macd = macdSeries.last;
    final signal = signalSeries.last;
    final histogram = histogramSeries.last;

    final transitionIndex = latestIndex - policy.transitionLookback;

    final histogramDelta = histogram - histogramSeries[transitionIndex];

    final bullish = macd > signal && histogram > 0;

    final bearish = macd < signal && histogram < 0;

    final direction = bullish
        ? EvidenceDirection.bullish
        : bearish
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    final directional = direction != EvidenceDirection.neutral;

    final strengthening = direction == EvidenceDirection.bullish
        ? histogramDelta > 0
        : direction == EvidenceDirection.bearish
        ? histogramDelta < 0
        : false;

    final zeroAligned = direction == EvidenceDirection.bullish
        ? macd >= 0
        : direction == EvidenceDirection.bearish
        ? macd <= 0
        : false;

    final recentCross = _recentCross(
      histogramSeries,
      policy.freshCrossoverBars,
    );

    final freshDirectionalCross = direction == EvidenceDirection.bullish
        ? recentCross == _MacdCross.bullish
        : direction == EvidenceDirection.bearish
        ? recentCross == _MacdCross.bearish
        : false;

    final atr = TechnicalIndicatorMath.atr(candles, period: policy.atrPeriod);

    final histogramAtr = atr <= 0 ? 0.0 : histogram.abs() / atr;

    late final EvidenceStrength strength;
    late final double score;
    late final double dynamicWeight;

    if (!directional) {
      strength = EvidenceStrength.weak;
      score = 48;
      dynamicWeight = policy.neutralDynamicWeight;
    } else if (freshDirectionalCross && strengthening) {
      strength = EvidenceStrength.strong;
      score = 78;
      dynamicWeight = zeroAligned ? 1 : policy.transitionDynamicWeight;
    } else if (zeroAligned &&
        strengthening &&
        histogramAtr >= policy.exceptionalHistogramAtr) {
      strength = EvidenceStrength.exceptional;
      score = 90;
      dynamicWeight = 1;
    } else if (zeroAligned &&
        strengthening &&
        histogramAtr >= policy.strongHistogramAtr) {
      strength = EvidenceStrength.strong;
      score = 82;
      dynamicWeight = 1;
    } else if (zeroAligned && strengthening) {
      strength = EvidenceStrength.moderate;
      score = 72;
      dynamicWeight = 1;
    } else if (strengthening) {
      strength = EvidenceStrength.moderate;
      score = 68;
      dynamicWeight = policy.transitionDynamicWeight;
    } else {
      strength = EvidenceStrength.weak;
      score = 58;
      dynamicWeight = policy.weakeningDynamicWeight;
    }

    final sampleFactor = (candles.length / policy.targetCandleCount)
        .clamp(0.0, 1.0)
        .toDouble();

    final clarityFactor = policy.strongHistogramAtr <= 0
        ? 0.0
        : (histogramAtr / policy.strongHistogramAtr).clamp(0.0, 1.0).toDouble();

    final phaseFactor = strengthening
        ? 1.0
        : directional
        ? 0.70
        : 0.50;

    final reliability =
        (0.45 +
                (sampleFactor * 0.20) +
                (clarityFactor * 0.15) +
                (phaseFactor * 0.10))
            .clamp(0.45, 0.90)
            .toDouble();

    final phaseLabel = strengthening
        ? 'strengthening'
        : directional
        ? 'weakening'
        : 'mixed';

    final zeroLineLabel = macd >= 0 ? 'above zero line' : 'below zero line';

    final crossLabel = switch (recentCross) {
      _MacdCross.bullish => 'fresh bullish crossover',
      _MacdCross.bearish => 'fresh bearish crossover',
      _MacdCross.none => 'no fresh crossover',
    };

    final directionExplanation = direction == EvidenceDirection.bullish
        ? 'MACD is above its signal line.'
        : direction == EvidenceDirection.bearish
        ? 'MACD is below its signal line.'
        : 'MACD and its signal line do not provide a clear directional momentum relationship.';

    final transitionExplanation = freshDirectionalCross
        ? 'A fresh crossover supports the current momentum direction.'
        : strengthening
        ? 'Histogram momentum is strengthening.'
        : directional
        ? 'Histogram momentum is weakening, so its influence is reduced.'
        : 'Histogram momentum is mixed.';

    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: strength,
      score: score,
      baseWeight: 0.85,
      dynamicWeight: dynamicWeight,
      reliability: reliability,
      currentValue: 'MACD ${macd.toStringAsFixed(3)}',
      baselineValue: 'Signal ${signal.toStringAsFixed(3)}',
      relativeValue:
          'Histogram '
          '${histogram >= 0 ? '+' : ''}'
          '${histogram.toStringAsFixed(3)} • '
          '${histogramAtr.toStringAsFixed(2)}× ATR • '
          '$phaseLabel • $zeroLineLabel • $crossLabel',
      explanation:
          '$directionExplanation '
          '$transitionExplanation '
          'MACD is $zeroLineLabel and histogram magnitude is '
          '${histogramAtr.toStringAsFixed(2)}× ATR. '
          'The zero line is interpretation context only; it does not create '
          'another Trend-family vote. MACD remains Momentum-family evidence.',
    );
  }

  _MacdCross _recentCross(List<double> histogramSeries, int freshnessBars) {
    if (histogramSeries.length < 2 || freshnessBars <= 0) {
      return _MacdCross.none;
    }

    final start = (histogramSeries.length - 1 - freshnessBars)
        .clamp(1, histogramSeries.length - 1)
        .toInt();

    var result = _MacdCross.none;

    for (var index = start; index < histogramSeries.length; index++) {
      final previous = histogramSeries[index - 1];
      final current = histogramSeries[index];

      if (previous <= 0 && current > 0) {
        result = _MacdCross.bullish;
      } else if (previous >= 0 && current < 0) {
        result = _MacdCross.bearish;
      }
    }

    return result;
  }

  EvidenceResult _strategyUnavailable(String reason) {
    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.unavailable,
      direction: EvidenceDirection.unknown,
      strength: EvidenceStrength.veryWeak,
      score: 0,
      baseWeight: 0.85,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'Strategy-specific MACD calibration required',
      relativeValue: 'Not available',
      explanation: reason,
      unavailableReason: reason,
    );
  }

  EvidenceResult _insufficient(int requiredCandles) {
    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.insufficientData,
      direction: EvidenceDirection.unknown,
      strength: EvidenceStrength.veryWeak,
      score: 0,
      baseWeight: 0.85,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'At least $requiredCandles candles required',
      relativeValue: 'Not available',
      explanation: 'There is not enough candle history to calculate MACD.',
      unavailableReason: 'At least $requiredCandles candles are required.',
    );
  }

  EvidenceResult _error(String reason) {
    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.error,
      direction: EvidenceDirection.unknown,
      strength: EvidenceStrength.veryWeak,
      score: 0,
      baseWeight: 0.85,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'MACD calculation',
      relativeValue: 'Not available',
      explanation: 'MACD momentum could not be calculated.',
      unavailableReason: reason,
    );
  }
}

enum _MacdCross { none, bullish, bearish }
