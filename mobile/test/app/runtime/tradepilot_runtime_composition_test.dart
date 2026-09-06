import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/runtime/tradepilot_runtime_composition.dart';
import 'package:mobile/core/config/tradepilot_runtime_config.dart';
import 'package:mobile/core/network/tradepilot_gateway_client.dart';
import 'package:mobile/features/market/providers/gateway_market_data_provider.dart';
import 'package:mobile/features/market/providers/gateway_market_history_provider.dart';
import 'package:mobile/features/market/providers/mock_market_data_provider.dart';
import 'package:mobile/features/market/providers/mock_market_history_provider.dart';
import 'package:mobile/features/recommendation/context/mock_external_context_provider.dart';
import 'package:mobile/features/recommendation/context/static_us_security_context_resolver.dart';
import 'package:mobile/features/recommendation/context/unavailable_external_context_provider.dart';

class _FakeGatewayClient implements TradePilotGatewayClient {
  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String> queryParameters = const {},
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  test('synthetic runtime preserves deterministic regression providers', () {
    final composition = buildTradePilotRuntimeComposition(
      const TradePilotRuntimeConfig(
        mode: TradePilotRuntimeMode.synthetic,
        gatewayBaseUri: null,
      ),
    );

    expect(composition.marketDataProvider, isA<MockMarketDataProvider>());
    expect(composition.marketHistoryProvider, isA<MockMarketHistoryProvider>());
    expect(
      composition.externalContextProvider,
      isA<MockExternalContextProvider>(),
    );
    expect(composition.enableSyntheticHistoricalValidation, isTrue);
    expect(composition.enableSyntheticInvestorAnalysis, isTrue);
    expect(composition.ownedGatewayClient, isNull);
  });

  test(
    'live runtime uses gateway market providers without synthetic overlays',
    () {
      final composition = buildTradePilotRuntimeComposition(
        TradePilotRuntimeConfig(
          mode: TradePilotRuntimeMode.live,
          gatewayBaseUri: Uri.parse('http://127.0.0.1:8787'),
        ),
        gatewayClient: _FakeGatewayClient(),
      );

      expect(composition.marketDataProvider, isA<GatewayMarketDataProvider>());
      expect(
        composition.marketHistoryProvider,
        isA<GatewayMarketHistoryProvider>(),
      );
      expect(
        composition.externalContextProvider,
        isA<UnavailableExternalContextProvider>(),
      );
      expect(
        composition.securityContextResolver,
        isA<StaticUsSecurityContextResolver>(),
      );
      expect(composition.enableSyntheticHistoricalValidation, isFalse);
      expect(composition.enableSyntheticInvestorAnalysis, isFalse);
      expect(composition.ownedGatewayClient, isNull);
    },
  );

  test('live runtime owns HTTP gateway client when none is injected', () {
    final composition = buildTradePilotRuntimeComposition(
      TradePilotRuntimeConfig(
        mode: TradePilotRuntimeMode.live,
        gatewayBaseUri: Uri.parse('https://gateway.example.test'),
      ),
    );

    expect(composition.ownedGatewayClient, isNotNull);
    composition.ownedGatewayClient!.close();
  });
}
