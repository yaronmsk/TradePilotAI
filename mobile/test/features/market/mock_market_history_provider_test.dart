import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_history_range.dart';
import 'package:mobile/features/market/providers/mock_market_history_provider.dart';
import 'package:mobile/features/recommendation/context/historical_stock_profile_service.dart';

void main() {
  const provider = MockMarketHistoryProvider();

  group('MockMarketHistoryProvider', () {
    test('returns requested number of one-day points', () async {
      final candles = await provider.fetchHistory(
        symbol: 'AAPL',
        range: MarketHistoryRange.oneDay,
        endPrice: 150,
      );

      expect(candles.length, MarketHistoryRange.oneDay.pointCount);

      expect(candles.last.close, 150);
    });

    test('returns requested number of one-year points', () async {
      final candles = await provider.fetchHistory(
        symbol: 'NVDA',
        range: MarketHistoryRange.oneYear,
        endPrice: 120,
      );

      expect(candles.length, MarketHistoryRange.oneYear.pointCount);

      expect(candles.last.close, 120);
    });

    test('timestamps are chronological', () async {
      final candles = await provider.fetchHistory(
        symbol: 'MSFT',
        range: MarketHistoryRange.oneMonth,
        endPrice: 100,
      );

      for (var index = 1; index < candles.length; index++) {
        expect(
          candles[index].timestamp.isAfter(candles[index - 1].timestamp),
          isTrue,
        );
      }
    });

    test('rejects invalid end price', () async {
      expect(
        () => provider.fetchHistory(
          symbol: 'AAPL',
          range: MarketHistoryRange.oneDay,
          endPrice: 0,
        ),
        throwsArgumentError,
      );
    });

    test(
      'creates distinct long-term behavior for steady and volatile symbols',
      () async {
        final aaplHistory = await provider.fetchHistory(
          symbol: 'AAPL',
          range: MarketHistoryRange.oneYear,
          endPrice: 150,
        );
        final tslaHistory = await provider.fetchHistory(
          symbol: 'TSLA',
          range: MarketHistoryRange.oneYear,
          endPrice: 150,
        );

        const profileService = HistoricalStockProfileService();
        final aaplProfile = profileService.evaluate(aaplHistory);
        final tslaProfile = profileService.evaluate(tslaHistory);

        expect(
          aaplProfile.typicalRealizedVolatilityPercent,
          lessThan(tslaProfile.typicalRealizedVolatilityPercent),
        );
        expect(
          aaplProfile.volumeVariability,
          lessThan(tslaProfile.volumeVariability),
        );
      },
    );
  });
}
