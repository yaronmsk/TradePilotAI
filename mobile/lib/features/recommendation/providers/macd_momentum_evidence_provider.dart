import '../../market/models/market_snapshot.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';
import '../utils/technical_indicator_math.dart';
import 'evidence_provider.dart';

class MacdMomentumEvidenceProvider implements EvidenceProvider {
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
        'MACD = fast EMA minus slow EMA. The signal line is an EMA of MACD. TradePilot evaluates the MACD/signal relationship and normalizes histogram strength by the current stock price.',
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
