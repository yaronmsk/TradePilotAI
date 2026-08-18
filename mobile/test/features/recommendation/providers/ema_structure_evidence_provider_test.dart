import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/providers/ema_structure_evidence_provider.dart';

void main() {
  const provider = EmaStructureEvidenceProvider();

  MarketSnapshot snapshotFromCloses(List<double> closes) {
    final candles = List<MarketCandle>.generate(closes.length, (index) {
      final close = closes[index];
      return MarketCandle(
        timestamp: DateTime(2026, 8, 18, 10).add(Duration(minutes: index * 5)),
        open: close - 0.2,
        high: close + 0.4,
        low: close - 0.4,
        close: close,
        volume: 1000000 + (index * 10000),
      );
    });

    return MarketSnapshot(
      symbol: 'TEST',
      timeframe: '5m',
      timestamp: candles.last.timestamp,
      currentPrice: candles.last.close,
      currentVolume: candles.last.volume,
      candles: candles,
    );
  }

  test('returns bullish evidence for clean rising EMA structure', () {
    final closes = List<double>.generate(48, (index) => 100 + (index * 0.35));
    final result = provider.evaluate(snapshotFromCloses(closes));

    expect(result.status, EvidenceStatus.available);
    expect(result.direction, EvidenceDirection.bullish);
    expect(result.definition.family, EvidenceFamily.trend);
    expect(result.currentValue, contains('Price'));
  });

  test('returns bearish evidence for clean falling EMA structure', () {
    final closes = List<double>.generate(48, (index) => 120 - (index * 0.35));
    final result = provider.evaluate(snapshotFromCloses(closes));

    expect(result.direction, EvidenceDirection.bearish);
  });

  test('returns insufficient data when slow EMA cannot be established', () {
    final result = provider.evaluate(snapshotFromCloses(List.filled(10, 100)));

    expect(result.status, EvidenceStatus.insufficientData);
    expect(result.isAvailable, isFalse);
  });
}
