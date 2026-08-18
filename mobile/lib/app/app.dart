import 'package:flutter/material.dart';

import '../core/storage/shared_preferences_storage_service.dart';
import '../features/dashboard/controllers/dashboard_controller.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/market/controllers/market_controller.dart';
import '../features/market/controllers/market_history_controller.dart';
import '../features/market/providers/mock_market_data_provider.dart';
import '../features/market/providers/mock_market_history_provider.dart';
import '../features/market/services/market_history_service.dart';
import '../features/market/services/market_service.dart';
import '../features/recommendation/controllers/recommendation_controller.dart';
import '../features/recommendation/providers/candle_trend_evidence_provider.dart';
import '../features/recommendation/providers/ema_structure_evidence_provider.dart';
import '../features/recommendation/providers/macd_momentum_evidence_provider.dart';
import '../features/recommendation/providers/price_extension_evidence_provider.dart';
import '../features/recommendation/providers/relative_volume_evidence_provider.dart';
import '../features/recommendation/providers/rsi_evidence_provider.dart';
import '../features/recommendation/providers/support_resistance_evidence_provider.dart';
import '../features/recommendation/providers/volume_confirmation_evidence_provider.dart';
import '../features/recommendation/providers/vwap_position_evidence_provider.dart';
import '../features/recommendation/services/recommendation_context_service.dart';
import '../features/recommendation/services/recommendation_service.dart';
import '../features/watchlist/controllers/watchlist_controller.dart';
import '../features/watchlist/models/watchlist_item.dart';
import '../features/watchlist/repositories/local_watchlist_repository.dart';
import 'theme.dart';

class TradePilotApp extends StatefulWidget {
  const TradePilotApp({super.key});

  @override
  State<TradePilotApp> createState() => _TradePilotAppState();
}

class _TradePilotAppState extends State<TradePilotApp> {
  late final Future<void> _initializationFuture;

  MarketController? _marketController;
  MarketHistoryController? _marketHistoryController;
  WatchlistController? _watchlistController;
  RecommendationController? _recommendationController;
  DashboardController? _dashboardController;

  static const _defaultWatchlist = [
    WatchlistItem(symbol: 'AAPL', displayName: 'Apple Inc.'),
    WatchlistItem(symbol: 'MSFT', displayName: 'Microsoft Corporation'),
    WatchlistItem(symbol: 'NVDA', displayName: 'NVIDIA Corporation'),
    WatchlistItem(symbol: 'PLTR', displayName: 'Palantir Technologies'),
    WatchlistItem(symbol: 'GOOG', displayName: 'Alphabet Inc.'),
    WatchlistItem(symbol: 'TSLA', displayName: 'Tesla Inc.'),
  ];

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeApplication();
  }

  Future<void> _initializeApplication() async {
    final storageService = SharedPreferencesStorageService();
    await storageService.initialize();

    final watchlistRepository = LocalWatchlistRepository(storageService);

    const marketService = MarketService(MockMarketDataProvider());
    final marketController = MarketController(marketService);

    const marketHistoryService = MarketHistoryService(
      MockMarketHistoryProvider(),
    );

    final marketHistoryController = MarketHistoryController(
      marketHistoryService,
    );

    final watchlistController = WatchlistController(
      repository: watchlistRepository,
      initialItems: _defaultWatchlist,
      initialSelectedSymbol: 'AAPL',
    );

    await watchlistController.initialize();

    final recommendationController = RecommendationController(
      const RecommendationService(
        providers: [
          CandleTrendEvidenceProvider(),
          EmaStructureEvidenceProvider(),
          RsiEvidenceProvider(),
          MacdMomentumEvidenceProvider(),
          RelativeVolumeEvidenceProvider(),
          VolumeConfirmationEvidenceProvider(),
          VwapPositionEvidenceProvider(),
          SupportResistanceEvidenceProvider(),
          PriceExtensionEvidenceProvider(),
        ],
      ),
    );

    final recommendationContextService = RecommendationContextService(
      marketService: marketService,
    );

    final dashboardController = DashboardController(
      marketController: marketController,
      marketHistoryController: marketHistoryController,
      stockHistoryService: marketHistoryService,
      recommendationContextService: recommendationContextService,
      watchlistController: watchlistController,
      recommendationController: recommendationController,
    );

    final selectedSymbol = watchlistController.state.selectedSymbol;

    if (selectedSymbol != null) {
      await dashboardController.selectSymbol(selectedSymbol);
    }

    _marketController = marketController;
    _marketHistoryController = marketHistoryController;
    _watchlistController = watchlistController;
    _recommendationController = recommendationController;
    _dashboardController = dashboardController;
  }

  @override
  void dispose() {
    _dashboardController?.dispose();
    _watchlistController?.dispose();
    _recommendationController?.dispose();
    _marketHistoryController?.dispose();
    _marketController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            title: 'TradePilot AI',
            debugShowCheckedModeBanner: false,
            theme: buildTradePilotTheme(),
            home: const Scaffold(
              body: Center(child: Text('Unable to initialize TradePilot AI.')),
            ),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            title: 'TradePilot AI',
            debugShowCheckedModeBanner: false,
            theme: buildTradePilotTheme(),
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MaterialApp(
          title: 'TradePilot AI',
          debugShowCheckedModeBanner: false,
          theme: buildTradePilotTheme(),
          home: DashboardPage(dashboardController: _dashboardController!),
        );
      },
    );
  }
}
