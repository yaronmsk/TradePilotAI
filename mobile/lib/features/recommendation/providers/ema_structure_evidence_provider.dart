import '../../market/models/market_snapshot.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';
import '../utils/technical_indicator_math.dart';
import 'evidence_provider.dart';

class EmaStructureEvidenceProvider implements EvidenceProvider {
  const EmaStructureEvidenceProvider({
    this.fastPeriod = 9,
    this.slowPeriod = 21,
  });

  final int fastPeriod;
  final int slowPeriod;

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    kind: EvidenceKind.emaStructure,
    family: EvidenceFamily.trend,
    name: 'EMA Structure',
    description:
        'Checks whether price and fast/slow exponential moving averages are stacked in a bullish, bearish, or mixed order.',
    whyItMatters:
        'A clean moving-average structure can confirm whether short-term price action is aligned with the underlying trend rather than moving randomly.',
    calculation:
        'Compares the latest price with a fast EMA and a slow EMA. Strength is based on the normalized distance between the averages and price.',
  );

  @override
  String get name => kDefinition.name;

  @override
  EvidenceDefinition get definition => kDefinition;

  @override
  EvidenceResult evaluate(MarketSnapshot snapshot) {
    final candles = snapshot.candles;
    final requiredCandles = slowPeriod + 1;

    if (fastPeriod <= 0 || slowPeriod <= fastPeriod) {
      return _error('EMA periods must be positive and slow must exceed fast.');
    }

    if (candles.length < requiredCandles) {
      return _insufficient(requiredCandles);
    }

    final closes = candles
        .map((candle) => candle.close)
        .toList(growable: false);
    final price = closes.last;

    if (price <= 0) {
      return _error('EMA structure requires a positive latest price.');
    }

    final fast = TechnicalIndicatorMath.ema(closes, fastPeriod);
    final slow = TechnicalIndicatorMath.ema(closes, slowPeriod);
    final spreadPercent = ((fast - slow) / price) * 100;
    final priceToFastPercent = ((price - fast) / price) * 100;
    final magnitude = spreadPercent.abs() + priceToFastPercent.abs();

    final bullish = price > fast && fast > slow;
    final bearish = price < fast && fast < slow;

    final reliability = (0.55 + ((candles.length / 48).clamp(0.0, 1.0) * 0.35))
        .clamp(0.55, 0.90);

    final direction = bullish
        ? EvidenceDirection.bullish
        : bearish
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    final strength = direction == EvidenceDirection.neutral
        ? EvidenceStrength.moderate
        : magnitude >= 1.50
        ? EvidenceStrength.exceptional
        : magnitude >= 0.70
        ? EvidenceStrength.strong
        : EvidenceStrength.moderate;

    final score = direction == EvidenceDirection.neutral
        ? 50.0
        : magnitude >= 1.50
        ? 90.0
        : magnitude >= 0.70
        ? 78.0
        : 64.0;

    final structureText = bullish
        ? 'Price > EMA $fastPeriod > EMA $slowPeriod'
        : bearish
        ? 'Price < EMA $fastPeriod < EMA $slowPeriod'
        : 'Moving averages are mixed';

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
      currentValue: 'Price ${price.toStringAsFixed(2)}',
      baselineValue:
          'EMA $fastPeriod ${fast.toStringAsFixed(2)} · EMA $slowPeriod ${slow.toStringAsFixed(2)}',
      relativeValue:
          '${spreadPercent >= 0 ? '+' : ''}${spreadPercent.toStringAsFixed(2)}% EMA spread',
      explanation:
          '$structureText. This is trend-family evidence, so it confirms or challenges other trend signals without counting as a separate independent trend vote.',
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
      explanation:
          'There is not enough candle history to evaluate EMA structure.',
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
      baselineValue: 'EMA calculation',
      relativeValue: 'Not available',
      explanation: 'EMA structure could not be calculated.',
      unavailableReason: reason,
    );
  }
}
