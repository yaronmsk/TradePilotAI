import '../../../core/network/tradepilot_gateway_client.dart';
import '../models/market_candle.dart';
import '../models/market_history_range.dart';
import 'gateway_market_parsing.dart';
import 'market_history_provider.dart';

class GatewayMarketHistoryProvider implements MarketHistoryProvider {
  final TradePilotGatewayClient gatewayClient;

  const GatewayMarketHistoryProvider(this.gatewayClient);

  @override
  Future<List<MarketCandle>> fetchHistory({
    required String symbol,
    required MarketHistoryRange range,
    required double endPrice,
  }) async {
    final payload = await gatewayClient.getJson(
      '/v1/market/history',
      queryParameters: {
        'symbol': symbol.trim().toUpperCase(),
        'range': range.label,
      },
    );

    final provenance = parseGatewayProvenance(payload);
    requireUsableLiveProvenance(provenance);

    return parseGatewayCandles(payload['candles'], provenance: provenance);
  }
}
