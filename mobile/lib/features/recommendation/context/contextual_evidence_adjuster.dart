import '../models/evidence_definition.dart';
import '../models/evidence_result.dart';
import '../models/strategy_summary.dart';
import '../strategy/stock_dna_strategy_policy.dart';
import 'stock_behavior_profile.dart';

class ContextualEvidenceAdjuster {
  const ContextualEvidenceAdjuster();

  List<EvidenceResult> adjust({
    required List<EvidenceResult> results,
    required StockBehaviorProfile profile,
    StrategyType strategy = StrategyType.trader,
  }) {
    final policy = StockDnaStrategyPolicy.forStrategy(strategy);

    if (policy == null || !profile.hasSufficientData) {
      return List<EvidenceResult>.unmodifiable(results);
    }

    if (policy.requiresHistoricalBaseline && !profile.hasHistoricalBaseline) {
      return List<EvidenceResult>.unmodifiable(results);
    }

    return List<EvidenceResult>.unmodifiable(
      results.map(
        (result) => strategy == StrategyType.trader
            ? _adjustTraderEvidence(result, profile)
            : _adjustSwingEvidence(result, profile, policy),
      ),
    );
  }

  EvidenceResult _adjustTraderEvidence(
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
      case EvidenceKind.emaStructure:
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

      case EvidenceKind.macdMomentum:
        if (profile.behaviorType == StockBehaviorType.volatile &&
            profile.trendEfficiency < 0.50) {
          multiplier = 0.80;
          reasons.add(
            'MACD receives less weight because this volatile stock is currently moving noisily rather than directionally.',
          );
        } else if (profile.trendEfficiency >= 0.70) {
          multiplier = 1.10;
          reasons.add(
            'MACD receives slightly more weight because momentum is being evaluated inside a clean directional move.',
          );
        }
        break;

      case EvidenceKind.relativeVolume:
      case EvidenceKind.volumeConfirmation:
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
              'This stock historically has highly variable volume, so a moderate volume change is less exceptional than it would be for a stable-volume stock.',
            );
          }
        }
        break;

      case EvidenceKind.vwapPosition:
        if (profile.behaviorType == StockBehaviorType.volatile) {
          multiplier = 0.90;
          reasons.add(
            'VWAP distance is slightly discounted because volatile stocks naturally travel farther around intraday reference prices.',
          );
        }
        if (profile.relativeVolume >= 1.50) {
          multiplier *= 1.10;
          reasons.add(
            'VWAP structure receives extra weight because elevated participation makes the current price location more informative.',
          );
        }
        break;

      case EvidenceKind.supportResistance:
        if (profile.volatilityRegime == VolatilityRegime.elevated &&
            profile.trendEfficiency < 0.50) {
          multiplier = 0.85;
          reasons.add(
            'Local support and resistance receive less weight in elevated, noisy volatility where levels are more likely to be probed repeatedly.',
          );
        }
        break;

      case EvidenceKind.priceExtension:
        if (profile.behaviorType == StockBehaviorType.steady) {
          multiplier = 1.10;
          reasons.add(
            'ATR-normalized extension receives slightly more weight because large stretches are less typical for a steady stock.',
          );
        } else if (profile.trendEfficiency >= 0.75) {
          multiplier = 0.85;
          reasons.add(
            'Extension receives slightly less weight because strongly directional trends can remain stretched for longer.',
          );
        }
        break;

      case EvidenceKind.multiTimeframeTrend:
      case EvidenceKind.marketContext:
      case EvidenceKind.marketBreadth:
      case EvidenceKind.newsSentiment:
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

  EvidenceResult _adjustSwingEvidence(
    EvidenceResult evidence,
    StockBehaviorProfile profile,
    StockDnaStrategyPolicy policy,
  ) {
    if (!evidence.isAvailable) {
      return evidence;
    }

    double multiplier = 1;
    final reasons = <String>[];

    final persistentDailyTrend =
        profile.historicalTrendEfficiency20 >= policy.persistentTrend20 &&
        profile.historicalTrendEfficiency60 >= policy.persistentTrend60;

    final weakDailyTrend =
        profile.historicalTrendEfficiency20 <= policy.weakTrend20 &&
        profile.historicalTrendEfficiency60 <= policy.weakTrend60;

    final unusuallyVolatile =
        profile.volatilityPercentile >= policy.highVolatilityPercentile;

    switch (evidence.definition.kind) {
      case EvidenceKind.candleTrend:
      case EvidenceKind.emaStructure:
      case EvidenceKind.multiTimeframeTrend:
        if (persistentDailyTrend) {
          multiplier *= 1.10;
          reasons.add(
            'The one-year daily Stock DNA shows persistent trend behavior, so existing Swing trend evidence receives modestly more trust.',
          );
        } else if (weakDailyTrend) {
          multiplier *= 0.90;
          reasons.add(
            'The daily Stock DNA shows historically weak trend persistence, so existing Swing trend evidence receives less trust.',
          );
        }

        if (unusuallyVolatile && profile.trendEfficiency < 0.55) {
          multiplier *= 0.90;
          reasons.add(
            'Current volatility is unusually high versus this stock\'s own history while the active move is noisy, so trend conviction is reduced.',
          );
        }
        break;

      case EvidenceKind.rsi:
        if (profile.behaviorType == StockBehaviorType.volatile) {
          multiplier *= 0.88;
          reasons.add(
            'This stock is historically volatile, so a Swing RSI reading receives less standalone trust.',
          );
        } else if (profile.behaviorType == StockBehaviorType.steady) {
          multiplier *= 1.05;
          reasons.add(
            'This stock is historically steady, so an unusual oscillator condition can receive slightly more contextual trust.',
          );
        }

        if (persistentDailyTrend) {
          multiplier *= 0.90;
          reasons.add(
            'Persistent daily trend behavior further reduces reversal interpretation because oscillator extremes can remain elevated during strong Swing trends.',
          );
        }

        if (unusuallyVolatile) {
          multiplier *= 0.92;
          reasons.add(
            'Realized volatility is unusually high versus this stock\'s own history, so RSI influence is reduced.',
          );
        }
        break;

      case EvidenceKind.macdMomentum:
        if (persistentDailyTrend) {
          multiplier *= 1.08;
          reasons.add(
            'Persistent daily trend behavior gives existing Swing MACD momentum modestly more contextual trust.',
          );
        } else if (weakDailyTrend && profile.trendEfficiency < 0.50) {
          multiplier *= 0.92;
          reasons.add(
            'Historically weak trend persistence and a noisy current move reduce MACD contextual trust.',
          );
        }
        break;

      case EvidenceKind.relativeVolume:
      case EvidenceKind.volumeConfirmation:
        if (profile.volumeVariability <= policy.stableVolumeVariability) {
          multiplier *= 1.08;
          reasons.add(
            'Daily volume is normally stable for this stock, so existing Participation evidence is modestly more informative.',
          );
        } else if (profile.volumeVariability >=
            policy.erraticVolumeVariability) {
          multiplier *= 0.90;
          reasons.add(
            'Daily volume is historically erratic, so existing Participation evidence receives less contextual weight.',
          );
        }
        break;

      case EvidenceKind.supportResistance:
        if (unusuallyVolatile && profile.trendEfficiency < 0.55) {
          multiplier *= 0.90;
          reasons.add(
            'Unusually high stock-specific volatility with noisy price action makes local structure easier to probe, so existing level evidence is discounted.',
          );
        }
        break;

      case EvidenceKind.priceExtension:
        if (profile.behaviorType == StockBehaviorType.steady) {
          multiplier *= 1.08;
          reasons.add(
            'Large ATR-normalized stretches are less routine for this historically steady stock, so extension context receives slightly more weight.',
          );
        } else if (profile.behaviorType == StockBehaviorType.volatile ||
            unusuallyVolatile) {
          multiplier *= 0.92;
          reasons.add(
            'Large stretches are more routine for this volatile stock, so extension context receives slightly less weight.',
          );
        }
        break;

      case EvidenceKind.vwapPosition:
      case EvidenceKind.marketContext:
      case EvidenceKind.marketBreadth:
      case EvidenceKind.newsSentiment:
      case EvidenceKind.generic:
        break;
    }

    final adjustedWeight = (evidence.dynamicWeight * multiplier)
        .clamp(policy.minimumDynamicWeight, policy.maximumDynamicWeight)
        .toDouble();

    if (reasons.isEmpty || adjustedWeight == evidence.dynamicWeight) {
      return evidence;
    }

    return evidence.copyWith(
      dynamicWeight: adjustedWeight,
      explanation:
          '${evidence.explanation} Swing Stock DNA context adjustment: '
          '${reasons.join(' ')} '
          'Stock DNA changes evidence weight only; it does not create or flip direction.',
    );
  }
}
