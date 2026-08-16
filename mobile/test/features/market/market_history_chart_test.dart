import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/widgets/market_history_chart.dart';

void main() {
  testWidgets('renders chart when history exists', (tester) async {
    final candles = [
      MarketCandle(
        timestamp: DateTime(2026, 8, 16, 10),
        open: 100,
        high: 102,
        low: 99,
        close: 101,
        volume: 1000000,
      ),
      MarketCandle(
        timestamp: DateTime(2026, 8, 16, 10, 5),
        open: 101,
        high: 104,
        low: 100,
        close: 103,
        volume: 1100000,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MarketHistoryChart(candles: candles)),
      ),
    );

    expect(find.byType(CustomPaint), findsWidgets);

    expect(find.text('Price history is not available yet.'), findsNothing);
  });

  testWidgets('shows placeholder when history is empty', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MarketHistoryChart(candles: [])),
      ),
    );

    expect(find.text('Price history is not available yet.'), findsOneWidget);
  });
}
