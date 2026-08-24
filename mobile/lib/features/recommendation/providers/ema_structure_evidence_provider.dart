import '../../market/models/market_snapshot.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';
import '../models/strategy_summary.dart';
import '../strategy/ema_structure_strategy_policy.dart';
import '../utils/technical_indicator_math.dart';
import 'evidence_provider.dart';

class EmaStructureEvidenceProvider implements StrategyAwareEvidenceProvider {
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
        'Uses strategy-specific fast and slow EMA periods. It evaluates price/EMA ordering and structure strength. Swing also checks EMA slope, recent persistence, and ATR-normalized EMA separation.',
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

  @override
  EvidenceResult evaluateForStrategy(
    MarketSnapshot snapshot, {
    required StrategyType strategy,
  }) {
    return switch (strategy) {
      StrategyType.trader => evaluate(snapshot),
      StrategyType.swing => _evaluateSwing(snapshot),
      StrategyType.investor => _strategyUnavailable(
        'EMA Structure has not been calibrated for Investor yet.',
      ),
    };
  }

  EvidenceResult _evaluateSwing(MarketSnapshot snapshot) {
    final policy = EmaStructureStrategyPolicy.forStrategy(
      strategy: StrategyType.swing,
      timeframe: snapshot.timeframe,
    );

    if (policy == null) {
      return _strategyUnavailable(
        'Swing EMA Structure supports only the approved 1D and 4H primary intervals.',
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
      return _error('Swing EMA Structure requires positive closing prices.');
    }

    final fastSeries = TechnicalIndicatorMath.emaSeries(
      closes,
      policy.fastPeriod,
    );

    final slowSeries = TechnicalIndicatorMath.emaSeries(
      closes,
      policy.slowPeriod,
    );

    final price = closes.last;
    final fast = fastSeries.last;
    final slow = slowSeries.last;

    final slopeIndex = closes.length - 1 - policy.slopeLookback;
    final fastSlope = fast - fastSeries[slopeIndex];
    final slowSlope = slow - slowSeries[slopeIndex];

    final bullishStack = price > fast && fast > slow;
    final bearishStack = price < fast && fast < slow;

    var bullishPersistenceCount = 0;
    var bearishPersistenceCount = 0;

    final persistenceStart = closes.length - policy.persistenceLookback;

    for (var index = persistenceStart; index < closes.length; index++) {
      if (closes[index] > fastSeries[index] &&
          fastSeries[index] > slowSeries[index]) {
        bullishPersistenceCount++;
      }

      if (closes[index] < fastSeries[index] &&
          fastSeries[index] < slowSeries[index]) {
        bearishPersistenceCount++;
      }
    }

    final bullishPersistence =
        bullishPersistenceCount / policy.persistenceLookback;

    final bearishPersistence =
        bearishPersistenceCount / policy.persistenceLookback;

    final bullishConfirmed =
        bullishStack &&
        fastSlope > 0 &&
        slowSlope > 0 &&
        bullishPersistence >= policy.minimumPersistence;

    final bearishConfirmed =
        bearishStack &&
        fastSlope < 0 &&
        slowSlope < 0 &&
        bearishPersistence >= policy.minimumPersistence;

    final direction = bullishConfirmed
        ? EvidenceDirection.bullish
        : bearishConfirmed
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    final atr = TechnicalIndicatorMath.atr(candles, period: policy.atrPeriod);

    final normalizedSeparation = atr <= 0 ? 0.0 : (fast - slow).abs() / atr;

    final structureClarity = bullishPersistence > bearishPersistence
        ? bullishPersistence
        : bearishPersistence;

    final slopesMoveTogether =
        (fastSlope > 0 && slowSlope > 0) || (fastSlope < 0 && slowSlope < 0);

    final sampleFactor = (candles.length / policy.targetCandleCount).clamp(
      0.0,
      1.0,
    );

    final reliability =
        (0.30 +
                (sampleFactor * 0.25) +
                (structureClarity * 0.25) +
                ((slopesMoveTogether ? 1.0 : 0.0) * 0.15))
            .clamp(0.30, 0.95);

    final directional = direction != EvidenceDirection.neutral;

    final strength = !directional
        ? EvidenceStrength.moderate
        : normalizedSeparation >= policy.exceptionalSeparationAtr
        ? EvidenceStrength.exceptional
        : normalizedSeparation >= policy.strongSeparationAtr
        ? EvidenceStrength.strong
        : EvidenceStrength.moderate;

    final score = !directional
        ? 50.0
        : normalizedSeparation >= policy.exceptionalSeparationAtr
        ? 90.0
        : normalizedSeparation >= policy.strongSeparationAtr
        ? 78.0
        : 64.0;

    final persistence = direction == EvidenceDirection.bullish
        ? bullishPersistence
        : direction == EvidenceDirection.bearish
        ? bearishPersistence
        : structureClarity;

    final structureText = direction == EvidenceDirection.bullish
        ? 'Price > EMA ${policy.fastPeriod} > EMA ${policy.slowPeriod}'
        : direction == EvidenceDirection.bearish
        ? 'Price < EMA ${policy.fastPeriod} < EMA ${policy.slowPeriod}'
        : 'EMA structure is mixed or transitioning';

    final slopeText = fastSlope > 0 && slowSlope > 0
        ? 'Both EMAs are rising'
        : fastSlope < 0 && slowSlope < 0
        ? 'Both EMAs are falling'
        : 'EMA slopes are not aligned';

    final alignmentPercent = (persistence * 100).toStringAsFixed(0);

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
      currentValue: direction == EvidenceDirection.bullish
          ? 'Bullish EMA structure'
          : direction == EvidenceDirection.bearish
          ? 'Bearish EMA structure'
          : 'Mixed EMA structure',
      baselineValue:
          'EMA ${policy.fastPeriod} ${fast.toStringAsFixed(2)} · '
          'EMA ${policy.slowPeriod} ${slow.toStringAsFixed(2)}',
      relativeValue:
          '${normalizedSeparation.toStringAsFixed(2)}× ATR separation · '
          '$alignmentPercent% recent alignment',
      explanation:
          '$structureText. $slopeText. Recent structure alignment is '
          '$alignmentPercent%. EMA separation is '
          '${normalizedSeparation.toStringAsFixed(2)}× ATR. '
          'This remains Trend-family evidence and is de-duplicated '
          'with Candle Trend and other related trend signals.',
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
      baseWeight: 0.85,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'Strategy-specific EMA calibration required',
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
