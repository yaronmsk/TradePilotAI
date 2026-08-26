import '../../market/models/market_snapshot.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';
import '../models/strategy_summary.dart';
import '../strategy/price_extension_strategy_policy.dart';
import '../utils/technical_indicator_math.dart';
import 'evidence_provider.dart';

class PriceExtensionEvidenceProvider implements StrategyAwareEvidenceProvider {
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
        'Measures how far price has stretched from its equilibrium relative to the stock\'s own recent trading range.',
    whyItMatters:
        'A trend can remain directionally valid while price becomes a poor entry because it has moved too far too quickly.',
    calculation:
        'Trader preserves the validated EMA 21 and ATR calculation. Swing measures distance from its strategy-specific EMA reference in ATR units and uses the magnitude only for entry-quality, confidence and risk interpretation.',
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
          '${extensionAtr >= 0 ? '+' : ''}'
          '${extensionAtr.toStringAsFixed(2)} ATR',
      baselineValue:
          'EMA $emaPeriod ${ema.toStringAsFixed(2)} · '
          'ATR ${atr.toStringAsFixed(2)}',
      relativeValue:
          '${((price - ema) / ema * 100) >= 0 ? '+' : ''}'
          '${(((price - ema) / ema) * 100).toStringAsFixed(2)}% from EMA',
      explanation:
          '${direction == EvidenceDirection.bearish
              ? 'Price is materially extended above its short-term equilibrium, which increases chase risk for a new long entry.'
              : direction == EvidenceDirection.bullish
              ? 'Price is materially extended below its short-term equilibrium, which reduces conviction in chasing further downside.'
              : 'Price is within a normal ATR-adjusted distance from its short-term equilibrium.'} '
          'This evidence can oppose an otherwise strong trend without claiming the trend itself has reversed.',
    );
  }

  // ----------------------------------------------------------
  // Swing confidence / entry-quality path
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
        'Price Extension has not been calibrated for Investor yet.',
      ),
    };
  }

  EvidenceResult _evaluateSwing(MarketSnapshot snapshot) {
    final policy = PriceExtensionStrategyPolicy.forStrategy(
      strategy: StrategyType.swing,
      timeframe: snapshot.timeframe,
    );

    if (policy == null) {
      return _strategyUnavailable(
        'Swing Price Extension supports only the approved 1D and 4H primary intervals.',
      );
    }

    final candles = snapshot.candles;

    if (candles.length < policy.minimumCandles) {
      return _swingInsufficient(policy);
    }

    final closes = candles
        .map((candle) => candle.close)
        .toList(growable: false);

    final price = snapshot.currentPrice;

    final ema = TechnicalIndicatorMath.ema(closes, policy.referenceEmaPeriod);

    final atr = TechnicalIndicatorMath.atr(candles, period: policy.atrPeriod);

    if (price <= 0 || ema <= 0 || atr <= 0) {
      return _error(
        'Swing Price Extension requires positive price, EMA, and ATR values.',
      );
    }

    final extensionAtr = (price - ema) / atr;
    final magnitude = extensionAtr.abs();

    late final String stretchLabel;
    late final EvidenceStrength strength;
    late final double score;
    late final String explanation;

    if (magnitude >= policy.veryExtendedAtr) {
      stretchLabel = 'Very extended';
      strength = EvidenceStrength.veryWeak;
      score = policy.veryExtendedQualityScore;
      explanation =
          'Entry stretch is very high relative to recent volatility. '
          'Chasing a new Swing entry here carries materially worse entry quality.';
    } else if (magnitude >= policy.extendedAtr) {
      stretchLabel = 'Extended';
      strength = EvidenceStrength.weak;
      score = policy.extendedQualityScore;
      explanation =
          'Price is meaningfully extended from the Swing equilibrium reference. '
          'Entry quality is reduced even if the active trend remains valid.';
    } else if (magnitude >= policy.elevatedExtensionAtr) {
      stretchLabel = 'Elevated';
      strength = EvidenceStrength.moderate;
      score = policy.elevatedQualityScore;
      explanation =
          'Price is somewhat stretched from the Swing equilibrium reference. '
          'This adds moderate chase risk but does not imply reversal.';
    } else {
      stretchLabel = 'Normal';
      strength = EvidenceStrength.moderate;
      score = policy.normalQualityScore;
      explanation =
          'Price is within a normal volatility-adjusted distance from the '
          'Swing equilibrium reference, so extension is not currently a '
          'meaningful entry-quality concern.';
    }

    final sampleFactor = (candles.length / policy.targetCandles)
        .clamp(0.0, 1.0)
        .toDouble();

    final reliability = (0.60 + (sampleFactor * 0.28))
        .clamp(0.60, policy.maximumReliability)
        .toDouble();

    final percentFromEma = ((price - ema) / ema) * 100;

    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.available,

      // Permanent Swing rule:
      // extension never creates bullish/bearish reversal direction.
      direction: EvidenceDirection.neutral,

      strength: strength,
      score: score,
      baseWeight: 0.55,
      dynamicWeight: 1,
      reliability: reliability,
      currentValue:
          '${extensionAtr >= 0 ? '+' : ''}'
          '${extensionAtr.toStringAsFixed(2)} ATR',
      baselineValue:
          'EMA ${policy.referenceEmaPeriod} '
          '${ema.toStringAsFixed(2)} · '
          'ATR ${atr.toStringAsFixed(2)}',
      relativeValue:
          '$stretchLabel · '
          '${percentFromEma >= 0 ? '+' : ''}'
          '${percentFromEma.toStringAsFixed(2)}% from EMA',
      explanation:
          '$explanation '
          'The sign shows whether price is above or below the reference, '
          'but Swing Price Extension itself remains directionally neutral. '
          'It cannot create or flip BUY/SELL direction.',
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

  EvidenceResult _swingInsufficient(PriceExtensionStrategyPolicy policy) {
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
      baselineValue:
          'At least ${policy.minimumCandles} '
          '${policy.timeframe.toUpperCase()} candles required',
      relativeValue: 'Not available',
      explanation:
          'There is not enough history to establish the approved Swing '
          'equilibrium and volatility baseline.',
      unavailableReason:
          'At least ${policy.minimumCandles} candles are required for '
          '${policy.timeframe.toUpperCase()} Swing Price Extension.',
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
      baseWeight: 0.55,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'Strategy-specific extension policy required',
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
