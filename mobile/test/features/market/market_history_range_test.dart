import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_history_range.dart';

void main() {
  test('defines all supported market history ranges', () {
    expect(
      MarketHistoryRange.values,
      [
        MarketHistoryRange.oneDay,
        MarketHistoryRange.fiveDays,
        MarketHistoryRange.oneMonth,
        MarketHistoryRange.threeMonths,
        MarketHistoryRange.oneYear,
      ],
    );
  });
}