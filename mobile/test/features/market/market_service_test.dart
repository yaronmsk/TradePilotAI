import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/providers/mock_market_data_provider.dart';
import 'package:mobile/features/market/services/market_service.dart';

void main() {
  const service = MarketService(MockMarketDataProvider());

  test('MarketService loads a market snapshot', () async {
    final snapshot = await service.loadSnapshot(
      symbol: 'MSFT',
      timeframe: '5m',
      candleCount: 48,
    );

    expect(snapshot.symbol, 'MSFT');
    expect(snapshot.candleCount, 48);
    expect(snapshot.hasCandles, isTrue);
  });
}