import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/watchlist/models/watchlist_item.dart';

void main() {
  group('WatchlistItem', () {
    const item = WatchlistItem(symbol: 'AAPL', displayName: 'Apple Inc.');

    test('creates an item with expected values', () {
      expect(item.symbol, 'AAPL');
      expect(item.displayName, 'Apple Inc.');
      expect(item.isNotificationsEnabled, isFalse);
    });

    test('copyWith returns an updated copy', () {
      final updated = item.copyWith(isNotificationsEnabled: true);

      expect(updated.symbol, 'AAPL');
      expect(updated.displayName, 'Apple Inc.');
      expect(updated.isNotificationsEnabled, isTrue);
      expect(item.isNotificationsEnabled, isFalse);
    });

    test('converts to and from JSON', () {
      final json = item.toJson();
      final restored = WatchlistItem.fromJson(json);

      expect(restored, item);
    });
  });
}
