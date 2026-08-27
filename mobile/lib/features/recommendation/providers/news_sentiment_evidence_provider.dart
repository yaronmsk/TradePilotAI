import '../context/external_context_profile.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';
import '../models/strategy_summary.dart';
import '../strategy/news_sentiment_strategy_policy.dart';

class NewsSentimentEvidenceProvider {
  const NewsSentimentEvidenceProvider();

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    kind: EvidenceKind.newsSentiment,
    family: EvidenceFamily.sentiment,
    name: 'News Sentiment',
    description:
        'Summarizes the directional tone of recent company-specific news while accounting for source diversity, freshness and materiality.',
    whyItMatters:
        'Fresh material news can accelerate, contradict or invalidate a purely technical setup. A raw headline count is not enough because repeated or low-quality stories can create false conviction.',
    calculation:
        'Trader preserves its validated sentiment behavior. Swing uses strategy-specific freshness decay, materiality and independently de-duplicated story coverage. Article count is only a minimum coverage gate and does not multiply Swing influence after that gate is satisfied.',
  );

  EvidenceResult evaluate(
    NewsSentimentProfile profile, {
    StrategyType strategy = StrategyType.trader,
  }) {
    final policy = NewsSentimentStrategyPolicy.forStrategy(strategy);

    if (policy == null) {
      return _unavailable(
        'News Sentiment has not been calibrated for Investor yet.',
      );
    }

    if (strategy == StrategyType.trader) {
      return _evaluateTrader(profile, policy);
    }

    return _evaluateSwing(profile, policy);
  }

  EvidenceResult _evaluateTrader(
    NewsSentimentProfile profile,
    NewsSentimentStrategyPolicy policy,
  ) {
    if (!profile.isAvailable ||
        profile.articleCount < policy.minimumArticleCount ||
        profile.sourceCount < policy.minimumSourceCount) {
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
        currentValue: 'Limited data',
        baselineValue: 'Recent company news',
        relativeValue: 'Insufficient source diversity',
        explanation:
            'There are not enough recent independent news sources to use sentiment as recommendation evidence.',
        unavailableReason: 'Insufficient recent independent news coverage.',
      );
    }

    final score = profile.sentimentScore.abs().clamp(0.0, 100.0).toDouble();

    final direction = profile.sentimentScore >= policy.directionThreshold
        ? EvidenceDirection.bullish
        : profile.sentimentScore <= -policy.directionThreshold
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    final dynamicWeight = (0.75 + (profile.materiality * 0.25))
        .clamp(0.75, 1.0)
        .toDouble();

    return EvidenceResult(
      providerName: kDefinition.name,
      definition: kDefinition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: _strength(score),
      score: score,
      baseWeight: policy.providerBaseWeight,
      dynamicWeight: dynamicWeight,
      reliability: profile.reliability,
      currentValue: _stateLabel(profile.state),
      baselineValue: '${profile.articleCount} recent items',
      relativeValue:
          '${profile.sourceCount} sources • '
          'freshest ~${profile.freshnessHours.toStringAsFixed(1)}h',
      explanation:
          '${profile.summary} Sentiment score is '
          '${_signed(profile.sentimentScore)}/100 with '
          '${(profile.materiality * 100).toStringAsFixed(0)}% materiality.',
    );
  }

  EvidenceResult _evaluateSwing(
    NewsSentimentProfile profile,
    NewsSentimentStrategyPolicy policy,
  ) {
    final independentStories = profile.independentStoryCount;

    if (!profile.isAvailable ||
        profile.articleCount < policy.minimumArticleCount ||
        profile.sourceCount < policy.minimumSourceCount ||
        independentStories == null ||
        independentStories < policy.minimumIndependentStoryCount) {
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
        currentValue: 'Limited data',
        baselineValue: 'De-duplicated Swing news coverage',
        relativeValue:
            '${profile.sourceCount} sources • '
            '${independentStories ?? 0} independent stories',
        explanation:
            'Swing News Sentiment requires enough recent coverage, at least '
            'two independent sources and at least two de-duplicated story '
            'clusters. Raw headline count alone cannot qualify the signal.',
        unavailableReason:
            'Insufficient independent de-duplicated Swing news coverage.',
      );
    }

    if (profile.freshnessHours > policy.maximumFreshnessHours) {
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
        currentValue: 'Stale',
        baselineValue: 'Swing news horizon',
        relativeValue:
            'freshest ~${profile.freshnessHours.toStringAsFixed(1)}h',
        explanation:
            'The newest usable story is outside the seven-day Swing news '
            'context horizon, so it cannot influence the recommendation.',
        unavailableReason:
            'News coverage is outside the Swing freshness horizon.',
      );
    }

    final freshnessFactor = _freshnessFactor(profile.freshnessHours, policy);

    final sourceReliability = (profile.sourceCount / 6)
        .clamp(0.35, 1.0)
        .toDouble();

    final storyReliability = (independentStories / 5)
        .clamp(0.40, 1.0)
        .toDouble();

    final materialityReliability = profile.materiality
        .clamp(0.0, 1.0)
        .toDouble();

    // Deliberately excludes articleCount. Once minimum coverage is satisfied,
    // repeated/syndicated headlines cannot increase Swing reliability.
    final reliability =
        ((storyReliability * 0.35) +
                (sourceReliability * 0.25) +
                (freshnessFactor * 0.25) +
                (materialityReliability * 0.15))
            .clamp(0.0, 0.95)
            .toDouble();

    final materialityFactor = (0.50 + (profile.materiality * 0.50))
        .clamp(0.50, 1.0)
        .toDouble();

    final dynamicWeight = (freshnessFactor * materialityFactor)
        .clamp(0.20, 1.0)
        .toDouble();

    final absoluteSentiment = profile.sentimentScore
        .abs()
        .clamp(0.0, 100.0)
        .toDouble();

    final stateAllowsDirection =
        profile.state == NewsSentimentState.positive ||
        profile.state == NewsSentimentState.negative;

    final freshEnoughForDirection =
        profile.freshnessHours <= policy.directionalFreshnessHours;

    final materialEnough =
        profile.materiality >= policy.minimumDirectionalMateriality;

    final strongEnough = absoluteSentiment >= policy.directionThreshold;

    final directionEligible =
        stateAllowsDirection &&
        freshEnoughForDirection &&
        materialEnough &&
        strongEnough;

    final direction = !directionEligible
        ? EvidenceDirection.neutral
        : profile.sentimentScore > 0
        ? EvidenceDirection.bullish
        : EvidenceDirection.bearish;

    // If Swing news fails the directional-quality gates, do not allow a large
    // raw sentiment magnitude to inflate evidence confidence as neutral data.
    final score = direction == EvidenceDirection.neutral
        ? 0.0
        : absoluteSentiment;

    final currentValue =
        profile.freshnessHours > policy.directionalFreshnessHours
        ? 'Stale'
        : !materialEnough
        ? 'Low materiality'
        : !strongEnough ||
              profile.state == NewsSentimentState.mixed ||
              profile.state == NewsSentimentState.neutral
        ? 'Mixed'
        : _stateLabel(profile.state);

    final neutralityReason = direction != EvidenceDirection.neutral
        ? ''
        : profile.freshnessHours > policy.directionalFreshnessHours
        ? ' Coverage is still visible as context, but it is too old to '
              'create Swing direction.'
        : !materialEnough
        ? ' Materiality is below the Swing directional gate.'
        : !strongEnough
        ? ' Sentiment magnitude is inside the Swing neutral zone.'
        : ' Mixed or neutral classification prevents a directional '
              'news vote.';

    return EvidenceResult(
      providerName: kDefinition.name,
      definition: kDefinition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: _strength(score),
      score: score,
      baseWeight: policy.providerBaseWeight,
      dynamicWeight: dynamicWeight,
      reliability: reliability,
      currentValue: currentValue,
      baselineValue: '${profile.articleCount} items — coverage gate only',
      relativeValue:
          '${profile.sourceCount} sources • '
          '$independentStories independent stories • '
          'freshest ~${profile.freshnessHours.toStringAsFixed(1)}h',
      explanation:
          '${profile.summary} Swing sentiment is '
          '${_signed(profile.sentimentScore)}/100 with '
          '${(profile.materiality * 100).toStringAsFixed(0)}% materiality. '
          'Freshness decays after 24h; directional use ends after 120h and '
          'all coverage becomes stale after 168h. Article count does not '
          'increase Swing weight after minimum coverage is met.'
          '$neutralityReason',
    );
  }

  double _freshnessFactor(
    double freshnessHours,
    NewsSentimentStrategyPolicy policy,
  ) {
    if (freshnessHours <= policy.fullFreshnessHours) {
      return 1;
    }

    final decayWindow =
        policy.maximumFreshnessHours - policy.fullFreshnessHours;

    if (decayWindow <= 0) {
      return policy.minimumFreshnessFactor;
    }

    final progress =
        ((freshnessHours - policy.fullFreshnessHours) / decayWindow)
            .clamp(0.0, 1.0)
            .toDouble();

    return (1 - (progress * (1 - policy.minimumFreshnessFactor)))
        .clamp(policy.minimumFreshnessFactor, 1.0)
        .toDouble();
  }

  EvidenceResult _unavailable(String reason) {
    return EvidenceResult(
      providerName: kDefinition.name,
      definition: kDefinition,
      status: EvidenceStatus.unavailable,
      direction: EvidenceDirection.unknown,
      strength: EvidenceStrength.veryWeak,
      score: 0,
      baseWeight: 0.50,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Unavailable',
      baselineValue: 'Strategy-specific news policy',
      relativeValue: 'Unavailable',
      explanation: reason,
      unavailableReason: reason,
    );
  }

  EvidenceStrength _strength(double score) {
    if (score >= 70) {
      return EvidenceStrength.exceptional;
    }

    if (score >= 50) {
      return EvidenceStrength.strong;
    }

    if (score >= 28) {
      return EvidenceStrength.moderate;
    }

    if (score >= 12) {
      return EvidenceStrength.weak;
    }

    return EvidenceStrength.veryWeak;
  }

  String _stateLabel(NewsSentimentState state) {
    return switch (state) {
      NewsSentimentState.positive => 'Positive',
      NewsSentimentState.neutral => 'Neutral',
      NewsSentimentState.negative => 'Negative',
      NewsSentimentState.mixed => 'Mixed',
      NewsSentimentState.unavailable => 'Unavailable',
    };
  }

  String _signed(double value) {
    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(0)}';
  }
}
