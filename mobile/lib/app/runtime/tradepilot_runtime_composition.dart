import '../../core/config/tradepilot_runtime_config.dart';
import '../../core/network/tradepilot_gateway_client.dart';
import '../../features/market/providers/gateway_market_data_provider.dart';
import '../../features/market/providers/gateway_market_history_provider.dart';
import '../../features/market/providers/market_data_provider.dart';
import '../../features/market/providers/market_history_provider.dart';
import '../../features/market/providers/mock_market_data_provider.dart';
import '../../features/market/providers/mock_market_history_provider.dart';
import '../../features/recommendation/context/external_context_provider.dart';
import '../../features/recommendation/context/mock_external_context_provider.dart';
import '../../features/recommendation/context/mock_security_context_resolver.dart';
import '../../features/recommendation/context/security_context_resolver.dart';
import '../../features/recommendation/context/static_us_security_context_resolver.dart';
import '../../features/recommendation/context/unavailable_external_context_provider.dart';

class TradePilotRuntimeComposition {
  const TradePilotRuntimeComposition({
    required this.marketDataProvider,
    required this.marketHistoryProvider,
    required this.externalContextProvider,
    required this.securityContextResolver,
    required this.enableSyntheticHistoricalValidation,
    required this.enableSyntheticInvestorAnalysis,
    required this.ownedGatewayClient,
  });

  final MarketDataProvider marketDataProvider;
  final MarketHistoryProvider marketHistoryProvider;
  final ExternalContextProvider externalContextProvider;
  final SecurityContextResolver securityContextResolver;

  /// Synthetic historical analogs are regression fixtures only. They must not
  /// adjust confidence when market analysis is running in LIVE mode.
  final bool enableSyntheticHistoricalValidation;

  /// Investor remains synthetic until the SEC live slice is connected.
  final bool enableSyntheticInvestorAnalysis;

  /// Non-null only when this composition created the HTTP client and therefore
  /// owns its lifecycle.
  final HttpTradePilotGatewayClient? ownedGatewayClient;
}

TradePilotRuntimeComposition buildTradePilotRuntimeComposition(
  TradePilotRuntimeConfig config, {
  TradePilotGatewayClient? gatewayClient,
}) {
  switch (config.mode) {
    case TradePilotRuntimeMode.synthetic:
      return const TradePilotRuntimeComposition(
        marketDataProvider: MockMarketDataProvider(),
        marketHistoryProvider: MockMarketHistoryProvider(),
        externalContextProvider: MockExternalContextProvider(),
        securityContextResolver: MockSecurityContextResolver(),
        enableSyntheticHistoricalValidation: true,
        enableSyntheticInvestorAnalysis: true,
        ownedGatewayClient: null,
      );

    case TradePilotRuntimeMode.live:
      final baseUri = config.gatewayBaseUri;
      if (baseUri == null) {
        throw StateError('Live runtime requires a TradePilot gateway URL.');
      }

      final ownedClient = gatewayClient == null
          ? HttpTradePilotGatewayClient(baseUri: baseUri)
          : null;
      final resolvedClient = gatewayClient ?? ownedClient!;

      return TradePilotRuntimeComposition(
        marketDataProvider: GatewayMarketDataProvider(resolvedClient),
        marketHistoryProvider: GatewayMarketHistoryProvider(resolvedClient),
        externalContextProvider: const UnavailableExternalContextProvider(),
        securityContextResolver: const StaticUsSecurityContextResolver(),
        enableSyntheticHistoricalValidation: false,
        enableSyntheticInvestorAnalysis: false,
        ownedGatewayClient: ownedClient,
      );
  }
}
