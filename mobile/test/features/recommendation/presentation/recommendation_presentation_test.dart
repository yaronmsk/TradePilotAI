import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/recommendation.dart';
import 'package:mobile/features/recommendation/presentation/recommendation_presentation.dart';

void main() {
  group('RecommendationPresentation', () {
    test('creates presentation for Strong Buy', () {
      final presentation = RecommendationPresentation.fromType(
        RecommendationType.strongBuy,
      );

      expect(presentation.label, 'Strong Buy');
      expect(presentation.icon, '🟢');
      expect(presentation.color, Colors.green);
    });

    test('creates presentation for No Clear Direction', () {
      final presentation = RecommendationPresentation.fromType(
        RecommendationType.hold,
      );

      expect(presentation.label, 'No Clear Direction');
      expect(presentation.icon, '🟡');
      expect(presentation.color, Colors.orange);
    });

    test('creates presentation for Wait for Confirmation', () {
      final presentation = RecommendationPresentation.fromType(
        RecommendationType.wait,
      );

      expect(presentation.label, 'Wait for Confirmation');
      expect(presentation.icon, '⏳');
      expect(presentation.color, Colors.blueGrey);
    });

    test('creates presentation for Strong Sell', () {
      final presentation = RecommendationPresentation.fromType(
        RecommendationType.strongSell,
      );

      expect(presentation.label, 'Strong Sell');
      expect(presentation.icon, '🔴');
      expect(presentation.color, Colors.red);
    });
  });
}
