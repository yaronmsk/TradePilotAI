import '../models/strategy_summary.dart';
import 'external_context_profile.dart';
import 'external_context_provider.dart';
import 'market_context_target.dart';

class MockExternalContextProvider implements ExternalContextProvider {
  const MockExternalContextProvider();

  @override
  Future<ExternalContextProfile> load({
    required String symbol,
    required StrategyType strategy,
    required String primaryTimeframe,
    required MarketContextTarget target,
  }) async {
    final normalized = symbol.trim().toUpperCase();
    final breadth = _marketBreadthFor(target, primaryTimeframe);
    final eventRisk = _eventRiskFor(normalized, primaryTimeframe);
    final news = _newsFor(normalized);

    return ExternalContextProfile(
      marketBreadth: breadth,
      eventRisk: eventRisk,
      newsSentiment: news,
      isSynthetic: true,
      sourceLabel: 'Development simulation',
    );
  }

  MarketBreadthProfile _marketBreadthFor(
    MarketContextTarget target,
    String primaryTimeframe,
  ) {
    final sectorHash = _stableHash(target.sectorSymbol);
    final timeframeBias = switch (primaryTimeframe) {
      '1m' => -2.0,
      '5m' => 0.0,
      '15m' => 1.0,
      '30m' => 1.5,
      '1h' => 2.0,
      _ => 0.0,
    };

    final advancing = (56 + (sectorHash % 9) - 4 + timeframeBias)
        .clamp(20.0, 80.0)
        .toDouble();
    final above50 = (58 + ((sectorHash ~/ 7) % 11) - 5)
        .clamp(20.0, 80.0)
        .toDouble();
    final sectorParticipation = (54 + ((sectorHash ~/ 13) % 17) - 8)
        .clamp(20.0, 80.0)
        .toDouble();
    final volatilityPercentile = (42 + ((sectorHash ~/ 17) % 29) - 14)
        .clamp(10.0, 90.0)
        .toDouble();

    final participationScore =
        ((advancing - 50) * 1.4) +
        ((above50 - 50) * 1.1) +
        ((sectorParticipation - 50) * 0.8);
    final volatilityPenalty = volatilityPercentile >= 75
        ? (volatilityPercentile - 75) * 0.8
        : 0.0;
    final directionScore = (participationScore - volatilityPenalty)
        .clamp(-100.0, 100.0)
        .toDouble();

    final state = directionScore >= 35
        ? MarketBreadthState.strong
        : directionScore >= 15
        ? MarketBreadthState.healthy
        : directionScore <= -35
        ? MarketBreadthState.stressed
        : directionScore <= -15
        ? MarketBreadthState.weak
        : MarketBreadthState.mixed;

    return MarketBreadthProfile(
      state: state,
      advancingPercent: advancing,
      above50DayPercent: above50,
      sectorParticipationPercent: sectorParticipation,
      volatilityPercentile: volatilityPercentile,
      directionScore: directionScore,
      reliability: target.hasSectorBenchmark ? 0.88 : 0.72,
      summary:
          '${advancing.toStringAsFixed(0)}% of the broad sample is advancing and ${above50.toStringAsFixed(0)}% is above its 50-day trend reference.',
    );
  }

  EventRiskProfile _eventRiskFor(String symbol, String primaryTimeframe) {
    final earningsHours = switch (symbol) {
      'NVDA' => 28,
      'PLTR' => 18,
      'GOOG' => 72,
      'AAPL' => 96,
      'MSFT' => 120,
      'TSLA' => 160,
      _ => 84 + (_stableHash(symbol) % 120),
    };

    final macroHours = switch (primaryTimeframe) {
      '1m' => 9,
      '5m' => 18,
      '15m' => 24,
      '30m' => 30,
      '1h' => 36,
      _ => 36,
    };

    final earningsPenalty = earningsHours <= 24
        ? 8.0
        : earningsHours <= 48
        ? 6.0
        : earningsHours <= 96
        ? 3.5
        : earningsHours <= 168
        ? 1.5
        : 0.0;
    final macroPenalty = macroHours <= 12
        ? 4.0
        : macroHours <= 24
        ? 2.5
        : macroHours <= 48
        ? 1.0
        : 0.0;
    final penalty = (earningsPenalty + macroPenalty)
        .clamp(0.0, 12.0)
        .toDouble();

    final level = penalty >= 9
        ? EventRiskLevel.critical
        : penalty >= 6
        ? EventRiskLevel.high
        : penalty >= 3
        ? EventRiskLevel.moderate
        : EventRiskLevel.low;

    return EventRiskProfile(
      level: level,
      earningsHoursAway: earningsHours,
      macroEventHoursAway: macroHours,
      macroEventLabel: 'High-impact macro event',
      confidencePenaltyPoints: penalty,
      summary:
          'Upcoming earnings and scheduled macro events can create gap or volatility risk that current technical evidence cannot fully price in.',
    );
  }

  NewsSentimentProfile _newsFor(String symbol) {
    final score = switch (symbol) {
      'NVDA' => 52.0,
      'AAPL' => 24.0,
      'MSFT' => 31.0,
      'PLTR' => 14.0,
      'GOOG' => -9.0,
      'TSLA' => -34.0,
      _ => ((_stableHash(symbol) % 91) - 45).toDouble(),
    };

    final articleCount = 6 + (_stableHash('$symbol|articles') % 10);
    final sourceCount = 3 + (_stableHash('$symbol|sources') % 5);

    final independentStoryCount = (2 + (_stableHash('$symbol|stories') % 4))
        .clamp(2, sourceCount)
        .toInt();

    final freshnessHours =
        1.0 + (_stableHash('$symbol|freshness') % 18).toDouble() / 3;
    final materiality = (0.45 + (_stableHash('$symbol|materiality') % 45) / 100)
        .clamp(0.0, 1.0)
        .toDouble();
    final sampleReliability = (articleCount / 12).clamp(0.35, 1.0).toDouble();
    final sourceReliability = (sourceCount / 6).clamp(0.45, 1.0).toDouble();
    final freshnessReliability = (1 - (freshnessHours / 36))
        .clamp(0.35, 1.0)
        .toDouble();
    final reliability =
        (sampleReliability * 0.35) +
        (sourceReliability * 0.30) +
        (freshnessReliability * 0.20) +
        (materiality * 0.15);

    final state = score >= 20
        ? NewsSentimentState.positive
        : score <= -20
        ? NewsSentimentState.negative
        : score.abs() < 8
        ? NewsSentimentState.neutral
        : NewsSentimentState.mixed;

    return NewsSentimentProfile(
      state: state,
      sentimentScore: score,
      articleCount: articleCount,
      sourceCount: sourceCount,
      independentStoryCount: independentStoryCount,
      freshnessHours: freshnessHours,
      materiality: materiality,
      reliability: reliability.clamp(0.0, 0.95).toDouble(),
      summary:
          'Recent company-specific news is aggregated with source diversity, freshness and materiality so headline count alone cannot dominate the recommendation.',
    );
  }

  int _stableHash(String value) {
    var hash = 17;
    for (final codeUnit in value.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return hash;
  }
}
