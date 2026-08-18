import '../../market/models/market_snapshot.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';
import '../utils/technical_indicator_math.dart';
import 'evidence_provider.dart';

class PriceExtensionEvidenceProvider implements EvidenceProvider {
  const PriceExtensionEvidenceProvider({
    this.emaPeriod = 21,
    this.atrPeriod = 14,
  });

  final int emaPeriod;
  final int atrPeriod;

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    kind: EvidenceKind.priceExtension,
    family: EvidenceFamily.volatility,
    name: 'Price Extension',
    description:
        'Measures how far price has stretched from its short-term equilibrium relative to the stock\'s own recent trading range.',
    whyItMatters:
        'A trend can still be bullish while being a poor entry if price has moved too far too quickly. Extension is therefore treated as entry-quality and risk evidence rather than another trend signal.',
    calculation:
        'TradePilot measures the latest price\'s distance from EMA 21 and divides that distance by ATR, producing a volatility-normalized extension measured in ATR units.',
  );

  @override
  String get name => kDefinition.name;

  @override
  EvidenceDefinition get definition => kDefinition;

  @override
  EvidenceResult evaluate(MarketSnapshot snapshot) {
    final candles = snapshot.candles;
    final requiredCandles = emaPeriod + 1;

    if (emaPeriod <= 0 || atrPeriod <= 0) {
      return _error('Price-extension periods must be positive.');
    }

    if (candles.length < requiredCandles) {
      return _insufficient(requiredCandles);
    }

    final closes = candles
        .map((candle) => candle.close)
        .toList(growable: false);
    final price = snapshot.currentPrice;
    final ema = TechnicalIndicatorMath.ema(closes, emaPeriod);
    final atr = TechnicalIndicatorMath.atr(candles, period: atrPeriod);

    if (price <= 0 || ema <= 0 || atr <= 0) {
      return _error(
        'Price extension requires positive price, EMA, and ATR values.',
      );
    }

    final extensionAtr = (price - ema) / atr;
    final magnitude = extensionAtr.abs();

    final direction = extensionAtr >= 1.50
        ? EvidenceDirection.bearish
        : extensionAtr <= -1.50
        ? EvidenceDirection.bullish
        : EvidenceDirection.neutral;

    final strength = direction == EvidenceDirection.neutral
        ? EvidenceStrength.weak
        : magnitude >= 2.50
        ? EvidenceStrength.strong
        : EvidenceStrength.moderate;

    final score = direction == EvidenceDirection.neutral
        ? 45.0
        : magnitude >= 2.50
        ? 80.0
        : 66.0;

    final reliability = (0.60 + ((candles.length / 48).clamp(0.0, 1.0) * 0.30))
        .clamp(0.60, 0.90);

    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: strength,
      score: score,
      baseWeight: 0.55,
      dynamicWeight: 1,
      reliability: reliability,
      currentValue:
          '${extensionAtr >= 0 ? '+' : ''}${extensionAtr.toStringAsFixed(2)} ATR',
      baselineValue:
          'EMA $emaPeriod ${ema.toStringAsFixed(2)} · ATR ${atr.toStringAsFixed(2)}',
      relativeValue:
          '${((price - ema) / ema * 100) >= 0 ? '+' : ''}${(((price - ema) / ema) * 100).toStringAsFixed(2)}% from EMA',
      explanation:
          '${direction == EvidenceDirection.bearish
              ? 'Price is materially extended above its short-term equilibrium, which increases chase risk for a new long entry.'
              : direction == EvidenceDirection.bullish
              ? 'Price is materially extended below its short-term equilibrium, which reduces conviction in chasing further downside.'
              : 'Price is within a normal ATR-adjusted distance from its short-term equilibrium.'} This evidence can oppose an otherwise strong trend without claiming the trend itself has reversed.',
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
      baseWeight: 0.55,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'At least $requiredCandles candles required',
      relativeValue: 'Not available',
      explanation:
          'There is not enough candle history to evaluate price extension.',
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
      baseWeight: 0.55,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'Price-extension calculation',
      relativeValue: 'Not available',
      explanation: 'Price extension could not be calculated.',
      unavailableReason: reason,
    );
  }
}
