import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/controllers/market_history_controller.dart';
import 'package:mobile/features/market/models/market_history_range.dart';
import 'package:mobile/features/market/models/market_history_state.dart';
import 'package:mobile/features/market/providers/mock_market_history_provider.dart';
import 'package:mobile/features/market/services/market_history_service.dart';

void main() {
  late MarketHistoryController controller;

  setUp(() {
    controller = MarketHistoryController(
      const MarketHistoryService(MockMarketHistoryProvider()),
    );
  });

  tearDown(() {
    controller.dispose();
  });

  test('starts with one-day range', () {
    expect(controller.state.range, MarketHistoryRange.oneDay);

    expect(controller.state.status, MarketHistoryStatus.initial);
  });

  test('loads history for a symbol', () async {
    await controller.load(symbol: 'AAPL', endPrice: 150);

    expect(controller.state.status, MarketHistoryStatus.loaded);

    expect(controller.state.candles, isNotEmpty);

    expect(controller.state.candles.last.close, 150);
  });

  test('changes history range independently', () async {
    await controller.load(symbol: 'AAPL', endPrice: 150);

    await controller.selectRange(MarketHistoryRange.oneYear);

    expect(controller.state.range, MarketHistoryRange.oneYear);

    expect(
      controller.state.candles.length,
      MarketHistoryRange.oneYear.pointCount,
    );
  });

  test('reset restores initial state', () async {
    await controller.load(symbol: 'AAPL', endPrice: 150);

    controller.reset();

    expect(controller.state.status, MarketHistoryStatus.initial);

    expect(controller.state.candles, isEmpty);
  });
}
