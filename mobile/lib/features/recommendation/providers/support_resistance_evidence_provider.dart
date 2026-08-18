import '../../market/models/market_snapshot.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';
import '../utils/technical_indicator_math.dart';
import 'evidence_provider.dart';

class SupportResistanceEvidenceProvider implements EvidenceProvider {
  const SupportResistanceEvidenceProvider({this.lookback = 30});

  final int lookback;

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    kind: EvidenceKind.supportResistance,
    family: EvidenceFamily.priceStructure,
    name: 'Support & Resistance',
    description:
        'Measures where the latest price sits relative to recent support and resistance levels derived from prior candle highs and lows.',
    whyItMatters:
        'Price near a meaningful level can face rejection or find support, while a clean break beyond a recent level can strengthen a directional setup.',
    calculation:
        'TradePilot uses recent prior-candle highs and lows as deterministic local resistance and support, then normalizes distance and breakout thresholds with ATR.',
  );

  @override
  String get name => kDefinition.name;

  @override
  EvidenceDefinition get definition => kDefinition;

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
          'Support ${support.toStringAsFixed(2)} · Resistance ${resistance.toStringAsFixed(2)}',
      relativeValue:
          '${distanceToSupport.toStringAsFixed(2)}% above support · ${distanceToResistance.toStringAsFixed(2)}% below resistance',
      explanation:
          '$explanation These levels are local analysis-window levels, not guaranteed barriers.',
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
