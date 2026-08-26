import '../context/external_context_profile.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';
import '../models/strategy_summary.dart';
import '../strategy/market_breadth_strategy_policy.dart';

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
        'Trader preserves its validated breadth score. Swing recalculates breadth from advancing-stock participation, stocks above the medium-term trend reference and sector participation, while volatility pressure reduces influence rather than manufacturing bearish direction.',
  );

  EvidenceResult evaluate(
    MarketBreadthProfile profile, {
    StrategyType strategy = StrategyType.trader,
  }) {
    final policy = MarketBreadthStrategyPolicy.forStrategy(strategy);

    if (policy == null) {
      return _unavailable(
        'Market Breadth has not been calibrated for Investor yet.',
      );
    }

    if (!profile.isAvailable) {
      return EvidenceResult(
        providerName: kDefinition.name,
        definition: kDefinition,
        status: EvidenceStatus.insufficientData,
        direction: EvidenceDirection.unknown,
        strength: EvidenceStrength.veryWeak,
        score: 0,
        baseWeight: policy.providerBaseWeight,
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

    if (strategy == StrategyType.trader) {
      return _evaluateTrader(profile, policy);
    }

    return _evaluateSwing(profile, policy);
  }

  EvidenceResult _evaluateTrader(
    MarketBreadthProfile profile,
    MarketBreadthStrategyPolicy policy,
  ) {
    final score = profile.directionScore.abs().clamp(0.0, 100.0).toDouble();

    final direction = profile.directionScore > policy.directionThreshold
        ? EvidenceDirection.bullish
        : profile.directionScore < -policy.directionThreshold
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    return EvidenceResult(
      providerName: kDefinition.name,
      definition: kDefinition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: _strength(score),
      score: score,
      baseWeight: policy.providerBaseWeight,
      dynamicWeight: 1,
      reliability: profile.reliability,
      currentValue: _stateLabel(profile.state),
      baselineValue: '50% participation reference',
      relativeValue:
          '${profile.advancingPercent.toStringAsFixed(0)}% advancing • '
          '${profile.above50DayPercent.toStringAsFixed(0)}% above 50-day reference',
      explanation:
          '${profile.summary} Sector participation is '
          '${profile.sectorParticipationPercent.toStringAsFixed(0)}% and '
          'market-volatility percentile is '
          '${profile.volatilityPercentile.toStringAsFixed(0)}%.',
    );
  }

  EvidenceResult _evaluateSwing(
    MarketBreadthProfile profile,
    MarketBreadthStrategyPolicy policy,
  ) {
    final advancingScore = _centerParticipation(profile.advancingPercent);

    final mediumTermScore = _centerParticipation(profile.above50DayPercent);

    final sectorScore = _centerParticipation(
      profile.sectorParticipationPercent,
    );

    final directionScore =
        ((advancingScore * policy.advancingWeight) +
                (mediumTermScore * policy.aboveMediumTermWeight) +
                (sectorScore * policy.sectorParticipationWeight))
            .clamp(-100.0, 100.0)
            .toDouble();

    final score = directionScore.abs().clamp(0.0, 100.0).toDouble();

    final direction = directionScore > policy.directionThreshold
        ? EvidenceDirection.bullish
        : directionScore < -policy.directionThreshold
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    final dynamicWeight =
        profile.volatilityPercentile >= policy.extremeVolatilityPercentile
        ? policy.extremeVolatilityDynamicWeight
        : profile.volatilityPercentile >= policy.highVolatilityPercentile
        ? policy.highVolatilityDynamicWeight
        : 1.0;

    final state = _swingState(directionScore, policy);

    final volatilityExplanation = dynamicWeight < 1
        ? ' Elevated market volatility reduces Breadth influence but does not create bearish direction by itself.'
        : '';

    return EvidenceResult(
      providerName: kDefinition.name,
      definition: kDefinition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: _strength(score),
      score: score,
      baseWeight: policy.providerBaseWeight,
      dynamicWeight: dynamicWeight,
      reliability: profile.reliability.clamp(0.0, 0.92).toDouble(),
      currentValue: _stateLabel(state),
      baselineValue: '50% participation reference',
      relativeValue:
          '${profile.advancingPercent.toStringAsFixed(0)}% advancing • '
          '${profile.above50DayPercent.toStringAsFixed(0)}% above 50-day • '
          '${profile.sectorParticipationPercent.toStringAsFixed(0)}% sectors',
      explanation:
          'Swing Breadth gives the greatest weight to medium-term participation, '
          'then sector participation and current advancers. '
          '${profile.summary}'
          '$volatilityExplanation '
          'Market Breadth remains inside the same Market Context family as '
          'Market & Sector Context, so it cannot become a second independent '
          'market vote.',
    );
  }

  double _centerParticipation(double percent) {
    return ((percent - 50) * 2).clamp(-100.0, 100.0).toDouble();
  }

  MarketBreadthState _swingState(
    double score,
    MarketBreadthStrategyPolicy policy,
  ) {
    if (score >= policy.strongThreshold) {
      return MarketBreadthState.strong;
    }

    if (score >= policy.directionThreshold) {
      return MarketBreadthState.healthy;
    }

    if (score <= -policy.strongThreshold) {
      return MarketBreadthState.stressed;
    }

    if (score <= -policy.directionThreshold) {
      return MarketBreadthState.weak;
    }

    return MarketBreadthState.mixed;
  }

  EvidenceResult _unavailable(String reason) {
    return EvidenceResult(
      providerName: kDefinition.name,
      definition: kDefinition,
      status: EvidenceStatus.unavailable,
      direction: EvidenceDirection.unknown,
      strength: EvidenceStrength.veryWeak,
      score: 0,
      baseWeight: 0.55,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Unavailable',
      baselineValue: 'Strategy-specific breadth policy',
      relativeValue: 'Unavailable',
      explanation: reason,
      unavailableReason: reason,
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
