import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/recommendation.dart';
import 'package:mobile/features/recommendation/utils/recommendation_formatter.dart';

void main() {
  group('RecommendationFormatter', () {
    test('formats Strong Buy', () {
      expect(
        RecommendationFormatter.display(RecommendationType.strongBuy),
        '🟢 Strong Buy',
      );
    });

    test('formats Strong Sell', () {
      expect(
        RecommendationFormatter.display(RecommendationType.strongSell),
        '🔴 Strong Sell',
      );
    });

    test('formats No Clear Direction', () {
      expect(
        RecommendationFormatter.display(RecommendationType.hold),
        '🟡 No Clear Direction',
      );
    });

    test('formats Wait for Confirmation', () {
      expect(
        RecommendationFormatter.display(RecommendationType.wait),
        '⏳ Wait for Confirmation',
      );
    });
  });
}
