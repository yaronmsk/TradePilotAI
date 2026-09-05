import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/core/network/tradepilot_gateway_client.dart';

void main() {
  test('builds gateway URL without exposing provider credentials', () async {
    late Uri requestedUri;
    final client = HttpTradePilotGatewayClient(
      baseUri: Uri.parse('https://gateway.example.test/api'),
      httpClient: MockClient((request) async {
        requestedUri = request.url;
        return http.Response(
          '{"ok":true}',
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final result = await client.getJson(
      '/v1/market/snapshot',
      queryParameters: const {'symbol': 'AAPL', 'timeframe': '5m'},
    );

    expect(result['ok'], isTrue);
    expect(
      requestedUri.toString(),
      'https://gateway.example.test/api/v1/market/snapshot'
      '?symbol=AAPL&timeframe=5m',
    );
    expect(requestedUri.query, isNot(contains('apikey')));
  });

  test('preserves retry-after for gateway rate limits', () async {
    final client = HttpTradePilotGatewayClient(
      baseUri: Uri.parse('https://gateway.example.test'),
      httpClient: MockClient(
        (_) async => http.Response(
          '{"message":"Rate limit reached."}',
          429,
          headers: {'retry-after': '45'},
        ),
      ),
    );

    await expectLater(
      client.getJson('/v1/market/snapshot'),
      throwsA(
        isA<TradePilotGatewayException>()
            .having((error) => error.statusCode, 'statusCode', 429)
            .having(
              (error) => error.retryAfter,
              'retryAfter',
              const Duration(seconds: 45),
            ),
      ),
    );
  });

  test('rejects non-object JSON responses', () async {
    final client = HttpTradePilotGatewayClient(
      baseUri: Uri.parse('https://gateway.example.test'),
      httpClient: MockClient((_) async => http.Response('[]', 200)),
    );

    await expectLater(
      client.getJson('/v1/market/snapshot'),
      throwsA(isA<TradePilotGatewayException>()),
    );
  });
}
