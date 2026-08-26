import '../../market/models/market_snapshot.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';
import '../models/strategy_summary.dart';
import '../strategy/support_resistance_strategy_policy.dart';
import '../utils/technical_indicator_math.dart';
import 'evidence_provider.dart';

class SupportResistanceEvidenceProvider
    implements StrategyAwareEvidenceProvider {
  const SupportResistanceEvidenceProvider({this.lookback = 30});

  final int lookback;

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    kind: EvidenceKind.supportResistance,
    family: EvidenceFamily.priceStructure,
    name: 'Support & Resistance',
    description:
        'Measures where the latest price sits relative to recent support and resistance levels derived from prior candle highs and lows.',
    whyItMatters:
        'Price near a meaningful level can affect entry quality and risk, while a confirmed rejection, breakout or breakdown can strengthen directional evidence.',
    calculation:
        'Trader preserves its validated local high/low and ATR behavior. Swing derives structure from prior candles, excludes confirmation candles from level construction, and requires strategy-specific confirmation before a level can create directional evidence.',
  );

  @override
  String get name => kDefinition.name;

  @override
  EvidenceDefinition get definition => kDefinition;

  // ----------------------------------------------------------
  // Validated Trader behavior — intentionally unchanged.
  // ----------------------------------------------------------

  @override
  EvidenceResult evaluate(MarketSnapshot snapshot) {
    final candles = snapshot.candles;

    if (lookback < 5) {
      return _error(
        'Support/resistance lookback must be at least five candles.',
      );
    }

    if (candles.length < 12) {
      return _insufficient();
    }

    final priorCandles = candles.sublist(0, candles.length - 1);
    final start = (priorCandles.length - lookback)
        .clamp(0, priorCandles.length)
        .toInt();

    final window = priorCandles.sublist(start);

    final support = window
        .map((candle) => candle.low)
        .reduce((value, candidate) => candidate < value ? candidate : value);

    final resistance = window
        .map((candle) => candle.high)
        .reduce((value, candidate) => candidate > value ? candidate : value);

    final price = snapshot.currentPrice;
    final atr = TechnicalIndicatorMath.atr(candles, period: 14);

    if (price <= 0 || atr <= 0 || support <= 0 || resistance <= 0) {
      return _error('Support/resistance requires valid positive price ranges.');
    }

    final breakoutBuffer = atr * 0.15;
    final proximity = atr * 0.35;

    final aboveResistance = price > resistance + breakoutBuffer;
    final belowSupport = price < support - breakoutBuffer;

    final nearResistance =
        !aboveResistance && (resistance - price).abs() <= proximity;

    final nearSupport = !belowSupport && (price - support).abs() <= proximity;

    late final EvidenceDirection direction;
    late final EvidenceStrength strength;
    late final double score;
    late final String explanation;

    if (aboveResistance) {
      direction = EvidenceDirection.bullish;
      strength = EvidenceStrength.strong;
      score = 84;
      explanation =
          'Price has broken above recent resistance by more than the ATR-normalized breakout buffer.';
    } else if (belowSupport) {
      direction = EvidenceDirection.bearish;
      strength = EvidenceStrength.strong;
      score = 84;
      explanation =
          'Price has broken below recent support by more than the ATR-normalized breakout buffer.';
    } else if (nearResistance && !nearSupport) {
      direction = EvidenceDirection.bearish;
      strength = EvidenceStrength.moderate;
      score = 64;
      explanation =
          'Price is close to recent resistance, which can limit upside unless the level is broken with confirmation.';
    } else if (nearSupport && !nearResistance) {
      direction = EvidenceDirection.bullish;
      strength = EvidenceStrength.moderate;
      score = 64;
      explanation =
          'Price is close to recent support, which can improve entry structure if the level continues to hold.';
    } else {
      direction = EvidenceDirection.neutral;
      strength = EvidenceStrength.moderate;
      score = 50;
      explanation =
          'Price is between recent support and resistance without a confirmed breakout or immediate level test.';
    }

    final distanceToResistance = ((resistance - price) / price) * 100;
    final distanceToSupport = ((price - support) / price) * 100;

    final reliability =
        (0.60 + ((window.length / lookback).clamp(0.0, 1.0) * 0.30)).clamp(
          0.60,
          0.90,
        );

    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: strength,
      score: score,
      baseWeight: 0.80,
      dynamicWeight: 1,
      reliability: reliability,
      currentValue: 'Price ${price.toStringAsFixed(2)}',
      baselineValue:
          'Support ${support.toStringAsFixed(2)} · '
          'Resistance ${resistance.toStringAsFixed(2)}',
      relativeValue:
          '${distanceToSupport.toStringAsFixed(2)}% above support · '
          '${distanceToResistance.toStringAsFixed(2)}% below resistance',
      explanation:
          '$explanation These levels are local analysis-window levels, not guaranteed barriers.',
    );
  }

  // ----------------------------------------------------------
  // Strategy-aware path
  // ----------------------------------------------------------

  @override
  EvidenceResult evaluateForStrategy(
    MarketSnapshot snapshot, {
    required StrategyType strategy,
  }) {
    return switch (strategy) {
      StrategyType.trader => evaluate(snapshot),
      StrategyType.swing => _evaluateSwing(snapshot),
      StrategyType.investor => _strategyUnavailable(
        'Support & Resistance has not been calibrated for Investor yet.',
      ),
    };
  }

  EvidenceResult _evaluateSwing(MarketSnapshot snapshot) {
    final policy = SupportResistanceStrategyPolicy.forStrategy(
      strategy: StrategyType.swing,
      timeframe: snapshot.timeframe,
    );

    if (policy == null) {
      return _strategyUnavailable(
        'Swing Support & Resistance supports only the approved 1D and 4H primary intervals.',
      );
    }

    final candles = snapshot.candles;

    if (candles.length < policy.minimumCandles) {
      return _swingInsufficient(policy);
    }

    if (candles.length <= policy.confirmationCloses) {
      return _swingInsufficient(policy);
    }

    final referenceEnd = candles.length - policy.confirmationCloses;

    final referenceCandles = candles.sublist(0, referenceEnd);

    final start = (referenceCandles.length - policy.structureLookback)
        .clamp(0, referenceCandles.length)
        .toInt();

    final structureWindow = referenceCandles.sublist(start);

    if (structureWindow.length < 5) {
      return _swingInsufficient(policy);
    }

    final support = structureWindow
        .map((candle) => candle.low)
        .reduce((value, candidate) => candidate < value ? candidate : value);

    final resistance = structureWindow
        .map((candle) => candle.high)
        .reduce((value, candidate) => candidate > value ? candidate : value);

    final price = snapshot.currentPrice;

    final atr = TechnicalIndicatorMath.atr(candles, period: policy.atrPeriod);

    if (price <= 0 ||
        atr <= 0 ||
        support <= 0 ||
        resistance <= 0 ||
        resistance <= support) {
      return _error(
        'Swing Support & Resistance requires valid positive structure and ATR data.',
      );
    }

    final confirmationCandles = candles.sublist(referenceEnd);

    final breakoutBuffer = atr * policy.breakoutBufferAtr;

    final proximity = atr * policy.proximityAtr;

    final rejectionCloseBuffer = atr * policy.rejectionCloseAtr;

    final confirmedBreakout = confirmationCandles.every(
      (candle) => candle.close > resistance + breakoutBuffer,
    );

    final confirmedBreakdown = confirmationCandles.every(
      (candle) => candle.close < support - breakoutBuffer,
    );

    final latest = candles.last;

    final supportRejection =
        !confirmedBreakdown &&
        latest.low <= support + proximity &&
        latest.close >= support + rejectionCloseBuffer &&
        latest.close > latest.open;

    final resistanceRejection =
        !confirmedBreakout &&
        latest.high >= resistance - proximity &&
        latest.close <= resistance - rejectionCloseBuffer &&
        latest.close < latest.open;

    final nearSupport =
        !confirmedBreakdown && (price - support).abs() <= proximity;

    final nearResistance =
        !confirmedBreakout && (resistance - price).abs() <= proximity;

    final breakAboveAtr = (price - resistance) / atr;

    final breakBelowAtr = (support - price) / atr;

    late final EvidenceDirection direction;
    late final EvidenceStrength strength;
    late final double score;
    late final String explanation;

    if (confirmedBreakout) {
      direction = EvidenceDirection.bullish;

      final strong = breakAboveAtr >= policy.strongBreakDistanceAtr;

      strength = strong ? EvidenceStrength.strong : EvidenceStrength.moderate;

      score = strong ? 90 : 78;

      explanation =
          'Price closed above structural resistance for '
          '${policy.confirmationCloses} consecutive '
          '${policy.timeframe.toUpperCase()} candles, confirming a Swing breakout.';
    } else if (confirmedBreakdown) {
      direction = EvidenceDirection.bearish;

      final strong = breakBelowAtr >= policy.strongBreakDistanceAtr;

      strength = strong ? EvidenceStrength.strong : EvidenceStrength.moderate;

      score = strong ? 90 : 78;

      explanation =
          'Price closed below structural support for '
          '${policy.confirmationCloses} consecutive '
          '${policy.timeframe.toUpperCase()} candles, confirming a Swing breakdown.';
    } else if (supportRejection && !resistanceRejection) {
      direction = EvidenceDirection.bullish;
      strength = EvidenceStrength.moderate;
      score = 70;

      explanation =
          'Price tested the structural support area and closed decisively back above it with a bullish candle. This is rejection/hold evidence, not support proximity alone.';
    } else if (resistanceRejection && !supportRejection) {
      direction = EvidenceDirection.bearish;
      strength = EvidenceStrength.moderate;
      score = 70;

      explanation =
          'Price tested the structural resistance area and closed decisively back below it with a bearish candle. This is rejection evidence, not resistance proximity alone.';
    } else if (nearSupport || nearResistance) {
      direction = EvidenceDirection.neutral;
      strength = EvidenceStrength.weak;
      score = 50;

      if (nearSupport && !nearResistance) {
        explanation =
            'Price is near structural support. For Swing this is entry/risk context only until a hold, rejection or breakdown is actually confirmed.';
      } else if (nearResistance && !nearSupport) {
        explanation =
            'Price is near structural resistance. For Swing this is entry/risk context only until a rejection or breakout is actually confirmed.';
      } else {
        explanation =
            'Price is close to both local structure boundaries. Proximity alone is directionally neutral and is treated as entry/risk context.';
      }
    } else {
      direction = EvidenceDirection.neutral;
      strength = EvidenceStrength.moderate;
      score = 50;

      explanation =
          'Price is between the active Swing support and resistance levels without a confirmed structural event.';
    }

    final sampleFactor = (structureWindow.length / policy.structureLookback)
        .clamp(0.0, 1.0)
        .toDouble();

    final reliability = (0.60 + (sampleFactor * 0.30))
        .clamp(0.60, policy.maximumReliability)
        .toDouble();

    final supportDistanceAtr = (price - support) / atr;

    final resistanceDistanceAtr = (resistance - price) / atr;

    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: strength,
      score: score,
      baseWeight: 0.80,
      dynamicWeight: 1,
      reliability: reliability,
      currentValue: 'Price ${price.toStringAsFixed(2)}',
      baselineValue:
          'Support ${support.toStringAsFixed(2)} · '
          'Resistance ${resistance.toStringAsFixed(2)} · '
          '${structureWindow.length}-candle structure',
      relativeValue:
          '${supportDistanceAtr.toStringAsFixed(2)} ATR above support · '
          '${resistanceDistanceAtr.toStringAsFixed(2)} ATR below resistance',
      explanation:
          '$explanation Levels are derived only from candles preceding the confirmation window. They are local structural references, not guaranteed barriers.',
    );
  }

  EvidenceResult _insufficient() {
    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.insufficientData,
      direction: EvidenceDirection.unknown,
      strength: EvidenceStrength.veryWeak,
      score: 0,
      baseWeight: 0.80,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'At least 12 candles required',
      relativeValue: 'Not available',
      explanation:
          'There is not enough candle history to estimate local support and resistance.',
      unavailableReason: 'At least 12 candles are required.',
    );
  }

  EvidenceResult _swingInsufficient(SupportResistanceStrategyPolicy policy) {
    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.insufficientData,
      direction: EvidenceDirection.unknown,
      strength: EvidenceStrength.veryWeak,
      score: 0,
      baseWeight: 0.80,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue:
          'At least ${policy.minimumCandles} '
          '${policy.timeframe.toUpperCase()} candles required',
      relativeValue: 'Not available',
      explanation:
          'There is not enough history to establish Swing structure and reserve the required confirmation window.',
      unavailableReason:
          'At least ${policy.minimumCandles} candles are required for '
          '${policy.timeframe.toUpperCase()} Swing Support & Resistance.',
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
      baseWeight: 0.80,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'Strategy-specific structural policy required',
      relativeValue: 'Not available',
      explanation: reason,
      unavailableReason: reason,
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
      baseWeight: 0.80,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'Support/resistance calculation',
      relativeValue: 'Not available',
      explanation: 'Support and resistance could not be calculated.',
      unavailableReason: reason,
    );
  }
}
