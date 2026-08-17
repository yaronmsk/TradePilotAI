import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/providers/mock_market_data_provider.dart';
import 'package:mobile/features/market/services/market_service.dart';
import 'package:mobile/features/recommendation/context/market_context_profile.dart';
import 'package:mobile/features/recommendation/context/multi_timeframe_profile.dart';
import 'package:mobile/features/recommendation/services/recommendation_context_service.dart';

void main() {
  const marketService = MarketService(MockMarketDataProvider());
  const service = RecommendationContextService(marketService: marketService);

  test('builds aligned higher-timeframe and market context for NVDA', () async {
    final primary = await marketService.loadSnapshot(
      symbol: 'NVDA',
      timeframe: '5m',
      candleCount: 48,
    );

    final context = await service.loadTraderContext(primary);

    expect(context.multiTimeframeProfile.hasSufficientData, isTrue);
    expect(context.multiTimeframeProfile.alignment, TimeframeAlignment.aligned);
    expect(context.marketContextProfile.hasSufficientData, isTrue);
    expect(
      context.marketContextProfile.relativeStrength,
      RelativeStrengthState.outperforming,
    );
  });

  test('captures mixed Trader timeframe context for PLTR', () async {
    final primary = await marketService.loadSnapshot(
      symbol: 'PLTR',
      timeframe: '5m',
      candleCount: 48,
    );

    final context = await service.loadTraderContext(primary);

    expect(context.multiTimeframeProfile.hasSufficientData, isTrue);
    expect(context.multiTimeframeProfile.alignment, TimeframeAlignment.opposed);
  });
}
