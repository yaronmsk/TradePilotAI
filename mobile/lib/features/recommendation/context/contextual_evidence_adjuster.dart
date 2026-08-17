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
    final reasons = <String>[];

    switch (evidence.definition.kind) {
      case EvidenceKind.candleTrend:
        if (profile.behaviorType == StockBehaviorType.volatile) {
          if (profile.trendEfficiency >= 0.65) {
            multiplier = 1.15;
            reasons.add(
              'Trend evidence receives more weight because this volatile stock is moving directionally rather than randomly.',
            );
          } else {
            multiplier = 0.75;
            reasons.add(
              'Trend evidence receives less weight because this volatile stock is currently noisy and directionally inconsistent.',
            );
          }
        }

        if (profile.hasHistoricalBaseline &&
            profile.volatilityRegime == VolatilityRegime.elevated) {
          if (profile.trendEfficiency >= 0.65 &&
              profile.relativeVolume >= 1.20) {
            multiplier *= 1.10;
            reasons.add(
              'The move also has participation while volatility is high versus the stock\'s own one-year history, which strengthens directional confirmation.',
            );
          } else if (profile.trendEfficiency < 0.55) {
            multiplier *= 0.85;
            reasons.add(
              'Current volatility is high versus the stock\'s own history without a clean directional path, so trend conviction is reduced.',
            );
          }
        }
        break;

      case EvidenceKind.rsi:
        if (profile.behaviorType == StockBehaviorType.steady) {
          multiplier = 1.10;
          reasons.add(
            'RSI receives slightly more weight because mean-reversion signals are more informative in a steadier price profile.',
          );
        } else if (profile.behaviorType == StockBehaviorType.volatile) {
          multiplier = 0.75;
          reasons.add(
            'RSI receives less weight because overbought and oversold readings occur more frequently in volatile stocks.',
          );
        }

        if (profile.trendEfficiency >= 0.70) {
          multiplier *= 0.80;
          reasons.add(
            'RSI is discounted because the current move is strongly directional, where extreme RSI readings can persist instead of reversing immediately.',
          );
        }

        if (profile.volatilityRegime == VolatilityRegime.elevated) {
          multiplier *= 0.90;
          reasons.add(
            profile.hasHistoricalBaseline
                ? 'RSI is further discounted because realized volatility is elevated versus this stock\'s own one-year history.'
                : 'RSI is further discounted because short-term volatility is elevated relative to this stock\'s recent baseline.',
          );
        }

        if (profile.hasHistoricalBaseline &&
            profile.behaviorType == StockBehaviorType.volatile) {
          multiplier *= 0.90;
          reasons.add(
            'The long-term Stock DNA confirms that this is an inherently volatile name, so a single oscillator extreme carries less standalone weight.',
          );
        }
        break;

      case EvidenceKind.relativeVolume:
        if (profile.relativeVolume >= 2) {
          multiplier = 1.30;
          reasons.add(
            'Volume evidence receives more weight because current activity is at least twice the stock\'s recent average.',
          );
        } else if (profile.relativeVolume >= 1.50) {
          multiplier = 1.15;
          reasons.add(
            'Volume evidence receives more weight because trading activity is materially above the stock\'s recent average.',
          );
        } else if (profile.relativeVolume <= 0.70) {
          multiplier = 0.75;
          reasons.add(
            'Volume evidence receives less weight because current activity is unusually light.',
          );
        }

        if (profile.hasHistoricalBaseline) {
          if (profile.volumeVariability <= 0.25 &&
              profile.relativeVolume >= 1.50) {
            multiplier *= 1.10;
            reasons.add(
              'Daily volume is usually stable for this stock, so today\'s volume expansion is more unusual and receives extra importance.',
            );
          } else if (profile.volumeVariability >= 0.50 &&
              profile.relativeVolume < 2.0) {
            multiplier *= 0.85;
            reasons.add(
              'This stock historically has highly variable volume, so a moderate volume spike is less exceptional than it would be for a stable-volume stock.',
            );
          }
        }
        break;

      case EvidenceKind.generic:
        break;
    }

    final adjustedWeight = (evidence.dynamicWeight * multiplier).clamp(
      0.50,
      1.50,
    );

    if (reasons.isEmpty || adjustedWeight == evidence.dynamicWeight) {
      return evidence;
    }

    return evidence.copyWith(
      dynamicWeight: adjustedWeight,
      explanation:
          '${evidence.explanation} Context adjustment: ${reasons.join(' ')}',
    );
  }
}
