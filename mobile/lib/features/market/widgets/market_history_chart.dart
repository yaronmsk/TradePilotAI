import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/market_candle.dart';

class MarketHistoryChart extends StatelessWidget {
  const MarketHistoryChart({
    required this.candles,
    this.height = 190,
    super.key,
  });

  final List<MarketCandle> candles;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (candles.length < 2) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Price history is not available yet.')),
      );
    }

    final closes = candles
        .map((candle) => candle.close)
        .toList(growable: false);

    final minPrice = closes.reduce(math.min);
    final maxPrice = closes.reduce(math.max);

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            top: 22,
            bottom: 22,
            child: CustomPaint(
              painter: _MarketHistoryPainter(
                candles: candles,
                lineColor: Theme.of(context).colorScheme.primary,
                gridColor: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Text(
              '\$${maxPrice.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Text(
              '\$${minPrice.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketHistoryPainter extends CustomPainter {
  _MarketHistoryPainter({
    required this.candles,
    required this.lineColor,
    required this.gridColor,
  });

  final List<MarketCandle> candles;
  final Color lineColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.length < 2 || size.width <= 0 || size.height <= 0) {
      return;
    }

    final closes = candles
        .map((candle) => candle.close)
        .toList(growable: false);

    final minPrice = closes.reduce(math.min);
    final maxPrice = closes.reduce(math.max);

    final priceRange = math.max(maxPrice - minPrice, 0.000001);

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.7;

    for (var index = 1; index < 4; index++) {
      final y = size.height * (index / 4);

      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    for (var index = 0; index < candles.length; index++) {
      final x = candles.length == 1
          ? 0.0
          : size.width * (index / (candles.length - 1));

      final normalized = (candles[index].close - minPrice) / priceRange;

      final y = size.height - (normalized * size.height);

      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _MarketHistoryPainter oldDelegate) {
    return oldDelegate.candles != candles ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}
