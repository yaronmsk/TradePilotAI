import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/controllers/market_controller.dart';
import 'package:mobile/features/market/models/market_state.dart';
import 'package:mobile/features/market/providers/mock_market_data_provider.dart';
import 'package:mobile/features/market/services/market_service.dart';

void main() {
  late MarketController controller;

  setUp(() {
    controller = MarketController(
      const MarketService(
        MockMarketDataProvider(),
      ),
    );
  });

  test('starts with initial state', () {
    expect(controller.state.status, MarketStatus.initial);
    expect(controller.state.snapshot, isNull);
    expect(controller.state.errorMessage, isNull);
  });

  test('loads a market snapshot successfully', () async {
    await controller.loadSnapshot(
      symbol: 'TSLA',
      timeframe: '5m',
      candleCount: 48,
    );

    expect(controller.state.status, MarketStatus.loaded);
    expect(controller.state.snapshot, isNotNull);
    expect(controller.state.snapshot!.symbol, 'TSLA');
    expect(controller.state.snapshot!.candleCount, 48);
    expect(controller.state.errorMessage, isNull);
  });

  test('stores an error when loading fails', () async {
    await controller.loadSnapshot(
      symbol: 'TSLA',
      timeframe: '30m',
      candleCount: 48,
    );

    expect(controller.state.status, MarketStatus.error);
    expect(controller.state.snapshot, isNull);
    expect(controller.state.errorMessage, isNotNull);
  });

  test('reset returns controller to initial state', () async {
    await controller.loadSnapshot(
      symbol: 'TSLA',
      timeframe: '5m',
      candleCount: 48,
    );

    controller.reset();

    expect(controller.state.status, MarketStatus.initial);
    expect(controller.state.snapshot, isNull);
    expect(controller.state.errorMessage, isNull);
  });
}