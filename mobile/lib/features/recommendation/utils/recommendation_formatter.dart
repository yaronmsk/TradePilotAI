import '../models/recommendation.dart';

class RecommendationFormatter {
  const RecommendationFormatter._();

  static String label(RecommendationType type) {
    switch (type) {
      case RecommendationType.strongBuy:
        return 'Strong Buy';

      case RecommendationType.buy:
        return 'Buy';

      case RecommendationType.hold:
        return 'No Clear Direction';

      case RecommendationType.sell:
        return 'Sell';

      case RecommendationType.strongSell:
        return 'Strong Sell';

      case RecommendationType.wait:
        return 'Wait for Confirmation';

      case RecommendationType.unknown:
        return 'Unknown';
    }
  }

  static String icon(RecommendationType type) {
    switch (type) {
      case RecommendationType.strongBuy:
      case RecommendationType.buy:
        return '🟢';

      case RecommendationType.hold:
        return '🟡';

      case RecommendationType.sell:
        return '🟠';

      case RecommendationType.strongSell:
        return '🔴';

      case RecommendationType.wait:
        return '⏳';

      case RecommendationType.unknown:
        return '⚪';
    }
  }

  static String display(RecommendationType type) {
    return '${icon(type)} ${label(type)}';
  }
}
