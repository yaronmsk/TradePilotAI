import '../../../core/network/tradepilot_gateway_client.dart';
import '../models/market_snapshot.dart';
import 'gateway_market_parsing.dart';
import 'market_data_provider.dart';

class GatewayMarketDataProvider implements MarketDataProvider {
  final TradePilotGatewayClient gatewayClient;

  const GatewayMarketDataProvider(this.gatewayClient);

  @override
  Future<MarketSnapshot> fetchSnapshot({
    required String symbol,
    required String timeframe,
    required int candleCount,
  }) async {
    final payload = await gatewayClient.getJson(
      '/v1/market/snapshot',
      queryParameters: {
        'symbol': symbol.trim().toUpperCase(),
        'timeframe': timeframe,
        'candleCount': '$candleCount',
      },
    );

    final provenance = parseGatewayProvenance(payload);
    requireUsableLiveProvenance(provenance);

    final snapshot = payload['snapshot'];
    if (snapshot is! Map<String, dynamic>) {
      throw const FormatException('Gateway response requires snapshot.');
    }

    final candles = parseGatewayCandles(
      snapshot['candles'],
      provenance: provenance,
    );

    return MarketSnapshot(
      symbol: requiredString(snapshot['symbol'], 'snapshot.symbol'),
      timeframe: requiredString(snapshot['timeframe'], 'snapshot.timeframe'),
      timestamp: requiredDateTime(snapshot['timestamp'], 'snapshot.timestamp'),
      currentPrice: requiredNumber(
        snapshot['currentPrice'],
        'snapshot.currentPrice',
      ),
      currentVolume: requiredNumber(
        snapshot['currentVolume'],
        'snapshot.currentVolume',
      ),
      candles: candles,
      provenance: provenance,
    );
  }
}
