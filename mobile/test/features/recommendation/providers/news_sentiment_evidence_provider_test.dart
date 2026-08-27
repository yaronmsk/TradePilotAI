import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/external_context_profile.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/providers/news_sentiment_evidence_provider.dart';

void main() {
  const provider = NewsSentimentEvidenceProvider();

  NewsSentimentProfile swingProfile({
    required NewsSentimentState state,
    required double sentiment,
    int articles = 8,
    int sources = 4,
    int? stories = 3,
    double freshness = 12,
    double materiality = 0.75,
    double reliability = 0.90,
  }) {
    return NewsSentimentProfile(
      state: state,
      sentimentScore: sentiment,
      articleCount: articles,
      sourceCount: sources,
      independentStoryCount: stories,
      freshnessHours: freshness,
      materiality: materiality,
      reliability: reliability,
      summary: 'Synthetic Swing news test profile.',
    );
  }

  group('Trader News Sentiment regression', () {
    test('uses positive high-quality news as bullish Sentiment evidence', () {
      const profile = NewsSentimentProfile(
        state: NewsSentimentState.positive,
        sentimentScore: 55,
        articleCount: 10,
        sourceCount: 6,
        freshnessHours: 2,
        materiality: 0.85,
        reliability: 0.9,
        summary: 'Positive recent news.',
      );

      final result = provider.evaluate(profile);

      expect(result.definition.family, EvidenceFamily.sentiment);
      expect(result.direction, EvidenceDirection.bullish);
      expect(result.score, 55);
      expect(result.dynamicWeight, greaterThan(0.9));
      expect(result.baseWeight, 0.55);
    });

    test('uses negative news as bearish evidence', () {
      const profile = NewsSentimentProfile(
        state: NewsSentimentState.negative,
        sentimentScore: -42,
        articleCount: 8,
        sourceCount: 4,
        freshnessHours: 3,
        materiality: 0.7,
        reliability: 0.82,
        summary: 'Negative recent news.',
      );

      final result = provider.evaluate(profile);

      expect(result.direction, EvidenceDirection.bearish);
      expect(result.score, 42);
    });

    test('rejects low source diversity', () {
      const profile = NewsSentimentProfile(
        state: NewsSentimentState.positive,
        sentimentScore: 70,
        articleCount: 10,
        sourceCount: 1,
        freshnessHours: 1,
        materiality: 0.9,
        reliability: 0.9,
        summary: 'Repeated single-source coverage.',
      );

      final result = provider.evaluate(profile);

      expect(result.status, EvidenceStatus.insufficientData);
    });

    test('explicit Trader strategy preserves legacy result', () {
      const profile = NewsSentimentProfile(
        state: NewsSentimentState.positive,
        sentimentScore: 55,
        articleCount: 10,
        sourceCount: 6,
        freshnessHours: 2,
        materiality: 0.85,
        reliability: 0.9,
        summary: 'Positive recent news.',
      );

      final legacy = provider.evaluate(profile);

      final explicit = provider.evaluate(
        profile,
        strategy: StrategyType.trader,
      );

      expect(explicit.direction, legacy.direction);
      expect(explicit.score, legacy.score);
      expect(explicit.baseWeight, legacy.baseWeight);
      expect(explicit.dynamicWeight, legacy.dynamicWeight);
      expect(explicit.reliability, legacy.reliability);
    });
  });

  group('Swing News Sentiment', () {
    test('fresh material positive news is bullish', () {
      final result = provider.evaluate(
        swingProfile(
          state: NewsSentimentState.positive,
          sentiment: 52,
          freshness: 18,
          materiality: 0.80,
        ),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.bullish);
      expect(result.score, 52);
      expect(result.baseWeight, 0.50);
      expect(result.definition.family, EvidenceFamily.sentiment);
    });

    test('fresh material negative news preserves bearish parity', () {
      final bullish = provider.evaluate(
        swingProfile(state: NewsSentimentState.positive, sentiment: 48),
        strategy: StrategyType.swing,
      );

      final bearish = provider.evaluate(
        swingProfile(state: NewsSentimentState.negative, sentiment: -48),
        strategy: StrategyType.swing,
      );

      expect(bullish.direction, EvidenceDirection.bullish);
      expect(bearish.direction, EvidenceDirection.bearish);
      expect(bullish.score, bearish.score);
      expect(bullish.baseWeight, bearish.baseWeight);
      expect(bullish.dynamicWeight, bearish.dynamicWeight);
      expect(bullish.reliability, bearish.reliability);
    });

    test(
      'low materiality cannot create Swing direction or confidence strength',
      () {
        final result = provider.evaluate(
          swingProfile(
            state: NewsSentimentState.positive,
            sentiment: 70,
            materiality: 0.30,
          ),
          strategy: StrategyType.swing,
        );

        expect(result.direction, EvidenceDirection.neutral);
        expect(result.score, 0);
        expect(result.currentValue, 'Low materiality');
      },
    );

    test('weak sentiment remains inside the Swing neutral zone', () {
      final result = provider.evaluate(
        swingProfile(
          state: NewsSentimentState.positive,
          sentiment: 14,
          materiality: 0.90,
        ),
        strategy: StrategyType.swing,
      );

      expect(result.direction, EvidenceDirection.neutral);
      expect(result.score, 0);
      expect(result.currentValue, 'Mixed');
    });

    test('mixed classification cannot become directional', () {
      final result = provider.evaluate(
        swingProfile(
          state: NewsSentimentState.mixed,
          sentiment: 45,
          materiality: 0.90,
        ),
        strategy: StrategyType.swing,
      );

      expect(result.direction, EvidenceDirection.neutral);
      expect(result.score, 0);
    });

    test('older Swing news remains context but loses direction after 120h', () {
      final result = provider.evaluate(
        swingProfile(
          state: NewsSentimentState.positive,
          sentiment: 65,
          freshness: 130,
          materiality: 0.90,
        ),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.neutral);
      expect(result.score, 0);
      expect(result.currentValue, 'Stale');
      expect(result.dynamicWeight, lessThan(1));
    });

    test('news older than seven days becomes unusable', () {
      final result = provider.evaluate(
        swingProfile(
          state: NewsSentimentState.positive,
          sentiment: 65,
          freshness: 169,
          materiality: 0.90,
        ),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.insufficientData);
      expect(result.direction, EvidenceDirection.unknown);
      expect(result.score, 0);
    });

    test('Swing requires explicit de-duplicated independent stories', () {
      final result = provider.evaluate(
        swingProfile(
          state: NewsSentimentState.positive,
          sentiment: 65,
          stories: null,
        ),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.insufficientData);
      expect(result.unavailableReason, contains('de-duplicated'));
    });

    test('repeated article count cannot multiply Swing influence', () {
      final compactCoverage = provider.evaluate(
        swingProfile(
          state: NewsSentimentState.positive,
          sentiment: 50,
          articles: 4,
          sources: 3,
          stories: 2,
        ),
        strategy: StrategyType.swing,
      );

      final repeatedCoverage = provider.evaluate(
        swingProfile(
          state: NewsSentimentState.positive,
          sentiment: 50,
          articles: 40,
          sources: 3,
          stories: 2,
        ),
        strategy: StrategyType.swing,
      );

      expect(repeatedCoverage.direction, compactCoverage.direction);
      expect(repeatedCoverage.score, compactCoverage.score);
      expect(repeatedCoverage.dynamicWeight, compactCoverage.dynamicWeight);
      expect(repeatedCoverage.reliability, compactCoverage.reliability);
      expect(repeatedCoverage.effectiveWeight, compactCoverage.effectiveWeight);
    });

    test('Investor remains unavailable', () {
      final result = provider.evaluate(
        swingProfile(state: NewsSentimentState.positive, sentiment: 50),
        strategy: StrategyType.investor,
      );

      expect(result.status, EvidenceStatus.unavailable);
      expect(result.direction, EvidenceDirection.unknown);
    });
  });
}
