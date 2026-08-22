import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/external_context_profile.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/providers/news_sentiment_evidence_provider.dart';

void main() {
  const provider = NewsSentimentEvidenceProvider();

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
}
