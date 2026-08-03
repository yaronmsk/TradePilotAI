import 'package:flutter/foundation.dart';

import '../../market/controllers/market_controller.dart';
import '../../recommendation/controllers/recommendation_controller.dart';
import '../../watchlist/controllers/watchlist_controller.dart';

class DashboardController extends ChangeNotifier {
  DashboardController({
    required this.marketController,
    required this.watchlistController,
    required this.recommendationController,
    this.defaultTimeframe = '5m',
    this.defaultCandleCount = 48,
  });

  final MarketController marketController;
  final WatchlistController watchlistController;
  final RecommendationController recommendationController;

  final String defaultTimeframe;
  final int defaultCandleCount;

  Future<void> selectSymbol(String symbol) async {
    watchlistController.selectSymbol(symbol);
    recommendationController.reset();

    await marketController.loadSnapshot(
      symbol: symbol,
      timeframe: defaultTimeframe,
      candleCount: defaultCandleCount,
    );

    final snapshot = marketController.state.snapshot;

    if (snapshot != null) {
      recommendationController.analyze(snapshot);
    }

    notifyListeners();
  }
}
