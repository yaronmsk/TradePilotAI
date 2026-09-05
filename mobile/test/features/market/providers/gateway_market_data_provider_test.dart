import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/tradepilot_gateway_client.dart';
import 'package:mobile/features/market/providers/gateway_market_data_provider.dart';

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

Map<String, dynamic> _payload({String state = 'LIVE'}) => {
  'provenance': {
    'state': state,
    'source': 'Twelve Data via TradePilot Gateway',
    'observedAt': '2026-09-04T20:00:00Z',
    'fetchedAt': '2026-09-05T15:40:00Z',
  },
  'snapshot': {
    'symbol': 'AAPL',
    'timeframe': '5m',
    'timestamp': '2026-09-04T20:00:00Z',
    'currentPrice': 319.97,
    'currentVolume': 1200000,
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
  },
};

void main() {
  test('maps normalized gateway snapshot into existing market model', () async {
    final gateway = _FakeGatewayClient(_payload());
    final provider = GatewayMarketDataProvider(gateway);

    final snapshot = await provider.fetchSnapshot(
      symbol: 'aapl',
      timeframe: '5m',
      candleCount: 120,
    );

    expect(gateway.path, '/v1/market/snapshot');
    expect(gateway.query, {
      'symbol': 'AAPL',
      'timeframe': '5m',
      'candleCount': '120',
    });
    expect(snapshot.symbol, 'AAPL');
    expect(snapshot.currentPrice, 319.97);
    expect(snapshot.candles, hasLength(2));
    expect(
      snapshot.candles.first.timestamp.isBefore(
        snapshot.candles.last.timestamp,
      ),
      isTrue,
    );
    expect(snapshot.provenance.isLiveUsable, isTrue);
    expect(
      snapshot.candles.every((candle) => candle.provenance.isLiveUsable),
      isTrue,
    );
  });

  test('rejects synthetic data from the live provider', () async {
    final provider = GatewayMarketDataProvider(
      _FakeGatewayClient(_payload(state: 'SYNTHETIC')),
    );

    await expectLater(
      provider.fetchSnapshot(symbol: 'AAPL', timeframe: '5m', candleCount: 120),
      throwsStateError,
    );
  });

  test('rejects stale data from the live provider', () async {
    final provider = GatewayMarketDataProvider(
      _FakeGatewayClient(_payload(state: 'STALE')),
    );

    await expectLater(
      provider.fetchSnapshot(symbol: 'AAPL', timeframe: '5m', candleCount: 120),
      throwsStateError,
    );
  });
}
