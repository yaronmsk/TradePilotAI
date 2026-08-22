import '../context/external_context_profile.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';

class MarketBreadthEvidenceProvider {
  const MarketBreadthEvidenceProvider();

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    kind: EvidenceKind.marketBreadth,
    family: EvidenceFamily.marketContext,
    name: 'Market Breadth',
    description:
        'Measures how broadly the current market move is being supported across stocks rather than relying only on a headline index.',
    whyItMatters:
        'An index can rise while participation underneath it weakens. Broad participation makes a market move more trustworthy; narrow participation can make it fragile.',
    calculation:
        'TradePilot combines the share of advancing stocks, the share above a medium-term trend reference, sector participation and a volatility-regime penalty. It remains inside the Market Context evidence family so it cannot double-count the existing market/sector context provider.',
  );

  EvidenceResult evaluate(MarketBreadthProfile profile) {
    if (!profile.isAvailable) {
      return EvidenceResult(
        providerName: kDefinition.name,
        definition: kDefinition,
        status: EvidenceStatus.insufficientData,
        direction: EvidenceDirection.unknown,
        strength: EvidenceStrength.veryWeak,
        score: 0,
        baseWeight: 0.65,
        dynamicWeight: 1,
        reliability: 0,
        currentValue: 'Unavailable',
        baselineValue: 'Broad participation',
        relativeValue: 'Breadth data unavailable',
        explanation:
            'Market breadth could not be calculated from the available context data.',
        unavailableReason: 'Breadth data is unavailable.',
      );
    }

    final score = profile.directionScore.abs().clamp(0.0, 100.0).toDouble();
    final direction = profile.directionScore > 8
        ? EvidenceDirection.bullish
        : profile.directionScore < -8
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    return EvidenceResult(
      providerName: kDefinition.name,
      definition: kDefinition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: _strength(score),
      score: score,
      baseWeight: 0.65,
      dynamicWeight: 1,
      reliability: profile.reliability,
      currentValue: _stateLabel(profile.state),
      baselineValue: '50% participation reference',
      relativeValue:
          '${profile.advancingPercent.toStringAsFixed(0)}% advancing • ${profile.above50DayPercent.toStringAsFixed(0)}% above 50-day reference',
      explanation:
          '${profile.summary} Sector participation is ${profile.sectorParticipationPercent.toStringAsFixed(0)}% and market-volatility percentile is ${profile.volatilityPercentile.toStringAsFixed(0)}%.',
    );
  }

  EvidenceStrength _strength(double score) {
    if (score >= 75) {
      return EvidenceStrength.exceptional;
    }
    if (score >= 55) {
      return EvidenceStrength.strong;
    }
    if (score >= 30) {
      return EvidenceStrength.moderate;
    }
    if (score >= 12) {
      return EvidenceStrength.weak;
    }
    return EvidenceStrength.veryWeak;
  }

  String _stateLabel(MarketBreadthState state) {
    return switch (state) {
      MarketBreadthState.strong => 'Strong',
      MarketBreadthState.healthy => 'Healthy',
      MarketBreadthState.mixed => 'Mixed',
      MarketBreadthState.weak => 'Weak',
      MarketBreadthState.stressed => 'Stressed',
      MarketBreadthState.unavailable => 'Unavailable',
    };
  }
}
