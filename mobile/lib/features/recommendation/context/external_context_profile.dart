enum MarketBreadthState { strong, healthy, mixed, weak, stressed, unavailable }

enum EventRiskLevel { low, moderate, high, critical, unavailable }

enum NewsSentimentState { positive, neutral, negative, mixed, unavailable }

class MarketBreadthProfile {
  const MarketBreadthProfile({
    required this.state,
    required this.advancingPercent,
    required this.above50DayPercent,
    required this.sectorParticipationPercent,
    required this.volatilityPercentile,
    required this.directionScore,
    required this.reliability,
    required this.summary,
  });

  const MarketBreadthProfile.unavailable()
    : state = MarketBreadthState.unavailable,
      advancingPercent = 0,
      above50DayPercent = 0,
      sectorParticipationPercent = 0,
      volatilityPercentile = 0,
      directionScore = 0,
      reliability = 0,
      summary = 'Market breadth is unavailable.';

  final MarketBreadthState state;
  final double advancingPercent;
  final double above50DayPercent;
  final double sectorParticipationPercent;
  final double volatilityPercentile;
  final double directionScore;
  final double reliability;
  final String summary;

  bool get isAvailable => state != MarketBreadthState.unavailable;
}

class EventRiskProfile {
  const EventRiskProfile({
    required this.level,
    required this.earningsHoursAway,
    required this.macroEventHoursAway,
    required this.macroEventLabel,
    required this.confidencePenaltyPoints,
    required this.summary,
  });

  const EventRiskProfile.unavailable()
    : level = EventRiskLevel.unavailable,
      earningsHoursAway = null,
      macroEventHoursAway = null,
      macroEventLabel = '',
      confidencePenaltyPoints = 0,
      summary = 'Upcoming event risk is unavailable.';

  final EventRiskLevel level;
  final int? earningsHoursAway;
  final int? macroEventHoursAway;
  final String macroEventLabel;

  /// Confidence-only penalty. Event proximity is risk context, not a Buy/Sell
  /// signal, so it never changes the direction score directly.
  final double confidencePenaltyPoints;
  final String summary;

  bool get isAvailable => level != EventRiskLevel.unavailable;
}

class NewsSentimentProfile {
  const NewsSentimentProfile({
    required this.state,
    required this.sentimentScore,
    required this.articleCount,
    required this.sourceCount,
    this.independentStoryCount,
    required this.freshnessHours,
    required this.materiality,
    required this.reliability,
    required this.summary,
  });

  const NewsSentimentProfile.unavailable()
    : state = NewsSentimentState.unavailable,
      sentimentScore = 0,
      articleCount = 0,
      sourceCount = 0,
      independentStoryCount = null,
      freshnessHours = 0,
      materiality = 0,
      reliability = 0,
      summary = 'News sentiment is unavailable.';

  final NewsSentimentState state;

  /// Signed sentiment score from -100 to +100.
  final double sentimentScore;
  final int articleCount;
  final int sourceCount;

  /// Number of independently de-duplicated news-story clusters when the
  /// upstream source can provide that information.
  ///
  /// Swing directional use requires this value so syndicated/repeated
  /// headlines cannot multiply evidence simply by appearing many times.
  final int? independentStoryCount;

  final double freshnessHours;

  /// Importance/relevance of the recent news set, from 0 to 1.
  final double materiality;
  final double reliability;
  final String summary;

  bool get isAvailable => state != NewsSentimentState.unavailable;
}

class ExternalContextProfile {
  const ExternalContextProfile({
    required this.marketBreadth,
    required this.eventRisk,
    required this.newsSentiment,
    required this.isSynthetic,
    required this.sourceLabel,
  });

  const ExternalContextProfile.unavailable()
    : marketBreadth = const MarketBreadthProfile.unavailable(),
      eventRisk = const EventRiskProfile.unavailable(),
      newsSentiment = const NewsSentimentProfile.unavailable(),
      isSynthetic = false,
      sourceLabel = '';

  final MarketBreadthProfile marketBreadth;
  final EventRiskProfile eventRisk;
  final NewsSentimentProfile newsSentiment;
  final bool isSynthetic;
  final String sourceLabel;

  bool get hasAnyContext =>
      marketBreadth.isAvailable ||
      eventRisk.isAvailable ||
      newsSentiment.isAvailable;
}
