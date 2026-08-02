import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/watchlist/controllers/watchlist_controller.dart';
import 'package:mobile/features/watchlist/models/watchlist_item.dart';
import 'package:mobile/features/watchlist/models/watchlist_state.dart';

void main() {
  group('WatchlistController', () {
    const apple = WatchlistItem(symbol: 'AAPL', displayName: 'Apple Inc.');

    const microsoft = WatchlistItem(
      symbol: 'MSFT',
      displayName: 'Microsoft Corporation',
    );

    test('starts loaded with initial items and first symbol selected', () {
      final controller = WatchlistController(
        initialItems: const [apple, microsoft],
      );

      expect(controller.state.status, WatchlistStatus.loaded);
      expect(controller.state.items, const [apple, microsoft]);
      expect(controller.state.selectedSymbol, 'AAPL');
    });

    test('adds and automatically selects the first item', () {
      final controller = WatchlistController();

      controller.addItem(apple);

      expect(controller.state.items, const [apple]);
      expect(controller.state.selectedSymbol, 'AAPL');
      expect(controller.state.errorMessage, isNull);
    });

    test('normalizes symbol and display name when adding', () {
      final controller = WatchlistController();

      controller.addItem(
        const WatchlistItem(
          symbol: ' msft ',
          displayName: ' Microsoft Corporation ',
        ),
      );

      expect(controller.state.items.single.symbol, 'MSFT');
      expect(
        controller.state.items.single.displayName,
        'Microsoft Corporation',
      );
    });

    test('prevents duplicate symbols', () {
      final controller = WatchlistController(initialItems: const [apple]);

      controller.addItem(
        const WatchlistItem(symbol: 'aapl', displayName: 'Duplicate Apple'),
      );

      expect(controller.state.items.length, 1);
      expect(controller.state.status, WatchlistStatus.error);
      expect(controller.state.errorMessage, contains('already'));
    });

    test('selects an existing symbol', () {
      final controller = WatchlistController(
        initialItems: const [apple, microsoft],
      );

      controller.selectSymbol('msft');

      expect(controller.state.selectedSymbol, 'MSFT');
      expect(controller.state.selectedItem, microsoft);
    });

    test('does not select a symbol outside the watchlist', () {
      final controller = WatchlistController(initialItems: const [apple]);

      controller.selectSymbol('NVDA');

      expect(controller.state.selectedSymbol, 'AAPL');
      expect(controller.state.status, WatchlistStatus.error);
    });

    test('removes an item', () {
      final controller = WatchlistController(
        initialItems: const [apple, microsoft],
      );

      controller.removeItem('MSFT');

      expect(controller.state.items, const [apple]);
      expect(controller.state.selectedSymbol, 'AAPL');
    });

    test('selects the next available item after removing selection', () {
      final controller = WatchlistController(
        initialItems: const [apple, microsoft],
        initialSelectedSymbol: 'MSFT',
      );

      controller.removeItem('MSFT');

      expect(controller.state.items, const [apple]);
      expect(controller.state.selectedSymbol, 'AAPL');
    });

    test('clears selection after removing the final item', () {
      final controller = WatchlistController(initialItems: const [apple]);

      controller.removeItem('AAPL');

      expect(controller.state.items, isEmpty);
      expect(controller.state.selectedSymbol, isNull);
    });

    test('toggles notifications for an item', () {
      final controller = WatchlistController(initialItems: const [apple]);

      controller.toggleNotifications('AAPL');

      expect(controller.state.items.single.isNotificationsEnabled, isTrue);

      controller.toggleNotifications('AAPL');

      expect(controller.state.items.single.isNotificationsEnabled, isFalse);
    });

    test('notifies listeners after a state change', () {
      final controller = WatchlistController();
      var notificationCount = 0;

      controller.addListener(() {
        notificationCount++;
      });

      controller.addItem(apple);

      expect(notificationCount, 1);
    });
  });
}
