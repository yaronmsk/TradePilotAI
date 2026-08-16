import '../../market/models/market_snapshot.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_result.dart';
import 'evidence_provider.dart';

class RsiEvidenceProvider implements EvidenceProvider {
  const RsiEvidenceProvider({this.period = 14});

  final int period;

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    kind: EvidenceKind.rsi,
    name: 'RSI',
    description:
        'Measures the speed and magnitude of recent price changes on a scale from 0 to 100.',
    whyItMatters:
        'RSI can help identify when price momentum may be stretched toward overbought or oversold conditions.',
    calculation:
        'RSI is calculated from average gains and average losses over the selected lookback period using the Relative Strength Index formula.',
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
