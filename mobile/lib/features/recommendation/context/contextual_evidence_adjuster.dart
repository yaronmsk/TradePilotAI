import '../models/evidence_definition.dart';
import '../models/evidence_result.dart';
import 'stock_behavior_profile.dart';

class ContextualEvidenceAdjuster {
  const ContextualEvidenceAdjuster();

  List<EvidenceResult> adjust({
    required List<EvidenceResult> results,
    required StockBehaviorProfile profile,
  }) {
    if (!profile.hasSufficientData) {
      return List<EvidenceResult>.unmodifiable(results);
    }

    return List<EvidenceResult>.unmodifiable(
      results.map((result) => _adjustEvidence(result, profile)),
    );
  }

  EvidenceResult _adjustEvidence(
    EvidenceResult evidence,
    StockBehaviorProfile profile,
  ) {
    if (!evidence.isAvailable) {
      return evidence;
    }

    double multiplier = 1;
    String? contextReason;

    switch (evidence.definition.kind) {
      case EvidenceKind.candleTrend:
        if (profile.behaviorType == StockBehaviorType.volatile) {
          if (profile.trendEfficiency >= 0.65) {
            multiplier = 1.15;
            contextReason =
                'Trend evidence receives more weight because this volatile stock is moving directionally rather than randomly.';
          } else {
            multiplier = 0.75;
            contextReason =
                'Trend evidence receives less weight because this volatile stock is currently noisy and directionally inconsistent.';
          }
        }
        break;

      case EvidenceKind.rsi:
        if (profile.behaviorType == StockBehaviorType.steady) {
          multiplier = 1.10;
          contextReason =
              'RSI receives slightly more weight because mean-reversion signals are more informative in a steadier price profile.';
        } else if (profile.behaviorType == StockBehaviorType.volatile) {
          multiplier = 0.75;
          contextReason =
              'RSI receives less weight because overbought and oversold readings occur more frequently in volatile stocks.';
        }

        if (profile.trendEfficiency >= 0.70) {
          multiplier *= 0.80;
          contextReason =
              'RSI is discounted because the current move is strongly directional, where extreme RSI readings can persist instead of reversing immediately.';
        }
        break;

      case EvidenceKind.relativeVolume:
        if (profile.relativeVolume >= 2) {
          multiplier = 1.30;
          contextReason =
              'Volume evidence receives more weight because current activity is at least twice the stock\'s recent average.';
        } else if (profile.relativeVolume >= 1.50) {
          multiplier = 1.15;
          contextReason =
              'Volume evidence receives more weight because trading activity is materially above the stock\'s recent average.';
        } else if (profile.relativeVolume <= 0.70) {
          multiplier = 0.75;
          contextReason =
              'Volume evidence receives less weight because current activity is unusually light.';
        }
        break;

      case EvidenceKind.generic:
        break;
    }

    if (profile.volatilityRegime == VolatilityRegime.elevated &&
        evidence.definition.kind == EvidenceKind.rsi) {
      multiplier *= 0.90;
      contextReason =
          'RSI is further discounted because short-term volatility is elevated relative to this stock\'s own recent baseline.';
    }

    final adjustedWeight = (evidence.dynamicWeight * multiplier).clamp(
      0.50,
      1.50,
    );

    if (contextReason == null || adjustedWeight == evidence.dynamicWeight) {
      return evidence;
    }

    return evidence.copyWith(
      dynamicWeight: adjustedWeight,
      explanation: '${evidence.explanation} Context adjustment: $contextReason',
    );
  }
}
