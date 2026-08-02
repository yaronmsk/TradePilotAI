import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/watchlist/models/watchlist_item.dart';
import 'package:mobile/features/watchlist/widgets/add_stock_dialog.dart';

void main() {
  Widget createTestApp({required Widget child}) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('AddStockDialog', () {
    testWidgets('shows only the stock symbol field', (tester) async {
      await tester.pumpWidget(createTestApp(child: const AddStockDialog()));

      expect(find.text('Add stock'), findsOneWidget);
      expect(find.text('Stock symbol'), findsOneWidget);
      expect(find.text('Company name'), findsNothing);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('shows validation error for an empty symbol', (tester) async {
      await tester.pumpWidget(createTestApp(child: const AddStockDialog()));

      await tester.tap(find.text('Add'));
      await tester.pump();

      expect(find.text('Enter a stock symbol.'), findsOneWidget);
    });

    testWidgets('rejects an invalid stock symbol', (tester) async {
      await tester.pumpWidget(createTestApp(child: const AddStockDialog()));

      await tester.enterText(find.byType(TextFormField), 'INVALID SYMBOL');

      await tester.tap(find.text('Add'));
      await tester.pump();

      expect(find.text('Enter a valid stock symbol.'), findsOneWidget);
    });

    testWidgets('returns a normalized watchlist item', (tester) async {
      WatchlistItem? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    result = await AddStockDialog.show(context);
                  },
                  child: const Text('Open dialog'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), ' amd ');

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(result, const WatchlistItem(symbol: 'AMD', displayName: 'AMD'));
    });

    testWidgets('returns null when cancelled', (tester) async {
      WatchlistItem? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    result = await AddStockDialog.show(context);
                  },
                  child: const Text('Open dialog'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });
}
