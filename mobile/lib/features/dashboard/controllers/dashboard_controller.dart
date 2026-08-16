import 'package:flutter/foundation.dart';

import '../../market/controllers/market_controller.dart';
import '../../market/controllers/market_history_controller.dart';
import '../../recommendation/controllers/recommendation_controller.dart';
import '../../watchlist/controllers/watchlist_controller.dart';

class DashboardController extends ChangeNotifier {
  DashboardController({
    required this.marketController,
    required this.marketHistoryController,
    required this.watchlistController,
    required this.recommendationController,
    this.defaultTimeframe = '5m',
    this.defaultCandleCount = 48,
  });

  final MarketController marketController;
  final MarketHistoryController marketHistoryController;
  final WatchlistController watchlistController;
  final RecommendationController recommendationController;

  final String defaultTimeframe;
  final int defaultCandleCount;

  Future<void> selectSymbol(String symbol) async {
    watchlistController.selectSymbol(symbol);

    recommendationController.reset();
    marketHistoryController.reset();

    await marketController.loadSnapshot(
      symbol: symbol,
      timeframe: defaultTimeframe,
      candleCount: defaultCandleCount,
    );

    final snapshot = marketController.state.snapshot;

    if (snapshot != null) {
      recommendationController.analyze(snapshot);

      await marketHistoryController.load(
        symbol: snapshot.symbol,
        endPrice: snapshot.currentPrice,
      );
    }

    notifyListeners();
  }
}
