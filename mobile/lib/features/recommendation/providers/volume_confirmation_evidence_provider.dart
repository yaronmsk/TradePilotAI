import '../../market/models/market_snapshot.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';
import '../models/strategy_summary.dart';
import '../strategy/volume_confirmation_strategy_policy.dart';
import '../utils/technical_indicator_math.dart';
import 'evidence_provider.dart';

class VolumeConfirmationEvidenceProvider
    implements StrategyAwareEvidenceProvider {
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
        'Trader preserves the validated recent-half versus prior-half volume comparison with its existing price-move threshold. Swing compares equal recent and prior volume windows but measures price-move significance in ATR units using strategy-specific 1D or 4H policy.',
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
          '${volumeRatio.toStringAsFixed(2)}x volume · '
          '${priceChangePercent >= 0 ? '+' : ''}'
          '${priceChangePercent.toStringAsFixed(2)}% price',
      explanation:
          '$explanation Relative Volume and Volume Confirmation share the Participation evidence group, so they reinforce or challenge each other without being counted as two independent confirmations.',
    );
  }

  // ----------------------------------------------------------
  // Strategy-aware path
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
        'Volume Confirmation has not been calibrated for Investor yet.',
      ),
    };
  }

  EvidenceResult _evaluateSwing(MarketSnapshot snapshot) {
    final policy = VolumeConfirmationStrategyPolicy.forStrategy(
      strategy: StrategyType.swing,
      timeframe: snapshot.timeframe,
    );

    if (policy == null) {
      return _strategyUnavailable(
        'Swing Volume Confirmation supports only the approved 1D and 4H primary intervals.',
      );
    }

    final candles = snapshot.candles;

    if (candles.length < policy.minimumCandles) {
      return _swingInsufficient(policy);
    }

    var effectiveLookback = candles.length < policy.lookback
        ? candles.length
        : policy.lookback;

    // Equal prior/recent windows prevent one side from receiving an
    // additional candle merely because an odd number of candles exists.
    if (effectiveLookback.isOdd) {
      effectiveLookback -= 1;
    }

    if (effectiveLookback < policy.minimumCandles) {
      return _swingInsufficient(policy);
    }

    final window = candles.sublist(candles.length - effectiveLookback);

    if (window.first.close <= 0) {
      return _error('Volume confirmation requires valid positive price data.');
    }

    final split = window.length ~/ 2;

    final prior = window.sublist(0, split);
    final recent = window.sublist(split);

    final priorAverage = TechnicalIndicatorMath.average(
      prior.map((candle) => candle.volume),
    );

    final recentAverage = TechnicalIndicatorMath.average(
      recent.map((candle) => candle.volume),
    );

    if (priorAverage <= 0 || recentAverage <= 0) {
      return _error('Volume confirmation requires valid positive volume data.');
    }

    final atr = TechnicalIndicatorMath.atr(window, period: policy.atrPeriod);

    if (atr <= 0) {
      return _error('Swing Volume Confirmation requires a valid ATR baseline.');
    }

    final volumeRatio = recentAverage / priorAverage;
    final priceMove = window.last.close - window.first.close;
    final priceMoveAtr = priceMove / atr;
    final absoluteMoveAtr = priceMoveAtr.abs();

    final hasDirectionalMove =
        absoluteMoveAtr >= policy.minimumDirectionalMoveAtr;

    final expandingVolume = volumeRatio >= policy.expandingVolumeRatio;

    final fadingVolume = volumeRatio <= policy.fadingVolumeRatio;

    late final EvidenceDirection direction;
    late final EvidenceStrength strength;
    late final double score;
    late final String explanation;

    if (hasDirectionalMove && expandingVolume) {
      direction = priceMove > 0
          ? EvidenceDirection.bullish
          : EvidenceDirection.bearish;

      final strongConfirmation =
          volumeRatio >= policy.strongExpandingVolumeRatio ||
          absoluteMoveAtr >= policy.strongDirectionalMoveAtr;

      strength = strongConfirmation
          ? EvidenceStrength.strong
          : EvidenceStrength.moderate;

      score = strongConfirmation ? 82 : 68;

      explanation =
          'Participation is expanding while price is making a volatility-significant Swing move, confirming that move.';
    } else if (hasDirectionalMove && fadingVolume) {
      direction = priceMove > 0
          ? EvidenceDirection.bearish
          : EvidenceDirection.bullish;

      final strongDivergence =
          volumeRatio <= policy.strongFadingVolumeRatio &&
          absoluteMoveAtr >= policy.strongDirectionalMoveAtr;

      strength = strongDivergence
          ? EvidenceStrength.strong
          : EvidenceStrength.moderate;

      score = strongDivergence ? 76 : 64;

      explanation =
          'Price is making a volatility-significant Swing move while participation is fading. This creates divergence evidence against the price move.';
    } else {
      direction = EvidenceDirection.neutral;
      strength = EvidenceStrength.moderate;
      score = 50;

      if (!hasDirectionalMove) {
        explanation =
            'The observed price movement is not large enough relative to the stock\'s recent ATR to treat volume change as meaningful directional Swing confirmation.';
      } else {
        explanation =
            'Price is moving meaningfully, but participation is neither expanding nor fading enough to materially confirm or challenge that move.';
      }
    }

    final sampleFactor = (effectiveLookback / policy.targetCandles)
        .clamp(0.0, 1.0)
        .toDouble();

    final reliability = (0.55 + (sampleFactor * 0.30))
        .clamp(0.55, policy.maximumReliability)
        .toDouble();

    final signedMove =
        '${priceMoveAtr >= 0 ? '+' : ''}'
        '${priceMoveAtr.toStringAsFixed(2)} ATR';

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
      baselineValue:
          'Prior avg ${_formatVolume(priorAverage)} · '
          '${window.length}-candle Swing window',
      relativeValue:
          '${volumeRatio.toStringAsFixed(2)}x volume · '
          '$signedMove move',
      explanation:
          '$explanation The price-move significance threshold is '
          '${policy.minimumDirectionalMoveAtr.toStringAsFixed(2)} ATR for '
          '${policy.timeframe.toUpperCase()} Swing. Relative Volume and '
          'Volume Confirmation remain inside the same Participation family, '
          'so they cannot become two independent participation votes.',
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

  EvidenceResult _swingInsufficient(VolumeConfirmationStrategyPolicy policy) {
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
      baselineValue:
          'At least ${policy.minimumCandles} '
          '${policy.timeframe.toUpperCase()} candles required',
      relativeValue: 'Not available',
      explanation:
          'There is not enough history to compare prior and recent '
          'participation using the approved Swing window.',
      unavailableReason:
          'At least ${policy.minimumCandles} candles are required for '
          '${policy.timeframe.toUpperCase()} Swing Volume Confirmation.',
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
      baseWeight: 0.75,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'Strategy-specific Volume Confirmation policy required',
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
