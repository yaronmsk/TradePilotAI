import 'package:flutter/material.dart';

import '../models/recommendation.dart';
import '../utils/recommendation_formatter.dart';

class RecommendationPresentation {
  const RecommendationPresentation({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final String icon;
  final Color color;

  factory RecommendationPresentation.fromType(RecommendationType type) {
    return RecommendationPresentation(
      label: RecommendationFormatter.label(type),
      icon: RecommendationFormatter.icon(type),
      color: _color(type),
    );
  }

  static Color _color(RecommendationType type) {
    switch (type) {
      case RecommendationType.strongBuy:
      case RecommendationType.buy:
        return Colors.green;

      case RecommendationType.hold:
        return Colors.orange;

      case RecommendationType.sell:
      case RecommendationType.strongSell:
        return Colors.red;

      case RecommendationType.wait:
        return Colors.blueGrey;

      case RecommendationType.unknown:
        return Colors.grey;
    }
  }
}
