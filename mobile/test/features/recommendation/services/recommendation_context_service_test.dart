import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/providers/mock_market_data_provider.dart';
import 'package:mobile/features/market/services/market_service.dart';
import 'package:mobile/features/recommendation/context/market_context_profile.dart';
import 'package:mobile/features/recommendation/context/multi_timeframe_profile.dart';
import 'package:mobile/features/recommendation/context/strategy_timeframe_plan.dart';
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

    expect(context.externalContextProfile.marketBreadth.isAvailable, isTrue);
    expect(context.externalContextProfile.eventRisk.isAvailable, isTrue);
    expect(context.externalContextProfile.newsSentiment.isAvailable, isTrue);
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

  test('honors a selected Trader primary timeframe plan', () async {
    final primary = await marketService.loadSnapshot(
      symbol: 'NVDA',
      timeframe: '15m',
      candleCount: 48,
    );

    final plan = StrategyTimeframePlan.traderForPrimary('15m');

    final context = await service.loadTraderContext(primary, plan: plan);

    expect(context.multiTimeframeProfile.plan.primaryTimeframe, '15m');
    expect(context.multiTimeframeProfile.primary.timeframe, '15m');
    expect(context.multiTimeframeProfile.confirmation.timeframe, '1h');
    expect(context.multiTimeframeProfile.regime.timeframe, '1d');
  });

  test('loads the approved default Swing context hierarchy', () async {
    final plan = StrategyTimeframePlan.swing;

    final primary = await marketService.loadSnapshot(
      symbol: 'NVDA',
      timeframe: plan.primaryTimeframe,
      candleCount: plan.primaryCandleCount,
    );

    final context = await service.loadSwingContext(primary, plan: plan);

    expect(context.multiTimeframeProfile.hasSufficientData, isTrue);

    expect(context.multiTimeframeProfile.primary.timeframe, '1d');
    expect(context.multiTimeframeProfile.confirmation.timeframe, '1w');
    expect(context.multiTimeframeProfile.regime.timeframe, '1mo');

    expect(context.multiTimeframeProfile.alignment, TimeframeAlignment.aligned);

    expect(context.marketContextProfile.hasSufficientData, isTrue);
  });

  test('loads the approved alternate 4h Swing context hierarchy', () async {
    final plan = StrategyTimeframePlan.swingForPrimary('4h');

    final primary = await marketService.loadSnapshot(
      symbol: 'NVDA',
      timeframe: plan.primaryTimeframe,
      candleCount: plan.primaryCandleCount,
    );

    final context = await service.loadSwingContext(primary, plan: plan);

    expect(context.multiTimeframeProfile.hasSufficientData, isTrue);

    expect(context.multiTimeframeProfile.primary.timeframe, '4h');
    expect(context.multiTimeframeProfile.confirmation.timeframe, '1d');
    expect(context.multiTimeframeProfile.regime.timeframe, '1w');

    expect(context.multiTimeframeProfile.alignment, TimeframeAlignment.aligned);

    expect(context.marketContextProfile.hasSufficientData, isTrue);
  });
}
