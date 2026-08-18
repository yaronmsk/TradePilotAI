import 'package:flutter/foundation.dart';

import '../../market/controllers/market_controller.dart';
import '../../market/controllers/market_history_controller.dart';
import '../../market/models/market_candle.dart';
import '../../market/models/market_history_range.dart';
import '../../market/models/market_snapshot.dart';
import '../../market/services/market_history_service.dart';
import '../../recommendation/context/recommendation_analysis_context.dart';
import '../../recommendation/context/strategy_timeframe_plan.dart';
import '../../recommendation/controllers/recommendation_controller.dart';
import '../../recommendation/models/strategy_summary.dart';
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
  }) : _selectedPrimaryTimeframes = <StrategyType, String>{
         StrategyType.trader: StrategyTimeframePlan.defaultPrimaryTimeframeFor(
           StrategyType.trader,
         ),
         StrategyType.swing: StrategyTimeframePlan.defaultPrimaryTimeframeFor(
           StrategyType.swing,
         ),
         StrategyType.investor:
             StrategyTimeframePlan.defaultPrimaryTimeframeFor(
               StrategyType.investor,
             ),
       };

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

  final Map<StrategyType, String> _selectedPrimaryTimeframes;

  bool _isAnalysisReloading = false;
  int _analysisRequestId = 0;

  bool get isAnalysisReloading => _isAnalysisReloading;

  String selectedPrimaryTimeframeFor(StrategyType strategy) {
    return _selectedPrimaryTimeframes[strategy] ??
        StrategyTimeframePlan.defaultPrimaryTimeframeFor(strategy);
  }

  List<String> availablePrimaryTimeframesFor(StrategyType strategy) {
    return StrategyTimeframePlan.primaryTimeframesFor(strategy);
  }

  StrategyTimeframePlan analysisPlanFor(StrategyType strategy) {
    return StrategyTimeframePlan.forStrategy(
      strategy,
      primaryTimeframe: selectedPrimaryTimeframeFor(strategy),
    );
  }

  Future<void> selectSymbol(String symbol) async {
    watchlistController.selectSymbol(symbol);

    recommendationController.reset();
    marketHistoryController.reset();

    await _loadTraderAnalysis(symbol: symbol, reloadChartHistory: true);
  }

  Future<void> selectAnalysisTimeframe(
    StrategyType strategy,
    String timeframe,
  ) async {
    final available = availablePrimaryTimeframesFor(strategy);

    if (!available.contains(timeframe)) {
      throw ArgumentError.value(
        timeframe,
        'timeframe',
        'Unsupported ${strategy.title} analysis timeframe.',
      );
    }

    if (selectedPrimaryTimeframeFor(strategy) == timeframe) {
      return;
    }

    _selectedPrimaryTimeframes[strategy] = timeframe;
    notifyListeners();

    // Swing and Investor are not active yet. Their selected defaults are kept
    // in the same strategy-aware model now so their future engines can plug in
    // without redesigning the dashboard contract.
    if (strategy != StrategyType.trader) {
      return;
    }

    final symbol = watchlistController.state.selectedSymbol;

    if (symbol == null) {
      return;
    }

    _isAnalysisReloading = true;
    notifyListeners();

    try {
      await _loadTraderAnalysis(symbol: symbol, reloadChartHistory: true);
    } finally {
      _isAnalysisReloading = false;
      notifyListeners();
    }
  }

  Future<void> _loadTraderAnalysis({
    required String symbol,
    required bool reloadChartHistory,
  }) async {
    final requestId = ++_analysisRequestId;
    final plan = analysisPlanFor(StrategyType.trader);

    await marketController.loadSnapshot(
      symbol: symbol,
      timeframe: plan.primaryTimeframe,
      candleCount: plan.primaryCandleCount,
    );

    if (requestId != _analysisRequestId) {
      return;
    }

    final snapshot = marketController.state.snapshot;

    if (snapshot == null) {
      notifyListeners();
      return;
    }

    final chartHistoryFuture = reloadChartHistory
        ? marketHistoryController.load(
            symbol: snapshot.symbol,
            endPrice: snapshot.currentPrice,
          )
        : Future<void>.value();

    final stockDnaFuture = _loadStockDnaHistory(
      symbol: snapshot.symbol,
      endPrice: snapshot.currentPrice,
    );

    final analysisContextFuture = _loadRecommendationContext(
      snapshot,
      plan: plan,
    );

    final historicalDailyCandles = await stockDnaFuture;
    final analysisContext = await analysisContextFuture;

    if (requestId != _analysisRequestId) {
      return;
    }

    recommendationController.analyze(
      snapshot,
      historicalDailyCandles: historicalDailyCandles,
      analysisContext: analysisContext,
    );

    await chartHistoryFuture;

    if (requestId == _analysisRequestId) {
      notifyListeners();
    }
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
    MarketSnapshot snapshot, {
    required StrategyTimeframePlan plan,
  }) async {
    try {
      return await recommendationContextService.loadTraderContext(
        snapshot,
        plan: plan,
      );
    } catch (_) {
      return RecommendationAnalysisContext.unknown();
    }
  }
}
