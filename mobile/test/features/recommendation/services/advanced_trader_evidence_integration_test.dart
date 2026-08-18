import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/providers/mock_market_data_provider.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/providers/candle_trend_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/ema_structure_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/macd_momentum_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/price_extension_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/relative_volume_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/rsi_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/support_resistance_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/volume_confirmation_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/vwap_position_evidence_provider.dart';
import 'package:mobile/features/recommendation/services/recommendation_service.dart';

void main() {
  const marketProvider = MockMarketDataProvider();
  const service = RecommendationService(
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
  );

  test(
    'advanced Trader evidence expands signals without multiplying families',
    () async {
      final snapshot = await marketProvider.fetchSnapshot(
        symbol: 'NVDA',
        timeframe: '5m',
        candleCount: 48,
      );

      final recommendation = service.analyze(snapshot);
      final results = recommendation.evidenceReport.results;

      expect(results, hasLength(9));
      expect(
        results.where((item) => item.definition.family == EvidenceFamily.trend),
        hasLength(2),
      );
      expect(
        results.where(
          (item) => item.definition.family == EvidenceFamily.momentum,
        ),
        hasLength(2),
      );
      expect(
        results.where(
          (item) => item.definition.family == EvidenceFamily.participation,
        ),
        hasLength(2),
      );
      expect(
        results.where(
          (item) => item.definition.family == EvidenceFamily.priceStructure,
        ),
        hasLength(2),
      );
      expect(
        results.where(
          (item) => item.definition.family == EvidenceFamily.volatility,
        ),
        hasLength(1),
      );

      expect(recommendation.consensus.independentFamilyCount, 5);
    },
  );
}
