import '../context/external_context_profile.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';

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
        'TradePilot uses a signed sentiment score and scales its reliability using article count, independent source count, freshness and materiality. Sentiment remains its own capped evidence family.',
  );

  EvidenceResult evaluate(NewsSentimentProfile profile) {
    if (!profile.isAvailable ||
        profile.articleCount < 3 ||
        profile.sourceCount < 2) {
      return EvidenceResult(
        providerName: kDefinition.name,
        definition: kDefinition,
        status: EvidenceStatus.insufficientData,
        direction: EvidenceDirection.unknown,
        strength: EvidenceStrength.veryWeak,
        score: 0,
        baseWeight: 0.55,
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
    final direction = profile.sentimentScore >= 15
        ? EvidenceDirection.bullish
        : profile.sentimentScore <= -15
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
      baseWeight: 0.55,
      dynamicWeight: dynamicWeight,
      reliability: profile.reliability,
      currentValue: _stateLabel(profile.state),
      baselineValue: '${profile.articleCount} recent items',
      relativeValue:
          '${profile.sourceCount} sources • freshest ~${profile.freshnessHours.toStringAsFixed(1)}h',
      explanation:
          '${profile.summary} Sentiment score is ${_signed(profile.sentimentScore)}/100 with ${(profile.materiality * 100).toStringAsFixed(0)}% materiality.',
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
