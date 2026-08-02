import '../../market/models/market_snapshot.dart';
import '../models/evidence_result.dart';
import 'evidence_provider.dart';

class CandleTrendEvidenceProvider implements EvidenceProvider {
  const CandleTrendEvidenceProvider();

  @override
  String get name => 'Candle Trend';

  @override
  EvidenceResult evaluate(MarketSnapshot snapshot) {
    if (snapshot.candles.length < 2) {
      return EvidenceResult(
        providerName: name,
        status: EvidenceStatus.insufficientData,
        direction: EvidenceDirection.unknown,
        strength: EvidenceStrength.veryWeak,
        score: 0,
        baseWeight: 1,
        dynamicWeight: 1,
        reliability: 0,
        currentValue: 'Not available',
        baselineValue: 'At least 2 candles required',
        relativeValue: 'Not available',
        explanation:
            'There is not enough candle history to evaluate the trend.',
        unavailableReason: 'At least two candles are required.',
      );
    }

    final firstClose = snapshot.candles.first.close;
    final lastClose = snapshot.candles.last.close;

    if (firstClose <= 0) {
      return EvidenceResult(
        providerName: name,
        status: EvidenceStatus.error,
        direction: EvidenceDirection.unknown,
        strength: EvidenceStrength.veryWeak,
        score: 0,
        baseWeight: 1,
        dynamicWeight: 1,
        reliability: 0,
        currentValue: 'Invalid candle data',
        baselineValue: 'First close must be above zero',
        relativeValue: 'Not available',
        explanation: 'The candle trend could not be calculated.',
        unavailableReason: 'The first closing price is invalid.',
      );
    }

    final changePercent = ((lastClose - firstClose) / firstClose) * 100;

    if (changePercent >= 5) {
      return _availableResult(
        changePercent: changePercent,
        direction: EvidenceDirection.bullish,
        strength: EvidenceStrength.exceptional,
        score: 95,
        explanation:
            'The recent candle sequence shows a strong upward price trend.',
      );
    }

    if (changePercent >= 2) {
      return _availableResult(
        changePercent: changePercent,
        direction: EvidenceDirection.bullish,
        strength: EvidenceStrength.strong,
        score: 80,
        explanation:
            'The recent candle sequence shows a moderate upward price trend.',
      );
    }

    if (changePercent <= -5) {
      return _availableResult(
        changePercent: changePercent,
        direction: EvidenceDirection.bearish,
        strength: EvidenceStrength.exceptional,
        score: 95,
        explanation:
            'The recent candle sequence shows a strong downward price trend.',
      );
    }

    if (changePercent <= -2) {
      return _availableResult(
        changePercent: changePercent,
        direction: EvidenceDirection.bearish,
        strength: EvidenceStrength.strong,
        score: 80,
        explanation:
            'The recent candle sequence shows a moderate downward price trend.',
      );
    }

    return _availableResult(
      changePercent: changePercent,
      direction: EvidenceDirection.neutral,
      strength: EvidenceStrength.moderate,
      score: 50,
      explanation: 'The recent candle sequence is moving mostly sideways.',
    );
  }

  EvidenceResult _availableResult({
    required double changePercent,
    required EvidenceDirection direction,
    required EvidenceStrength strength,
    required double score,
    required String explanation,
  }) {
    return EvidenceResult(
      providerName: name,
      status: EvidenceStatus.available,
      direction: direction,
      strength: strength,
      score: score,
      baseWeight: 1,
      dynamicWeight: 1,
      reliability: 0.75,
      currentValue: '${changePercent.toStringAsFixed(2)}%',
      baselineValue: 'First candle close',
      relativeValue: '${changePercent.toStringAsFixed(2)}%',
      explanation: explanation,
    );
  }
}
