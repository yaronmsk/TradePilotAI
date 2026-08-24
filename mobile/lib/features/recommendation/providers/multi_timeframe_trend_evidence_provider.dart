import '../context/multi_timeframe_profile.dart';
import '../context/strategy_timeframe_plan.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';
import '../models/strategy_summary.dart';

class MultiTimeframeTrendEvidenceProvider {
  const MultiTimeframeTrendEvidenceProvider();

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    kind: EvidenceKind.multiTimeframeTrend,
    family: EvidenceFamily.trend,
    name: 'Multi-Timeframe Trend',
    description:
        'Compares the active strategy setup with confirmation and broader-regime trend views.',
    whyItMatters:
        'A short-term signal is more trustworthy when broader timeframes support it, and less trustworthy when higher-timeframe trends oppose it.',
    calculation:
        'TradePilot evaluates normalized price direction on the primary, confirmation and regime timeframes and combines them using strategy-specific role semantics. Swing uses primary-anchored direction, so broader timeframes may strengthen or weaken the setup but cannot independently reverse it. This evidence remains inside the Trend family.',
  );

  EvidenceResult evaluate(
    MultiTimeframeProfile profile, {
    StrategyType strategy = StrategyType.trader,
  }) {
    if (strategy == StrategyType.investor) {
      return _unavailable(
        profile,
        'Multi-Timeframe Trend has not been calibrated for Investor yet.',
      );
    }

    if (!_profileMatchesStrategy(profile, strategy)) {
      return _unavailable(
        profile,
        'The timeframe profile does not match the selected ${strategy.title} strategy plan.',
      );
    }

    if (!profile.hasSufficientData) {
      return EvidenceResult(
        providerName: kDefinition.name,
        definition: kDefinition,
        status: EvidenceStatus.insufficientData,
        direction: EvidenceDirection.unknown,
        strength: EvidenceStrength.veryWeak,
        score: 0,
        baseWeight: 1,
        dynamicWeight: 1,
        reliability: 0,
        currentValue: 'Unavailable',
        baselineValue: _planLabel(profile.plan),
        relativeValue: 'Higher-timeframe context unavailable',
        explanation:
            'Multi-timeframe trend context could not be calculated from the available data.',
        unavailableReason: 'Higher-timeframe snapshots are unavailable.',
      );
    }

    final rawScore = profile.directionScore.abs().clamp(0.0, 100.0);

    final direction = _resolveDirection(profile: profile, strategy: strategy);

    // A malformed Swing profile must never manufacture a direction opposite
    // to the primary setup. Treat such a contradiction as neutral evidence.
    final score = direction == EvidenceDirection.neutral && rawScore > 5
        ? 0.0
        : rawScore;

    return EvidenceResult(
      providerName: kDefinition.name,
      definition: kDefinition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: _strength(score),
      score: score,
      baseWeight: 1,
      dynamicWeight: 1,
      reliability: profile.reliability,
      currentValue: _alignmentLabel(profile.alignment),
      baselineValue:
          '${profile.primary.timeframe} / ${profile.confirmation.timeframe} / ${profile.regime.timeframe}',
      relativeValue:
          '${_directionLabel(profile.primary.direction)} • ${_directionLabel(profile.confirmation.direction)} • ${_directionLabel(profile.regime.direction)}',
      explanation:
          'The active trend is ${_directionLabel(profile.primary.direction).toLowerCase()}, '
          'the confirmation trend is ${_directionLabel(profile.confirmation.direction).toLowerCase()}, '
          'and the broader regime is ${_directionLabel(profile.regime.direction).toLowerCase()}. '
          '${_alignmentExplanation(profile.alignment, strategy)}',
    );
  }

  EvidenceStrength _strength(double score) {
    if (score >= 80) {
      return EvidenceStrength.exceptional;
    }
    if (score >= 60) {
      return EvidenceStrength.strong;
    }
    if (score >= 35) {
      return EvidenceStrength.moderate;
    }
    if (score >= 15) {
      return EvidenceStrength.weak;
    }
    return EvidenceStrength.veryWeak;
  }

  String _alignmentLabel(TimeframeAlignment alignment) {
    switch (alignment) {
      case TimeframeAlignment.aligned:
        return 'Aligned';
      case TimeframeAlignment.mixed:
        return 'Mixed';
      case TimeframeAlignment.opposed:
        return 'Opposed';
      case TimeframeAlignment.unknown:
        return 'Unknown';
    }
  }

  String _alignmentExplanation(
    TimeframeAlignment alignment,
    StrategyType strategy,
  ) {
    if (strategy == StrategyType.swing) {
      return switch (alignment) {
        TimeframeAlignment.aligned =>
          'The broader Swing timeframes reinforce the primary setup.',
        TimeframeAlignment.mixed =>
          'Broader Swing context is mixed, so the primary setup receives only partial confirmation.',
        TimeframeAlignment.opposed =>
          'Both broader Swing timeframes oppose the primary setup. They weaken it toward neutral but cannot independently reverse its direction.',
        TimeframeAlignment.unknown =>
          'Swing timeframe alignment is unavailable.',
      };
    }

    return switch (alignment) {
      TimeframeAlignment.aligned => 'The timeframes reinforce one another.',
      TimeframeAlignment.mixed =>
        'The timeframes are mixed, so the short-term signal receives less confirmation.',
      TimeframeAlignment.opposed =>
        'Both higher timeframes oppose the active signal, creating a meaningful trend conflict.',
      TimeframeAlignment.unknown => 'Timeframe alignment is unavailable.',
    };
  }

  EvidenceDirection _resolveDirection({
    required MultiTimeframeProfile profile,
    required StrategyType strategy,
  }) {
    if (profile.directionScore.abs() <= 5) {
      return EvidenceDirection.neutral;
    }

    if (strategy == StrategyType.swing) {
      final primary = profile.primary.direction;

      if (primary == EvidenceDirection.bullish && profile.directionScore > 5) {
        return EvidenceDirection.bullish;
      }

      if (primary == EvidenceDirection.bearish && profile.directionScore < -5) {
        return EvidenceDirection.bearish;
      }

      return EvidenceDirection.neutral;
    }

    return profile.directionScore > 5
        ? EvidenceDirection.bullish
        : EvidenceDirection.bearish;
  }

  bool _profileMatchesStrategy(
    MultiTimeframeProfile profile,
    StrategyType strategy,
  ) {
    StrategyTimeframePlan expected;

    try {
      expected = StrategyTimeframePlan.forStrategy(
        strategy,
        primaryTimeframe: profile.plan.primaryTimeframe,
      );
    } on ArgumentError {
      return false;
    }

    return profile.plan.primaryTimeframe == expected.primaryTimeframe &&
        profile.plan.confirmationTimeframe == expected.confirmationTimeframe &&
        profile.plan.regimeTimeframe == expected.regimeTimeframe &&
        profile.primary.timeframe == expected.primaryTimeframe &&
        profile.confirmation.timeframe == expected.confirmationTimeframe &&
        profile.regime.timeframe == expected.regimeTimeframe;
  }

  EvidenceResult _unavailable(MultiTimeframeProfile profile, String reason) {
    return EvidenceResult(
      providerName: kDefinition.name,
      definition: kDefinition,
      status: EvidenceStatus.unavailable,
      direction: EvidenceDirection.unknown,
      strength: EvidenceStrength.veryWeak,
      score: 0,
      baseWeight: 1,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Unavailable',
      baselineValue: _planLabel(profile.plan),
      relativeValue: 'Strategy-specific context unavailable',
      explanation: reason,
      unavailableReason: reason,
    );
  }

  String _planLabel(StrategyTimeframePlan plan) =>
      '${plan.primaryTimeframe} / '
      '${plan.confirmationTimeframe} / '
      '${plan.regimeTimeframe}';

  String _directionLabel(EvidenceDirection direction) {
    switch (direction) {
      case EvidenceDirection.bullish:
        return 'Bullish';
      case EvidenceDirection.bearish:
        return 'Bearish';
      case EvidenceDirection.neutral:
        return 'Neutral';
      case EvidenceDirection.unknown:
        return 'Unknown';
    }
  }
}
