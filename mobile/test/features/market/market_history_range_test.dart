import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_history_range.dart';

void main() {
  group('MarketHistoryRange', () {
    test('defines all supported ranges', () {
      expect(MarketHistoryRange.values, [
        MarketHistoryRange.oneDay,
        MarketHistoryRange.fiveDays,
        MarketHistoryRange.oneMonth,
        MarketHistoryRange.threeMonths,
        MarketHistoryRange.oneYear,
      ]);
    });

    test('provides user-facing labels', () {
      expect(MarketHistoryRange.oneDay.label, '1D');

      expect(MarketHistoryRange.fiveDays.label, '5D');

      expect(MarketHistoryRange.oneMonth.label, '1M');

      expect(MarketHistoryRange.threeMonths.label, '3M');

      expect(MarketHistoryRange.oneYear.label, '1Y');
    });
  });
}
