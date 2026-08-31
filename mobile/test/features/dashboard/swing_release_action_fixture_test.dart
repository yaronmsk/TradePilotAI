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
import 'package:mobile/features/recommendation/models/recommendation.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/providers/candle_trend_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/ema_structure_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/macd_momentum_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/price_extension_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/relative_volume_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/rsi_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/support_resistance_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/volume_confirmation_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/vwap_position_evidence_provider.dart';
import 'package:mobile/features/recommendation/services/recommendation_context_service.dart';
import 'package:mobile/features/recommendation/services/recommendation_service.dart';
import 'package:mobile/features/watchlist/controllers/watchlist_controller.dart';
import 'package:mobile/features/watchlist/models/watchlist_item.dart';

void main() {
  test(
    'development BULL fixture exercises actionable Swing BUY through dashboard orchestration',
    () async {
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
            WatchlistItem(symbol: 'BULL', displayName: 'BULL'),
          ],
          initialSelectedSymbol: 'BULL',
        ),
        recommendationController: RecommendationController(
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
        ),
        historicalSetupValidationService:
            const HistoricalSetupValidationService(
              provider: MockHistoricalSetupProvider(),
            ),
      );

      await controller.selectSymbol('BULL');
      await controller.selectAnalysisTimeframe(StrategyType.swing, '4h');

      final recommendation = controller
          .recommendationStateFor(StrategyType.swing)
          .recommendation;

      expect(recommendation, isNotNull);
      expect(
        recommendation!.type,
        anyOf(RecommendationType.buy, RecommendationType.strongBuy),
      );
      expect(recommendation.directionScore, greaterThanOrEqualTo(35));
      expect(recommendation.confidenceScore, greaterThanOrEqualTo(60));
      expect(
        recommendation.consensus.independentFamilyCount,
        greaterThanOrEqualTo(3),
      );

      controller.dispose();
    },
  );
}
