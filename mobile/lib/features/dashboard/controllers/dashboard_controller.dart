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
import '../../recommendation/history/historical_setup_validation_service.dart';
import '../../recommendation/investor/services/investor_analysis_service.dart';
import '../../recommendation/models/recommendation_state.dart';
import '../../recommendation/models/strategy_recommendation.dart';
import '../../recommendation/models/strategy_summary.dart';
import '../../recommendation/services/recommendation_context_service.dart';
import '../../recommendation/strategy/strategy_analysis_policy_catalog.dart';
import '../../watchlist/controllers/watchlist_controller.dart';

class DashboardController extends ChangeNotifier {
  DashboardController({
    required this.marketController,
    required this.marketHistoryController,
    required this.stockHistoryService,
    required this.recommendationContextService,
    required this.watchlistController,
    required this.recommendationController,
    this.historicalSetupValidationService,
    this.investorAnalysisService,
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
  final HistoricalSetupValidationService? historicalSetupValidationService;
  final InvestorAnalysisService? investorAnalysisService;

  final Map<StrategyType, String> _selectedPrimaryTimeframes;
  final Map<StrategyType, RecommendationState> _strategyRecommendationStates =
      <StrategyType, RecommendationState>{};

  StrategyType _activeAnalysisStrategy = StrategyType.trader;
  bool _isAnalysisReloading = false;
  int _analysisRequestId = 0;
  InvestorAnalysisResult? _investorAnalysisResult;

  bool get isAnalysisReloading => _isAnalysisReloading;

  StrategyType get activeAnalysisStrategy => _activeAnalysisStrategy;

  InvestorAnalysisResult? get investorAnalysisResult => _investorAnalysisResult;

  bool isStrategyAvailable(StrategyType strategy) {
    if (strategy == StrategyType.investor) {
      return investorAnalysisService != null;
    }

    return StrategyAnalysisPolicyCatalog.forStrategy(
      strategy,
    ).isRecommendationActive;
  }

  RecommendationState recommendationStateFor(StrategyType strategy) {
    return _strategyRecommendationStates[strategy] ??
        const RecommendationState();
  }

  List<StrategyRecommendation> get strategyRecommendations {
    return StrategyType.values
        .map((strategy) {
          final recommendation =
              _strategyRecommendationStates[strategy]?.recommendation;

          if (recommendation == null) {
            return null;
          }

          return StrategyRecommendation(
            strategy: strategy,
            recommendation: recommendation,
          );
        })
        .whereType<StrategyRecommendation>()
        .toList(growable: false);
  }

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
    _strategyRecommendationStates.clear();
    _investorAnalysisResult = null;
    _activeAnalysisStrategy = StrategyType.trader;

    await _loadStrategyAnalysis(
      symbol: symbol,
      strategy: StrategyType.trader,
      reloadChartHistory: true,
    );
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

    final policy = StrategyAnalysisPolicyCatalog.forStrategy(strategy);

    // Investor remains deferred to v0.12. Keeping its timeframe selection in
    // the shared model is safe, but no recommendation analysis may run yet.
    if (!policy.isRecommendationActive) {
      return;
    }

    await analyzeStrategy(strategy, reloadChartHistory: true);
  }

  Future<void> analyzeStrategy(
    StrategyType strategy, {
    bool reloadChartHistory = true,
  }) async {
    if (strategy == StrategyType.investor) {
      await _analyzeInvestor();
      return;
    }

    final policy = StrategyAnalysisPolicyCatalog.forStrategy(strategy);

    if (!policy.isRecommendationActive) {
      throw StateError(
        '${strategy.title} recommendation analysis is not active yet.',
      );
    }

    final symbol = watchlistController.state.selectedSymbol;

    if (symbol == null) {
      return;
    }

    _isAnalysisReloading = true;
    notifyListeners();

    try {
      await _loadStrategyAnalysis(
        symbol: symbol,
        strategy: strategy,
        reloadChartHistory: reloadChartHistory,
      );
    } finally {
      _isAnalysisReloading = false;
      notifyListeners();
    }
  }

  Future<void> _analyzeInvestor() async {
    final service = investorAnalysisService;

    if (service == null) {
      throw StateError('Investor recommendation analysis is not active yet.');
    }

    final symbol = watchlistController.state.selectedSymbol;

    if (symbol == null) {
      return;
    }

    final requestId = ++_analysisRequestId;
    _isAnalysisReloading = true;
    notifyListeners();

    try {
      final analysisTime =
          marketController.state.snapshot?.timestamp ?? DateTime.now();

      final result = await service.analyze(
        symbol: symbol,
        analysisTime: analysisTime,
      );

      if (requestId != _analysisRequestId) {
        return;
      }

      _investorAnalysisResult = result;
      _activeAnalysisStrategy = StrategyType.investor;
      _strategyRecommendationStates[StrategyType.investor] =
          RecommendationState(
            status: RecommendationStatus.ready,
            recommendation: result.recommendationAnalysis.recommendation,
          );
    } finally {
      if (requestId == _analysisRequestId) {
        _isAnalysisReloading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadStrategyAnalysis({
    required String symbol,
    required StrategyType strategy,
    required bool reloadChartHistory,
  }) async {
    final requestId = ++_analysisRequestId;
    final plan = analysisPlanFor(strategy);

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
      strategy: strategy,
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
      strategy: strategy,
    );

    if (requestId != _analysisRequestId) {
      return;
    }

    _activeAnalysisStrategy = strategy;
    _cacheRecommendationState(strategy);

    await _applyHistoricalSetupValidation(
      requestId: requestId,
      snapshot: snapshot,
      analysisContext: analysisContext,
      strategy: strategy,
    );

    await chartHistoryFuture;

    if (requestId == _analysisRequestId) {
      notifyListeners();
    }
  }

  Future<void> _applyHistoricalSetupValidation({
    required int requestId,
    required MarketSnapshot snapshot,
    required RecommendationAnalysisContext analysisContext,
    required StrategyType strategy,
  }) async {
    final service = historicalSetupValidationService;
    final recommendation = recommendationController.state.recommendation;
    final stockBehaviorProfile =
        recommendationController.state.stockBehaviorProfile;

    if (service == null ||
        recommendation == null ||
        stockBehaviorProfile == null ||
        requestId != _analysisRequestId) {
      return;
    }

    try {
      final validation = await service.validate(
        symbol: snapshot.symbol,
        strategy: strategy,
        recommendation: recommendation,
        stockBehaviorProfile: stockBehaviorProfile,
        analysisContext: analysisContext,
      );

      if (requestId != _analysisRequestId) {
        return;
      }

      recommendationController.applyHistoricalValidation(
        validation,
        strategy: strategy,
      );

      _cacheRecommendationState(strategy);
    } catch (_) {
      // Historical validation is an enhancement layer. Recommendation analysis
      // must remain usable when historical analog data is unavailable.
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
    required StrategyType strategy,
  }) async {
    try {
      return await recommendationContextService.loadContext(
        snapshot,
        plan: plan,
        strategy: strategy,
      );
    } catch (_) {
      return RecommendationAnalysisContext.unknown();
    }
  }

  void _cacheRecommendationState(StrategyType strategy) {
    _strategyRecommendationStates[strategy] = recommendationController.state;
  }
}
