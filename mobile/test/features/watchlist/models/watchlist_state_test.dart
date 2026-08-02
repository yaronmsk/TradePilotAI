import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/watchlist/models/watchlist_item.dart';
import 'package:mobile/features/watchlist/models/watchlist_state.dart';

void main() {
  group('WatchlistState', () {
    const apple = WatchlistItem(symbol: 'AAPL', displayName: 'Apple Inc.');

    const microsoft = WatchlistItem(
      symbol: 'MSFT',
      displayName: 'Microsoft Corporation',
    );

    test('starts with expected default values', () {
      const state = WatchlistState();

      expect(state.status, WatchlistStatus.initial);
      expect(state.items, isEmpty);
      expect(state.selectedSymbol, isNull);
      expect(state.selectedItem, isNull);
      expect(state.errorMessage, isNull);
    });

    test('returns the selected item', () {
      const state = WatchlistState(
        status: WatchlistStatus.loaded,
        items: [apple, microsoft],
        selectedSymbol: 'MSFT',
      );

      expect(state.selectedItem, microsoft);
    });

    test('returns null when selected symbol is not present', () {
      const state = WatchlistState(items: [apple], selectedSymbol: 'NVDA');

      expect(state.selectedItem, isNull);
    });

    test('checks symbols without case or whitespace sensitivity', () {
      const state = WatchlistState(items: [apple, microsoft]);

      expect(state.containsSymbol('aapl'), isTrue);
      expect(state.containsSymbol(' MSFT '), isTrue);
      expect(state.containsSymbol('NVDA'), isFalse);
    });

    test('copyWith updates values without changing original state', () {
      const original = WatchlistState(items: [apple], selectedSymbol: 'AAPL');

      final updated = original.copyWith(
        status: WatchlistStatus.loaded,
        items: const [apple, microsoft],
        selectedSymbol: 'MSFT',
      );

      expect(original.items.length, 1);
      expect(original.selectedSymbol, 'AAPL');

      expect(updated.status, WatchlistStatus.loaded);
      expect(updated.items.length, 2);
      expect(updated.selectedSymbol, 'MSFT');
    });

    test('copyWith can clear selected symbol and error message', () {
      const original = WatchlistState(
        selectedSymbol: 'AAPL',
        errorMessage: 'Storage failed',
      );

      final updated = original.copyWith(
        clearSelectedSymbol: true,
        clearErrorMessage: true,
      );

      expect(updated.selectedSymbol, isNull);
      expect(updated.errorMessage, isNull);
    });
  });
}
