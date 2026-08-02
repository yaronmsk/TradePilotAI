import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/watchlist/controllers/watchlist_controller.dart';
import 'package:mobile/features/watchlist/models/watchlist_item.dart';
import 'package:mobile/features/watchlist/widgets/watchlist_card.dart';

void main() {
  const apple = WatchlistItem(symbol: 'AAPL', displayName: 'Apple Inc.');

  const microsoft = WatchlistItem(
    symbol: 'MSFT',
    displayName: 'Microsoft Corporation',
  );

  Widget createTestApp({
    required WatchlistController controller,
    ValueChanged<String>? onSymbolSelected,
    VoidCallback? onAddPressed,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: WatchlistCard(
          controller: controller,
          onSymbolSelected: onSymbolSelected ?? (_) {},
          onAddPressed: onAddPressed ?? () {},
        ),
      ),
    );
  }

  group('WatchlistCard', () {
    testWidgets('shows an empty state', (tester) async {
      final controller = WatchlistController();

      await tester.pumpWidget(createTestApp(controller: controller));

      expect(find.text('Watchlist'), findsOneWidget);
      expect(find.text('Your watchlist is empty'), findsOneWidget);
      expect(find.text('Add stock'), findsOneWidget);
    });

    testWidgets('shows watchlist items', (tester) async {
      final controller = WatchlistController(
        initialItems: const [apple, microsoft],
      );

      await tester.pumpWidget(createTestApp(controller: controller));

      expect(find.text('AAPL'), findsOneWidget);
      expect(find.text('Apple Inc.'), findsOneWidget);
      expect(find.text('MSFT'), findsOneWidget);
      expect(find.text('Microsoft Corporation'), findsOneWidget);
    });

    testWidgets('selects a symbol and calls callback', (tester) async {
      final controller = WatchlistController(
        initialItems: const [apple, microsoft],
      );

      String? selectedSymbol;

      await tester.pumpWidget(
        createTestApp(
          controller: controller,
          onSymbolSelected: (symbol) {
            selectedSymbol = symbol;
          },
        ),
      );

      await tester.tap(find.text('MSFT'));
      await tester.pump();

      expect(controller.state.selectedSymbol, 'MSFT');
      expect(selectedSymbol, 'MSFT');
    });

    testWidgets('toggles notifications', (tester) async {
      final controller = WatchlistController(initialItems: const [apple]);

      await tester.pumpWidget(createTestApp(controller: controller));

      expect(controller.state.items.single.isNotificationsEnabled, isFalse);

      await tester.tap(find.byTooltip('Enable notifications'));
      await tester.pump();

      expect(controller.state.items.single.isNotificationsEnabled, isTrue);

      expect(find.byTooltip('Disable notifications'), findsOneWidget);
    });

    testWidgets('removes a stock', (tester) async {
      final controller = WatchlistController(initialItems: const [apple]);

      await tester.pumpWidget(createTestApp(controller: controller));

      await tester.tap(find.byTooltip('Remove AAPL'));
      await tester.pump();

      expect(controller.state.items, isEmpty);
      expect(find.text('Your watchlist is empty'), findsOneWidget);
    });

    testWidgets('calls add callback', (tester) async {
      final controller = WatchlistController();
      var addPressed = false;

      await tester.pumpWidget(
        createTestApp(
          controller: controller,
          onAddPressed: () {
            addPressed = true;
          },
        ),
      );

      await tester.tap(find.text('Add stock'));

      expect(addPressed, isTrue);
    });
  });
}
