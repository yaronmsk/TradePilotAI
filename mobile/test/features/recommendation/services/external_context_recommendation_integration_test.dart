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
    'adds breadth and news while keeping market context family capped',
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

      final marketResults = recommendation.evidenceReport.results
          .where(
            (result) =>
                result.definition.family == EvidenceFamily.marketContext,
          )
          .toList();
      final sentimentResults = recommendation.evidenceReport.results
          .where(
            (result) => result.definition.family == EvidenceFamily.sentiment,
          )
          .toList();

      expect(marketResults, hasLength(2));
      expect(sentimentResults, hasLength(1));
      expect(
        recommendation.consensus.familySummaries.where(
          (summary) => summary.family == EvidenceFamily.marketContext,
        ),
        hasLength(1),
      );
      expect(
        recommendation.consensus.familySummaries.where(
          (summary) => summary.family == EvidenceFamily.sentiment,
        ),
        hasLength(1),
      );
    },
  );

  test('event risk changes confidence but not direction', () async {
    final snapshot = await marketService.loadSnapshot(
      symbol: 'NVDA',
      timeframe: '5m',
      candleCount: 48,
    );
    final context = await contextService.loadTraderContext(snapshot);

    final withContext = recommendationService.analyze(
      snapshot,
      analysisContext: context,
    );

    final evidenceOnly = recommendationService.analyze(snapshot);

    expect(
      withContext.consensus.confidenceModifiers.any(
        (item) => item.label == 'Upcoming event risk',
      ),
      isTrue,
    );
    expect(
      withContext.confidenceScore,
      lessThan(withContext.consensus.evidenceConfidence),
    );
    expect(
      evidenceOnly.consensus.confidenceModifiers.last.label,
      'Data reliability',
    );
  });
}
