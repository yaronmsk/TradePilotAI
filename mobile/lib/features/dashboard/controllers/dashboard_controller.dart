import 'package:flutter/foundation.dart';

import '../../market/controllers/market_controller.dart';
import '../../market/controllers/market_history_controller.dart';
import '../../market/models/market_candle.dart';
import '../../market/models/market_history_range.dart';
import '../../market/models/market_snapshot.dart';
import '../../market/services/market_history_service.dart';
import '../../recommendation/context/recommendation_analysis_context.dart';
import '../../recommendation/controllers/recommendation_controller.dart';
import '../../recommendation/services/recommendation_context_service.dart';
import '../../watchlist/controllers/watchlist_controller.dart';

class DashboardController extends ChangeNotifier {
  DashboardController({
    required this.marketController,
    required this.marketHistoryController,
    required this.stockHistoryService,
    required this.recommendationContextService,
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

  /// Loads higher-timeframe stock data plus broad-market and sector benchmarks
  /// for the active strategy. This is independent from the visual chart range.
  final RecommendationContextService recommendationContextService;

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

      final stockDnaFuture = _loadStockDnaHistory(
        symbol: snapshot.symbol,
        endPrice: snapshot.currentPrice,
      );

      final analysisContextFuture = _loadRecommendationContext(snapshot);

      final historicalDailyCandles = await stockDnaFuture;
      final analysisContext = await analysisContextFuture;

      recommendationController.analyze(
        snapshot,
        historicalDailyCandles: historicalDailyCandles,
        analysisContext: analysisContext,
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
      return const <MarketCandle>[];
    }
  }

  Future<RecommendationAnalysisContext> _loadRecommendationContext(
    MarketSnapshot snapshot,
  ) async {
    try {
      return await recommendationContextService.loadTraderContext(snapshot);
    } catch (_) {
      return RecommendationAnalysisContext.unknown();
    }
  }
}
