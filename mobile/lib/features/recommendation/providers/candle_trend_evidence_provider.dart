import '../../market/models/market_snapshot.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_result.dart';
import 'evidence_provider.dart';

class CandleTrendEvidenceProvider implements EvidenceProvider {
  const CandleTrendEvidenceProvider();

  static const int _targetCandleCount = 48;

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    name: 'Candle Trend',
    description:
        'Measures the overall price direction by comparing the first and last closing prices in the analyzed candle sequence.',
    whyItMatters:
        'Strong directional movement often indicates sustained buying or selling pressure.',
    calculation:
        'Percentage change between the first closing price and the last closing price, combined with a reliability score based on sample size and trend efficiency.',
  );

  @override
  String get name => kDefinition.name;

  @override
  EvidenceDefinition get definition => kDefinition;

  @override
  EvidenceResult evaluate(MarketSnapshot snapshot) {
    if (snapshot.candles.length < 2) {
      return EvidenceResult(
        providerName: name,
        definition: definition,
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
        definition: definition,
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

    final reliabilityMetrics = _calculateReliability(snapshot);

    if (changePercent >= 5) {
      return _availableResult(
        changePercent: changePercent,
        direction: EvidenceDirection.bullish,
        strength: EvidenceStrength.exceptional,
        score: 95,
        reliabilityMetrics: reliabilityMetrics,
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
        reliabilityMetrics: reliabilityMetrics,
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
        reliabilityMetrics: reliabilityMetrics,
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
        reliabilityMetrics: reliabilityMetrics,
        explanation:
            'The recent candle sequence shows a moderate downward price trend.',
      );
    }

    return _availableResult(
      changePercent: changePercent,
      direction: EvidenceDirection.neutral,
      strength: EvidenceStrength.moderate,
      score: 50,
      reliabilityMetrics: reliabilityMetrics,
      explanation: 'The recent candle sequence is moving mostly sideways.',
    );
  }

  EvidenceResult _availableResult({
    required double changePercent,
    required EvidenceDirection direction,
    required EvidenceStrength strength,
    required double score,
    required _ReliabilityMetrics reliabilityMetrics,
    required String explanation,
  }) {
    final consistencyPercent = (reliabilityMetrics.trendEfficiency * 100)
        .toStringAsFixed(0);

    final reliabilityPercent = (reliabilityMetrics.reliability * 100)
        .toStringAsFixed(0);

    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: strength,
      score: score,
      baseWeight: 1,
      dynamicWeight: 1,
      reliability: reliabilityMetrics.reliability,
      currentValue: '${changePercent.toStringAsFixed(2)}%',
      baselineValue: 'First candle close',
      relativeValue: '${changePercent.toStringAsFixed(2)}%',
      explanation:
          '$explanation Reliability is $reliabilityPercent%, based on '
          '${reliabilityMetrics.candleCount} candles and '
          '$consistencyPercent% trend consistency.',
    );
  }

  _ReliabilityMetrics _calculateReliability(MarketSnapshot snapshot) {
    final candles = snapshot.candles;

    final sampleFactor = (candles.length / _targetCandleCount).clamp(0.0, 1.0);

    double totalPathDistance = 0;

    for (var index = 1; index < candles.length; index++) {
      totalPathDistance += (candles[index].close - candles[index - 1].close)
          .abs();
    }

    final netPriceChange = (candles.last.close - candles.first.close).abs();

    final trendEfficiency = totalPathDistance == 0
        ? 0.0
        : (netPriceChange / totalPathDistance).clamp(0.0, 1.0);

    final reliability =
        (0.10 + (sampleFactor * 0.40) + (trendEfficiency * 0.45)).clamp(
          0.10,
          0.95,
        );

    return _ReliabilityMetrics(
      reliability: reliability,
      trendEfficiency: trendEfficiency,
      candleCount: candles.length,
    );
  }
}

class _ReliabilityMetrics {
  const _ReliabilityMetrics({
    required this.reliability,
    required this.trendEfficiency,
    required this.candleCount,
  });

  final double reliability;
  final double trendEfficiency;
  final int candleCount;
}
