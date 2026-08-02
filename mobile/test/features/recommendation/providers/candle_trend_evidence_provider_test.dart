import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/providers/candle_trend_evidence_provider.dart';

void main() {
  const provider = CandleTrendEvidenceProvider();

  MarketSnapshot createSnapshot({required List<double> closes}) {
    final candles = List<MarketCandle>.generate(closes.length, (index) {
      final close = closes[index];

      return MarketCandle(
        timestamp: DateTime(2026, 8, 2, 10, index * 5),
        open: close,
        high: close,
        low: close,
        close: close,
        volume: 1000000,
      );
    }, growable: false);

    return MarketSnapshot(
      symbol: 'TEST',
      timeframe: '5m',
      timestamp: candles.isEmpty
          ? DateTime(2026, 8, 2)
          : candles.last.timestamp,
      currentPrice: candles.isEmpty ? 0 : candles.last.close,
      currentVolume: candles.isEmpty ? 0 : candles.last.volume,
      candles: candles,
    );
  }

  group('CandleTrendEvidenceProvider', () {
    test('exposes the shared provider name', () {
      expect(provider.name, 'Candle Trend');
    });

    test('returns insufficient data when fewer than two candles exist', () {
      final result = provider.evaluate(createSnapshot(closes: const [100]));

      expect(result.status, EvidenceStatus.insufficientData);
      expect(result.direction, EvidenceDirection.unknown);
      expect(result.isAvailable, isFalse);
      expect(result.reliability, 0);
    });

    test('returns exceptional bullish evidence for rise of at least 5%', () {
      final result = provider.evaluate(
        createSnapshot(closes: const [100, 106]),
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.bullish);
      expect(result.strength, EvidenceStrength.exceptional);
      expect(result.score, 95);
      expect(result.currentValue, '6.00%');
    });

    test('returns strong bullish evidence for rise between 2% and 5%', () {
      final result = provider.evaluate(
        createSnapshot(closes: const [100, 103]),
      );

      expect(result.direction, EvidenceDirection.bullish);
      expect(result.strength, EvidenceStrength.strong);
      expect(result.score, 80);
    });

    test('returns exceptional bearish evidence for fall of at least 5%', () {
      final result = provider.evaluate(createSnapshot(closes: const [100, 94]));

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.bearish);
      expect(result.strength, EvidenceStrength.exceptional);
      expect(result.score, 95);
      expect(result.currentValue, '-6.00%');
    });

    test('returns strong bearish evidence for fall between 2% and 5%', () {
      final result = provider.evaluate(createSnapshot(closes: const [100, 97]));

      expect(result.direction, EvidenceDirection.bearish);
      expect(result.strength, EvidenceStrength.strong);
      expect(result.score, 80);
    });

    test('returns neutral evidence for a small price change', () {
      final result = provider.evaluate(
        createSnapshot(closes: const [100, 101]),
      );

      expect(result.direction, EvidenceDirection.neutral);
      expect(result.strength, EvidenceStrength.moderate);
      expect(result.score, 50);
    });

    test('returns error when first closing price is invalid', () {
      final result = provider.evaluate(createSnapshot(closes: const [0, 100]));

      expect(result.status, EvidenceStatus.error);
      expect(result.direction, EvidenceDirection.unknown);
      expect(result.isAvailable, isFalse);
    });
  });
}
