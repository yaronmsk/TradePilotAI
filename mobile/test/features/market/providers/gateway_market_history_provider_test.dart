import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/tradepilot_gateway_client.dart';
import 'package:mobile/features/market/models/market_history_range.dart';
import 'package:mobile/features/market/providers/gateway_market_history_provider.dart';

class _FakeGatewayClient implements TradePilotGatewayClient {
  _FakeGatewayClient(this.payload);

  final Map<String, dynamic> payload;
  String? path;
  Map<String, String>? query;

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String> queryParameters = const {},
  }) async {
    this.path = path;
    query = queryParameters;
    return payload;
  }
}

void main() {
  test('maps normalized history and preserves live provenance', () async {
    final gateway = _FakeGatewayClient({
      'provenance': {
        'state': 'PARTIAL_LIVE',
        'source': 'Twelve Data via TradePilot Gateway',
        'observedAt': '2026-09-04T20:00:00Z',
        'fetchedAt': '2026-09-05T15:40:00Z',
      },
      'candles': [
        {
          'timestamp': '2026-09-04T19:55:00Z',
          'open': 319.0,
          'high': 320.0,
          'low': 318.8,
          'close': 319.8,
          'volume': 100000,
        },
        {
          'timestamp': '2026-09-04T19:50:00Z',
          'open': 318.5,
          'high': 319.2,
          'low': 318.2,
          'close': 319.0,
          'volume': 90000,
        },
      ],
    });

    final provider = GatewayMarketHistoryProvider(gateway);
    final candles = await provider.fetchHistory(
      symbol: 'aapl',
      range: MarketHistoryRange.oneDay,
      endPrice: 319.97,
    );

    expect(gateway.path, '/v1/market/history');
    expect(gateway.query, {'symbol': 'AAPL', 'range': '1D'});
    expect(candles, hasLength(2));
    expect(candles.first.timestamp.isBefore(candles.last.timestamp), isTrue);
    expect(candles.every((candle) => candle.provenance.isLiveUsable), isTrue);
  });
}
