import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/providers/mock_market_data_provider.dart';
import 'package:mobile/features/market/services/market_service.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/providers/candle_trend_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/relative_volume_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/rsi_evidence_provider.dart';
import 'package:mobile/features/recommendation/services/recommendation_context_service.dart';
import 'package:mobile/features/recommendation/services/recommendation_service.dart';

void main() {
  const marketService = MarketService(MockMarketDataProvider());
  const contextService = RecommendationContextService(
    marketService: marketService,
  );
  const recommendationService = RecommendationService(
    providers: [
      CandleTrendEvidenceProvider(),
      RsiEvidenceProvider(),
      RelativeVolumeEvidenceProvider(),
    ],
  );

  test(
    'adds timeframe and market context without double-counting trend family',
    () async {
      final snapshot = await marketService.loadSnapshot(
        symbol: 'NVDA',
        timeframe: '5m',
        candleCount: 48,
      );
      final context = await contextService.loadTraderContext(snapshot);

      final recommendation = recommendationService.analyze(
        snapshot,
        analysisContext: context,
      );

      expect(recommendation.evidenceReport.results.length, 5);
      expect(recommendation.evidenceReport.expectedProviderCount, 5);

      final trendEvidence = recommendation.evidenceReport.results
          .where((result) => result.definition.family == EvidenceFamily.trend)
          .toList();

      expect(trendEvidence.length, 2);
      expect(
        recommendation.consensus.familySummaries
            .where((summary) => summary.family == EvidenceFamily.trend)
            .length,
        1,
      );
      expect(
        recommendation.consensus.familySummaries.any(
          (summary) => summary.family == EvidenceFamily.marketContext,
        ),
        isTrue,
      );
    },
  );
}
