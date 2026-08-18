import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/dashboard/controllers/dashboard_controller.dart';
import 'package:mobile/features/market/controllers/market_controller.dart';
import 'package:mobile/features/market/controllers/market_history_controller.dart';
import 'package:mobile/features/market/providers/mock_market_data_provider.dart';
import 'package:mobile/features/market/providers/mock_market_history_provider.dart';
import 'package:mobile/features/market/services/market_history_service.dart';
import 'package:mobile/features/market/services/market_service.dart';
import 'package:mobile/features/recommendation/controllers/recommendation_controller.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/providers/candle_trend_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/rsi_evidence_provider.dart';
import 'package:mobile/features/recommendation/services/recommendation_context_service.dart';
import 'package:mobile/features/recommendation/services/recommendation_service.dart';
import 'package:mobile/features/watchlist/controllers/watchlist_controller.dart';
import 'package:mobile/features/watchlist/models/watchlist_item.dart';

void main() {
  test(
    'recalculates Trader analysis when the primary interval changes',
    () async {
      const marketService = MarketService(MockMarketDataProvider());
      const historyService = MarketHistoryService(MockMarketHistoryProvider());

      final marketController = MarketController(marketService);
      final historyController = MarketHistoryController(historyService);
      final watchlistController = WatchlistController(
        initialItems: const [
          WatchlistItem(symbol: 'AAPL', displayName: 'Apple Inc.'),
        ],
        initialSelectedSymbol: 'AAPL',
      );
      final recommendationController = RecommendationController(
        const RecommendationService(
          providers: [CandleTrendEvidenceProvider(), RsiEvidenceProvider()],
        ),
      );

      final controller = DashboardController(
        marketController: marketController,
        marketHistoryController: historyController,
        stockHistoryService: historyService,
        recommendationContextService: const RecommendationContextService(
          marketService: marketService,
        ),
        watchlistController: watchlistController,
        recommendationController: recommendationController,
      );

      await controller.selectSymbol('AAPL');

      expect(marketController.state.snapshot!.timeframe, '5m');
      expect(recommendationController.state.recommendation!.timeframe, '5m');

      await controller.selectAnalysisTimeframe(StrategyType.trader, '15m');

      expect(
        controller.selectedPrimaryTimeframeFor(StrategyType.trader),
        '15m',
      );
      expect(marketController.state.snapshot!.timeframe, '15m');
      expect(recommendationController.state.recommendation!.timeframe, '15m');
      expect(
        recommendationController
            .state
            .analysisContext!
            .multiTimeframeProfile
            .confirmation
            .timeframe,
        '1h',
      );
      expect(
        recommendationController
            .state
            .analysisContext!
            .multiTimeframeProfile
            .regime
            .timeframe,
        '1d',
      );
    },
  );

  test('rejects unavailable Trader analysis intervals', () async {
    const marketService = MarketService(MockMarketDataProvider());
    const historyService = MarketHistoryService(MockMarketHistoryProvider());

    final controller = DashboardController(
      marketController: MarketController(marketService),
      marketHistoryController: MarketHistoryController(historyService),
      stockHistoryService: historyService,
      recommendationContextService: const RecommendationContextService(
        marketService: marketService,
      ),
      watchlistController: WatchlistController(
        initialItems: const [
          WatchlistItem(symbol: 'AAPL', displayName: 'Apple Inc.'),
        ],
        initialSelectedSymbol: 'AAPL',
      ),
      recommendationController: RecommendationController(
        const RecommendationService(providers: [CandleTrendEvidenceProvider()]),
      ),
    );

    await expectLater(
      controller.selectAnalysisTimeframe(StrategyType.trader, '2h'),
      throwsArgumentError,
    );
  });
}
