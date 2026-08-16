import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/providers/relative_volume_evidence_provider.dart';

void main() {
  const provider = RelativeVolumeEvidenceProvider();

  MarketSnapshot createSnapshot({
    required double currentVolume,
    required bool bullishLatest,
    int candleCount = 21,
  }) {
    final candles = List<MarketCandle>.generate(candleCount, (index) {
      final isLast = index == candleCount - 1;
      final open = 100.0;
      final close = isLast ? (bullishLatest ? 101.0 : 99.0) : 100.2;

      return MarketCandle(
        timestamp: DateTime(2026, 8, 16, 10).add(Duration(minutes: index * 5)),
        open: open,
        high: 102,
        low: 98,
        close: close,
        volume: isLast ? currentVolume : 1000000,
      );
    }, growable: false);

    return MarketSnapshot(
      symbol: 'TEST',
      timeframe: '5m',
      timestamp: candles.last.timestamp,
      currentPrice: candles.last.close,
      currentVolume: currentVolume,
      candles: candles,
    );
  }

  test('returns bullish evidence for exceptional volume on an up candle', () {
    final result = provider.evaluate(
      createSnapshot(currentVolume: 2200000, bullishLatest: true),
    );

    expect(result.status, EvidenceStatus.available);
    expect(result.direction, EvidenceDirection.bullish);
    expect(result.strength, EvidenceStrength.exceptional);
    expect(result.currentValue, '2.20x');
  });

  test('returns bearish evidence for exceptional volume on a down candle', () {
    final result = provider.evaluate(
      createSnapshot(currentVolume: 2200000, bullishLatest: false),
    );

    expect(result.direction, EvidenceDirection.bearish);
  });

  test('returns neutral evidence when volume is near average', () {
    final result = provider.evaluate(
      createSnapshot(currentVolume: 1000000, bullishLatest: true),
    );

    expect(result.direction, EvidenceDirection.neutral);
    expect(result.relativeValue, '0% above average');
  });

  test('returns insufficient data with fewer than three candles', () {
    final result = provider.evaluate(
      createSnapshot(
        currentVolume: 1000000,
        bullishLatest: true,
        candleCount: 2,
      ),
    );

    expect(result.status, EvidenceStatus.insufficientData);
    expect(result.isAvailable, isFalse);
  });
}
