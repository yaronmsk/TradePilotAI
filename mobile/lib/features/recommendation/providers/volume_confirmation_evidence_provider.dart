import '../../market/models/market_snapshot.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';
import '../utils/technical_indicator_math.dart';
import 'evidence_provider.dart';

class VolumeConfirmationEvidenceProvider implements EvidenceProvider {
  const VolumeConfirmationEvidenceProvider({this.lookback = 20});

  final int lookback;

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    kind: EvidenceKind.volumeConfirmation,
    family: EvidenceFamily.participation,
    name: 'Volume Confirmation',
    description:
        'Checks whether recent price movement is being confirmed by stronger or weaker trading participation.',
    whyItMatters:
        'A directional move with expanding participation is generally more convincing than the same move occurring on fading activity.',
    calculation:
        'TradePilot compares average volume in the recent half of the analysis window with the preceding half, then evaluates whether that participation change confirms or diverges from price direction.',
  );

  @override
  String get name => kDefinition.name;

  @override
  EvidenceDefinition get definition => kDefinition;

  @override
  EvidenceResult evaluate(MarketSnapshot snapshot) {
    final candles = snapshot.candles;

    if (lookback < 8) {
      return _error(
        'Volume confirmation lookback must be at least eight candles.',
      );
    }

    if (candles.length < 12) {
      return _insufficient();
    }

    final effectiveLookback = candles.length < lookback
        ? candles.length
        : lookback;
    final window = candles.sublist(candles.length - effectiveLookback);
    final split = window.length ~/ 2;
    final prior = window.sublist(0, split);
    final recent = window.sublist(split);

    final priorAverage = TechnicalIndicatorMath.average(
      prior.map((candle) => candle.volume),
    );
    final recentAverage = TechnicalIndicatorMath.average(
      recent.map((candle) => candle.volume),
    );

    if (priorAverage <= 0 || recentAverage <= 0 || window.first.close <= 0) {
      return _error(
        'Volume confirmation requires valid positive volume and price data.',
      );
    }

    final volumeRatio = recentAverage / priorAverage;
    final priceChangePercent =
        ((window.last.close - window.first.close) / window.first.close) * 100;
    final hasDirectionalMove = priceChangePercent.abs() >= 0.50;
    final expandingVolume = volumeRatio >= 1.15;
    final fadingVolume = volumeRatio <= 0.85;

    late final EvidenceDirection direction;
    late final EvidenceStrength strength;
    late final double score;
    late final String explanation;

    if (hasDirectionalMove && expandingVolume) {
      direction = priceChangePercent > 0
          ? EvidenceDirection.bullish
          : EvidenceDirection.bearish;
      strength = volumeRatio >= 1.50
          ? EvidenceStrength.strong
          : EvidenceStrength.moderate;
      score = volumeRatio >= 1.50 ? 82 : 68;
      explanation =
          'Recent participation is expanding in the same direction as price, confirming the move.';
    } else if (hasDirectionalMove && fadingVolume) {
      direction = priceChangePercent > 0
          ? EvidenceDirection.bearish
          : EvidenceDirection.bullish;
      strength = EvidenceStrength.moderate;
      score = 64;
      explanation =
          'Price is moving directionally while recent participation is fading, creating a volume divergence that weakens conviction.';
    } else {
      direction = EvidenceDirection.neutral;
      strength = EvidenceStrength.moderate;
      score = 50;
      explanation =
          'Recent volume is not changing enough to materially confirm or challenge the current price move.';
    }

    final reliability =
        (0.55 + ((window.length / lookback).clamp(0.0, 1.0) * 0.35)).clamp(
          0.55,
          0.90,
        );

    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: strength,
      score: score,
      baseWeight: 0.75,
      dynamicWeight: 1,
      reliability: reliability,
      currentValue: 'Recent avg ${_formatVolume(recentAverage)}',
      baselineValue: 'Prior avg ${_formatVolume(priorAverage)}',
      relativeValue:
          '${volumeRatio.toStringAsFixed(2)}x volume · ${priceChangePercent >= 0 ? '+' : ''}${priceChangePercent.toStringAsFixed(2)}% price',
      explanation:
          '$explanation Relative Volume and Volume Confirmation share the Participation evidence group, so they reinforce or challenge each other without being counted as two independent confirmations.',
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(2)}M';
    }
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    }
    return volume.toStringAsFixed(0);
  }

  EvidenceResult _insufficient() {
    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.insufficientData,
      direction: EvidenceDirection.unknown,
      strength: EvidenceStrength.veryWeak,
      score: 0,
      baseWeight: 0.75,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'At least 12 candles required',
      relativeValue: 'Not available',
      explanation:
          'There is not enough candle history to evaluate volume confirmation.',
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
      baseWeight: 0.75,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'Volume confirmation calculation',
      relativeValue: 'Not available',
      explanation: 'Volume confirmation could not be calculated.',
      unavailableReason: reason,
    );
  }
}
