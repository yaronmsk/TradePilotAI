import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/dashboard/controllers/dashboard_controller.dart';
import 'package:mobile/features/market/controllers/market_controller.dart';
import 'package:mobile/features/market/controllers/market_history_controller.dart';
import 'package:mobile/features/market/providers/mock_market_data_provider.dart';
import 'package:mobile/features/market/providers/mock_market_history_provider.dart';
import 'package:mobile/features/market/services/market_history_service.dart';
import 'package:mobile/features/market/services/market_service.dart';
import 'package:mobile/features/recommendation/controllers/recommendation_controller.dart';
import 'package:mobile/features/recommendation/history/historical_setup_validation_service.dart';
import 'package:mobile/features/recommendation/history/mock_historical_setup_provider.dart';
import 'package:mobile/features/recommendation/investor/history/investor_historical_validation_service.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_estimate_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_fundamental_data_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_historical_data_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_macro_data_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_ownership_positioning_provider.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_valuation_data_provider.dart';
import 'package:mobile/features/recommendation/investor/services/investor_analysis_service.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/providers/candle_trend_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/rsi_evidence_provider.dart';
import 'package:mobile/features/recommendation/services/recommendation_context_service.dart';
import 'package:mobile/features/recommendation/services/recommendation_service.dart';
import 'package:mobile/features/watchlist/controllers/watchlist_controller.dart';
import 'package:mobile/features/watchlist/models/watchlist_item.dart';

DashboardController buildController() {
  const marketService = MarketService(MockMarketDataProvider());

  const historyService = MarketHistoryService(MockMarketHistoryProvider());

  const investorMacroProvider = MockInvestorMacroDataProvider();

  return DashboardController(
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
      const RecommendationService(
        providers: [CandleTrendEvidenceProvider(), RsiEvidenceProvider()],
      ),
    ),
    historicalSetupValidationService: const HistoricalSetupValidationService(
      provider: MockHistoricalSetupProvider(),
    ),
    investorAnalysisService: const InvestorAnalysisService(
      fundamentalDataProvider: MockInvestorFundamentalDataProvider(),
      analystEstimateProvider: MockInvestorEstimateProvider(),
      marketValuationDataProvider: MockInvestorValuationDataProvider(),
      macroContextProvider: investorMacroProvider,
      sensitivityDataProvider: investorMacroProvider,
      ownershipPositioningProvider: MockInvestorOwnershipPositioningProvider(),
      historicalValidationService: InvestorHistoricalValidationService(
        provider: MockInvestorHistoricalDataProvider(),
      ),
    ),
  );
}

void main() {
  test('retains independent Trader and Swing recommendation states', () async {
    final controller = buildController();

    await controller.selectSymbol('AAPL');

    final traderState = controller.recommendationStateFor(StrategyType.trader);

    expect(traderState.recommendation, isNotNull);
    expect(traderState.recommendation!.timeframe, '5m');

    expect(
      controller.strategyRecommendations.map((item) => item.strategy).toList(),
      [StrategyType.trader],
    );

    await controller.analyzeStrategy(StrategyType.swing);

    final swingState = controller.recommendationStateFor(StrategyType.swing);

    expect(controller.activeAnalysisStrategy, StrategyType.swing);

    expect(swingState.recommendation, isNotNull);
    expect(swingState.recommendation!.timeframe, '1d');

    expect(
      swingState.analysisContext!.multiTimeframeProfile.confirmation.timeframe,
      '1w',
    );

    expect(
      swingState.analysisContext!.multiTimeframeProfile.regime.timeframe,
      '1mo',
    );

    expect(
      swingState.recommendation!.historicalValidation.outcomeWindowLabel,
      contains('10 trading-day'),
    );

    final cached = controller.strategyRecommendations;

    expect(cached, hasLength(2));
    expect(cached[0].strategy, StrategyType.trader);
    expect(cached[1].strategy, StrategyType.swing);

    // Running Swing must not overwrite the cached Trader result.
    expect(
      controller
          .recommendationStateFor(StrategyType.trader)
          .recommendation!
          .timeframe,
      '5m',
    );
  });

  test(
    'recalculates Swing orchestration when switching from 1D to 4H',
    () async {
      final controller = buildController();

      await controller.selectSymbol('AAPL');
      await controller.analyzeStrategy(StrategyType.swing);

      await controller.selectAnalysisTimeframe(StrategyType.swing, '4h');

      final swingState = controller.recommendationStateFor(StrategyType.swing);

      expect(controller.selectedPrimaryTimeframeFor(StrategyType.swing), '4h');

      expect(controller.marketController.state.snapshot!.timeframe, '4h');

      expect(swingState.recommendation!.timeframe, '4h');

      expect(
        swingState
            .analysisContext!
            .multiTimeframeProfile
            .confirmation
            .timeframe,
        '1d',
      );

      expect(
        swingState.analysisContext!.multiTimeframeProfile.regime.timeframe,
        '1w',
      );

      expect(
        swingState.recommendation!.historicalValidation.outcomeWindowLabel,
        contains('15 × 4h'),
      );
    },
  );

  test(
    'Investor uses dedicated orchestration without overwriting Trader state',
    () async {
      final controller = buildController();

      await controller.selectSymbol('AAPL');

      expect(controller.isStrategyAvailable(StrategyType.investor), isTrue);
      expect(controller.marketController.state.snapshot!.timeframe, '5m');

      final traderRecommendation = controller
          .recommendationStateFor(StrategyType.trader)
          .recommendation;

      await controller.analyzeStrategy(StrategyType.investor);

      expect(controller.activeAnalysisStrategy, StrategyType.investor);
      expect(controller.investorAnalysisResult, isNotNull);
      expect(controller.investorAnalysisResult!.isSynthetic, isTrue);
      expect(
        controller.recommendationStateFor(StrategyType.investor).recommendation,
        isNotNull,
      );
      expect(
        controller
            .recommendationStateFor(StrategyType.investor)
            .recommendation!
            .timeframe,
        'Months to years',
      );

      // Investor does not repurpose the chart into a fake long-horizon candle
      // analysis; the shared market snapshot remains where Trader left it.
      expect(controller.marketController.state.snapshot!.timeframe, '5m');

      expect(
        controller.recommendationStateFor(StrategyType.trader).recommendation,
        same(traderRecommendation),
      );

      expect(
        controller.strategyRecommendations.map((item) => item.strategy),
        containsAll([StrategyType.trader, StrategyType.investor]),
      );
    },
  );
}
