import '../../market/models/market_snapshot.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';
import '../models/strategy_summary.dart';
import '../strategy/rsi_strategy_policy.dart';
import '../utils/technical_indicator_math.dart';
import 'evidence_provider.dart';

class RsiEvidenceProvider implements StrategyAwareEvidenceProvider {
  const RsiEvidenceProvider({this.period = 14});

  final int period;

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    kind: EvidenceKind.rsi,
    family: EvidenceFamily.momentum,
    name: 'RSI',
    description:
        'Measures the speed and magnitude of recent price changes on a scale from 0 to 100.',
    whyItMatters:
        'RSI can help identify when price momentum may be stretched toward overbought or oversold conditions.',
    calculation:
        'RSI is calculated from average gains and average losses over the selected lookback period. Strategy-specific interpretation determines whether that momentum confirms, challenges or is excessively stretched relative to the active setup.',
  );

  @override
  String get name => kDefinition.name;

  @override
  EvidenceDefinition get definition => kDefinition;

  @override
  EvidenceResult evaluate(MarketSnapshot snapshot) {
    final candles = snapshot.candles;

    if (period <= 0) {
      return _errorResult(reason: 'RSI period must be greater than zero.');
    }

    if (candles.length < period + 1) {
      return EvidenceResult(
        providerName: name,
        definition: definition,
        status: EvidenceStatus.insufficientData,
        direction: EvidenceDirection.unknown,
        strength: EvidenceStrength.veryWeak,
        score: 0,
        baseWeight: 0.8,
        dynamicWeight: 1,
        reliability: 0,
        currentValue: 'Not available',
        baselineValue: 'RSI $period',
        relativeValue: 'Not available',
        explanation: 'There is not enough candle history to calculate RSI.',
        unavailableReason: 'At least ${period + 1} candles are required.',
      );
    }

    double gains = 0;
    double losses = 0;

    final startIndex = candles.length - period;

    for (var index = startIndex; index < candles.length; index++) {
      final previousClose = candles[index - 1].close;
      final currentClose = candles[index].close;

      if (previousClose <= 0 || currentClose <= 0) {
        return _errorResult(
          reason: 'RSI cannot be calculated from invalid closing prices.',
        );
      }

      final change = currentClose - previousClose;

      if (change > 0) {
        gains += change;
      } else if (change < 0) {
        losses += change.abs();
      }
    }

    final averageGain = gains / period;
    final averageLoss = losses / period;

    final rsi = _calculateRsi(
      averageGain: averageGain,
      averageLoss: averageLoss,
    );

    final reliability = _calculateReliability(candleCount: candles.length);

    return _resultForRsi(
      rsi: rsi,
      reliability: reliability,
      candleCount: candles.length,
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
        'RSI has not been calibrated for Investor yet.',
      ),
    };
  }

  EvidenceResult _evaluateSwing(MarketSnapshot snapshot) {
    final policy = RsiStrategyPolicy.forStrategy(
      strategy: StrategyType.swing,
      timeframe: snapshot.timeframe,
    );

    if (policy == null) {
      return _strategyUnavailable(
        'Swing RSI supports only the approved 1D and 4H primary intervals.',
      );
    }

    final candles = snapshot.candles;

    if (candles.length < policy.minimumCandleCount) {
      return EvidenceResult(
        providerName: name,
        definition: definition,
        status: EvidenceStatus.insufficientData,
        direction: EvidenceDirection.unknown,
        strength: EvidenceStrength.veryWeak,
        score: 0,
        baseWeight: 0.8,
        dynamicWeight: 1,
        reliability: 0,
        currentValue: 'Not available',
        baselineValue: 'Swing RSI ${policy.rsiPeriod}',
        relativeValue: 'Not available',
        explanation:
            'There is not enough history to calculate Swing RSI with its trend context.',
        unavailableReason:
            'At least ${policy.minimumCandleCount} candles are required.',
      );
    }

    final closes = candles
        .map((candle) => candle.close)
        .toList(growable: false);

    if (closes.any((close) => close <= 0)) {
      return _errorResult(
        reason: 'Swing RSI requires valid positive closing prices.',
      );
    }

    final rsi = _calculateRsiFromCloses(closes, policy.rsiPeriod);

    final fastSeries = TechnicalIndicatorMath.emaSeries(
      closes,
      policy.contextFastEmaPeriod,
    );

    final slowSeries = TechnicalIndicatorMath.emaSeries(
      closes,
      policy.contextSlowEmaPeriod,
    );

    final latestIndex = closes.length - 1;
    final slopeIndex = latestIndex - policy.contextSlopeLookback;

    final fast = fastSeries.last;
    final slow = slowSeries.last;
    final price = closes.last;

    final fastSlope = fast - fastSeries[slopeIndex];
    final slowSlope = slow - slowSeries[slopeIndex];

    final context =
        price > fast && fast > slow && fastSlope > 0 && slowSlope > 0
        ? _SwingRsiTrendContext.bullish
        : price < fast && fast < slow && fastSlope < 0 && slowSlope < 0
        ? _SwingRsiTrendContext.bearish
        : _SwingRsiTrendContext.mixed;

    final interpretation = _interpretSwingRsi(
      rsi: rsi,
      context: context,
      policy: policy,
    );

    final sampleFactor = (candles.length / policy.targetCandleCount)
        .clamp(0.0, 1.0)
        .toDouble();

    final contextFactor = context == _SwingRsiTrendContext.mixed ? 0.65 : 1.0;

    final reliability = (0.40 + (sampleFactor * 0.30) + (contextFactor * 0.15))
        .clamp(0.40, 0.90)
        .toDouble();

    final reliabilityPercent = (reliability * 100).toStringAsFixed(0);

    final contextLabel = switch (context) {
      _SwingRsiTrendContext.bullish => 'bullish 20/50 EMA context',
      _SwingRsiTrendContext.bearish => 'bearish 20/50 EMA context',
      _SwingRsiTrendContext.mixed => 'mixed 20/50 EMA context',
    };

    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.available,
      direction: interpretation.direction,
      strength: interpretation.strength,
      score: interpretation.score,
      baseWeight: 0.8,
      dynamicWeight: interpretation.dynamicWeight,
      reliability: reliability,
      currentValue: 'RSI ${rsi.toStringAsFixed(2)}',
      baselineValue:
          'Swing RSI ${policy.rsiPeriod} • '
          'momentum 45–55 neutral • stretch 20/80',
      relativeValue: interpretation.label,
      explanation:
          '${interpretation.explanation} '
          'Current context is $contextLabel. '
          'Reliability is $reliabilityPercent%. '
          'The 20/50 EMA structure is used only to interpret RSI; '
          'it does not create another Trend-family vote. '
          'RSI remains Momentum-family evidence.',
    );
  }

  double _calculateRsiFromCloses(List<double> closes, int rsiPeriod) {
    double gains = 0;
    double losses = 0;

    final startIndex = closes.length - rsiPeriod;

    for (var index = startIndex; index < closes.length; index++) {
      final change = closes[index] - closes[index - 1];

      if (change > 0) {
        gains += change;
      } else if (change < 0) {
        losses += change.abs();
      }
    }

    return _calculateRsi(
      averageGain: gains / rsiPeriod,
      averageLoss: losses / rsiPeriod,
    );
  }

  _SwingRsiInterpretation _interpretSwingRsi({
    required double rsi,
    required _SwingRsiTrendContext context,
    required RsiStrategyPolicy policy,
  }) {
    if (rsi >= policy.extremeHigh) {
      return _SwingRsiInterpretation(
        direction: EvidenceDirection.bullish,
        strength: EvidenceStrength.moderate,
        score: 60,
        dynamicWeight: policy.extremeDynamicWeight,
        label: 'Bullish momentum • extended',
        explanation:
            'RSI shows very strong upside momentum but is highly extended. '
            'Swing does not convert this condition into automatic bearish evidence; '
            'instead RSI keeps the momentum direction with reduced influence because entry quality is less favorable.',
      );
    }

    if (rsi <= policy.extremeLow) {
      return _SwingRsiInterpretation(
        direction: EvidenceDirection.bearish,
        strength: EvidenceStrength.moderate,
        score: 60,
        dynamicWeight: policy.extremeDynamicWeight,
        label: 'Bearish momentum • extended',
        explanation:
            'RSI shows very strong downside momentum but is highly extended. '
            'Swing does not convert this condition into automatic bullish evidence; '
            'instead RSI keeps the momentum direction with reduced influence because entry quality is less favorable.',
      );
    }

    if (context == _SwingRsiTrendContext.bullish) {
      if (rsi >= policy.strongBullishFloor) {
        return const _SwingRsiInterpretation(
          direction: EvidenceDirection.bullish,
          strength: EvidenceStrength.strong,
          score: 82,
          dynamicWeight: 1,
          label: 'Bullish momentum confirmation',
          explanation: 'RSI confirms the established bullish Swing structure.',
        );
      }

      if (rsi >= policy.bullishMomentumFloor) {
        return const _SwingRsiInterpretation(
          direction: EvidenceDirection.bullish,
          strength: EvidenceStrength.moderate,
          score: 68,
          dynamicWeight: 1,
          label: 'Moderate bullish momentum',
          explanation:
              'RSI provides moderate momentum confirmation for the bullish Swing structure.',
        );
      }

      if (rsi > policy.bearishMomentumCeiling) {
        return const _SwingRsiInterpretation(
          direction: EvidenceDirection.neutral,
          strength: EvidenceStrength.moderate,
          score: 50,
          dynamicWeight: 1,
          label: 'Neutral / pullback momentum',
          explanation:
              'RSI is in a neutral zone inside the bullish structure and does not create a directional momentum vote.',
        );
      }

      if (rsi <= policy.strongBearishCeiling) {
        return const _SwingRsiInterpretation(
          direction: EvidenceDirection.bearish,
          strength: EvidenceStrength.strong,
          score: 78,
          dynamicWeight: 1,
          label: 'Bearish momentum deterioration',
          explanation:
              'RSI has deteriorated materially against the bullish trend context, creating opposing momentum evidence.',
        );
      }

      return const _SwingRsiInterpretation(
        direction: EvidenceDirection.bearish,
        strength: EvidenceStrength.moderate,
        score: 64,
        dynamicWeight: 1,
        label: 'Weakening bullish momentum',
        explanation:
            'RSI has weakened below the neutral zone and now challenges the bullish trend context.',
      );
    }

    if (context == _SwingRsiTrendContext.bearish) {
      if (rsi <= policy.strongBearishCeiling) {
        return const _SwingRsiInterpretation(
          direction: EvidenceDirection.bearish,
          strength: EvidenceStrength.strong,
          score: 82,
          dynamicWeight: 1,
          label: 'Bearish momentum confirmation',
          explanation: 'RSI confirms the established bearish Swing structure.',
        );
      }

      if (rsi <= policy.bearishMomentumCeiling) {
        return const _SwingRsiInterpretation(
          direction: EvidenceDirection.bearish,
          strength: EvidenceStrength.moderate,
          score: 68,
          dynamicWeight: 1,
          label: 'Moderate bearish momentum',
          explanation:
              'RSI provides moderate momentum confirmation for the bearish Swing structure.',
        );
      }

      if (rsi < policy.bullishMomentumFloor) {
        return const _SwingRsiInterpretation(
          direction: EvidenceDirection.neutral,
          strength: EvidenceStrength.moderate,
          score: 50,
          dynamicWeight: 1,
          label: 'Neutral / rebound momentum',
          explanation:
              'RSI is in a neutral zone inside the bearish structure and does not create a directional momentum vote.',
        );
      }

      if (rsi >= policy.strongBullishFloor) {
        return const _SwingRsiInterpretation(
          direction: EvidenceDirection.bullish,
          strength: EvidenceStrength.strong,
          score: 78,
          dynamicWeight: 1,
          label: 'Bullish momentum improvement',
          explanation:
              'RSI has improved materially against the bearish trend context, creating opposing bullish momentum evidence.',
        );
      }

      return const _SwingRsiInterpretation(
        direction: EvidenceDirection.bullish,
        strength: EvidenceStrength.moderate,
        score: 64,
        dynamicWeight: 1,
        label: 'Improving bearish momentum',
        explanation:
            'RSI has strengthened above the neutral zone and now challenges the bearish trend context.',
      );
    }

    if (rsi >= policy.strongBullishFloor) {
      return const _SwingRsiInterpretation(
        direction: EvidenceDirection.bullish,
        strength: EvidenceStrength.strong,
        score: 76,
        dynamicWeight: 0.80,
        label: 'Bullish momentum • mixed trend context',
        explanation:
            'RSI is bullish, but the surrounding Swing trend structure is mixed, so its influence is reduced.',
      );
    }

    if (rsi >= policy.bullishMomentumFloor) {
      return const _SwingRsiInterpretation(
        direction: EvidenceDirection.bullish,
        strength: EvidenceStrength.moderate,
        score: 64,
        dynamicWeight: 0.80,
        label: 'Moderate bullish momentum • mixed context',
        explanation:
            'RSI leans bullish while trend structure is mixed, so the momentum evidence is deliberately discounted.',
      );
    }

    if (rsi <= policy.strongBearishCeiling) {
      return const _SwingRsiInterpretation(
        direction: EvidenceDirection.bearish,
        strength: EvidenceStrength.strong,
        score: 76,
        dynamicWeight: 0.80,
        label: 'Bearish momentum • mixed trend context',
        explanation:
            'RSI is bearish, but the surrounding Swing trend structure is mixed, so its influence is reduced.',
      );
    }

    if (rsi <= policy.bearishMomentumCeiling) {
      return const _SwingRsiInterpretation(
        direction: EvidenceDirection.bearish,
        strength: EvidenceStrength.moderate,
        score: 64,
        dynamicWeight: 0.80,
        label: 'Moderate bearish momentum • mixed context',
        explanation:
            'RSI leans bearish while trend structure is mixed, so the momentum evidence is deliberately discounted.',
      );
    }

    return const _SwingRsiInterpretation(
      direction: EvidenceDirection.neutral,
      strength: EvidenceStrength.moderate,
      score: 50,
      dynamicWeight: 0.80,
      label: 'Neutral momentum • mixed trend context',
      explanation:
          'RSI and the surrounding trend structure do not provide a clear Swing momentum direction.',
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
      baseWeight: 0.8,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'Strategy-specific RSI calibration required',
      relativeValue: 'Not available',
      explanation: reason,
      unavailableReason: reason,
    );
  }

  double _calculateRsi({
    required double averageGain,
    required double averageLoss,
  }) {
    if (averageGain == 0 && averageLoss == 0) {
      return 50;
    }

    if (averageLoss == 0) {
      return 100;
    }

    if (averageGain == 0) {
      return 0;
    }

    final relativeStrength = averageGain / averageLoss;

    return 100 - (100 / (1 + relativeStrength));
  }

  double _calculateReliability({required int candleCount}) {
    final targetCount = period * 3;

    final sampleFactor = (candleCount / targetCount).clamp(0.0, 1.0);

    return (0.45 + (sampleFactor * 0.45)).clamp(0.45, 0.90);
  }

  EvidenceResult _resultForRsi({
    required double rsi,
    required double reliability,
    required int candleCount,
  }) {
    if (rsi <= 20) {
      return _availableResult(
        rsi: rsi,
        direction: EvidenceDirection.bullish,
        strength: EvidenceStrength.exceptional,
        score: 95,
        reliability: reliability,
        candleCount: candleCount,
        explanation:
            'RSI is deeply oversold, indicating unusually strong downward momentum that may be vulnerable to reversal.',
      );
    }

    if (rsi <= 30) {
      return _availableResult(
        rsi: rsi,
        direction: EvidenceDirection.bullish,
        strength: EvidenceStrength.strong,
        score: 80,
        reliability: reliability,
        candleCount: candleCount,
        explanation:
            'RSI is in oversold territory, which may indicate a potential bullish reversal opportunity.',
      );
    }

    if (rsi >= 80) {
      return _availableResult(
        rsi: rsi,
        direction: EvidenceDirection.bearish,
        strength: EvidenceStrength.exceptional,
        score: 95,
        reliability: reliability,
        candleCount: candleCount,
        explanation:
            'RSI is deeply overbought, indicating unusually strong upward momentum that may be vulnerable to reversal.',
      );
    }

    if (rsi >= 70) {
      return _availableResult(
        rsi: rsi,
        direction: EvidenceDirection.bearish,
        strength: EvidenceStrength.strong,
        score: 80,
        reliability: reliability,
        candleCount: candleCount,
        explanation:
            'RSI is in overbought territory, which may indicate increased risk of a bearish pullback.',
      );
    }

    return _availableResult(
      rsi: rsi,
      direction: EvidenceDirection.neutral,
      strength: EvidenceStrength.moderate,
      score: 50,
      reliability: reliability,
      candleCount: candleCount,
      explanation:
          'RSI is within its neutral range and does not currently indicate an overbought or oversold condition.',
    );
  }

  EvidenceResult _availableResult({
    required double rsi,
    required EvidenceDirection direction,
    required EvidenceStrength strength,
    required double score,
    required double reliability,
    required int candleCount,
    required String explanation,
  }) {
    final reliabilityPercent = (reliability * 100).toStringAsFixed(0);

    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: strength,
      score: score,
      baseWeight: 0.8,
      dynamicWeight: 1,
      reliability: reliability,
      currentValue: rsi.toStringAsFixed(2),
      baselineValue: '30 oversold / 70 overbought',
      relativeValue: _relativeDescription(rsi),
      explanation:
          '$explanation Reliability is $reliabilityPercent%, based on '
          '$candleCount available candles and an RSI period of $period.',
    );
  }

  EvidenceResult _errorResult({required String reason}) {
    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.error,
      direction: EvidenceDirection.unknown,
      strength: EvidenceStrength.veryWeak,
      score: 0,
      baseWeight: 0.8,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'RSI $period',
      relativeValue: 'Not available',
      explanation: 'RSI could not be calculated.',
      unavailableReason: reason,
    );
  }

  String _relativeDescription(double rsi) {
    if (rsi <= 30) {
      return 'Oversold';
    }

    if (rsi >= 70) {
      return 'Overbought';
    }

    return 'Neutral';
  }
}

enum _SwingRsiTrendContext { bullish, bearish, mixed }

class _SwingRsiInterpretation {
  const _SwingRsiInterpretation({
    required this.direction,
    required this.strength,
    required this.score,
    required this.dynamicWeight,
    required this.label,
    required this.explanation,
  });

  final EvidenceDirection direction;
  final EvidenceStrength strength;
  final double score;
  final double dynamicWeight;
  final String label;
  final String explanation;
}
