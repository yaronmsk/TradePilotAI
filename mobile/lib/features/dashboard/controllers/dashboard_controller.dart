import 'package:flutter/foundation.dart';

import '../../market/controllers/market_controller.dart';
import '../../market/controllers/market_history_controller.dart';
import '../../market/models/market_candle.dart';
import '../../market/models/market_history_range.dart';
import '../../market/services/market_history_service.dart';
import '../../recommendation/controllers/recommendation_controller.dart';
import '../../watchlist/controllers/watchlist_controller.dart';

class DashboardController extends ChangeNotifier {
  DashboardController({
    required this.marketController,
    required this.marketHistoryController,
    required this.stockHistoryService,
    required this.watchlistController,
    required this.recommendationController,
    this.defaultTimeframe = '5m',
    this.defaultCandleCount = 48,
  });

  final MarketController marketController;
  final MarketHistoryController marketHistoryController;

  /// Dedicated history service used by the recommendation brain. It always
  /// requests a fixed one-year daily baseline and is intentionally independent
  /// from the user-selected chart range.
  final MarketHistoryService stockHistoryService;

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
      final chartHistoryFuture = marketHistoryController.load(
        symbol: snapshot.symbol,
        endPrice: snapshot.currentPrice,
      );

      final historicalDailyCandles = await _loadStockDnaHistory(
        symbol: snapshot.symbol,
        endPrice: snapshot.currentPrice,
      );

      recommendationController.analyze(
        snapshot,
        historicalDailyCandles: historicalDailyCandles,
      );

      await chartHistoryFuture;
    }

    notifyListeners();
  }

  Future<List<MarketCandle>> _loadStockDnaHistory({
    required String symbol,
    required double endPrice,
  }) async {
    try {
      return await stockHistoryService.loadHistory(
        symbol: symbol,
        range: MarketHistoryRange.oneYear,
        endPrice: endPrice,
      );
    } catch (_) {
      // The recommendation engine can still operate using the short-term
      // snapshot if the long-term history provider is temporarily unavailable.
      return const <MarketCandle>[];
    }
  }
}
