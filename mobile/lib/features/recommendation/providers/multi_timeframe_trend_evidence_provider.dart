import '../context/multi_timeframe_profile.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';

class MultiTimeframeTrendEvidenceProvider {
  const MultiTimeframeTrendEvidenceProvider();

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    kind: EvidenceKind.multiTimeframeTrend,
    family: EvidenceFamily.trend,
    name: 'Multi-Timeframe Trend',
    description:
        'Compares the active Trader timeframe with higher-timeframe confirmation and regime trends.',
    whyItMatters:
        'A short-term signal is more trustworthy when broader timeframes support it, and less trustworthy when higher-timeframe trends oppose it.',
    calculation:
        'TradePilot evaluates 5-minute, 1-hour and 1-day price direction, normalizes each move by its own candle range, then combines them using Trader-specific role weights. This evidence remains in the Trend family so it cannot count as a separate independent vote from other trend indicators.',
  );

  EvidenceResult evaluate(MultiTimeframeProfile profile) {
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
        baselineValue: '5m / 1h / 1D',
        relativeValue: 'Higher-timeframe context unavailable',
        explanation:
            'Multi-timeframe trend context could not be calculated from the available data.',
        unavailableReason: 'Higher-timeframe snapshots are unavailable.',
      );
    }

    final score = profile.directionScore.abs().clamp(0.0, 100.0);
    final direction = profile.directionScore > 5
        ? EvidenceDirection.bullish
        : profile.directionScore < -5
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

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
          '${_alignmentExplanation(profile.alignment)}',
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

  String _alignmentExplanation(TimeframeAlignment alignment) {
    switch (alignment) {
      case TimeframeAlignment.aligned:
        return 'The timeframes reinforce one another.';
      case TimeframeAlignment.mixed:
        return 'The timeframes are mixed, so the short-term signal receives less confirmation.';
      case TimeframeAlignment.opposed:
        return 'Both higher timeframes oppose the active signal, creating a meaningful trend conflict.';
      case TimeframeAlignment.unknown:
        return 'Timeframe alignment is unavailable.';
    }
  }

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
