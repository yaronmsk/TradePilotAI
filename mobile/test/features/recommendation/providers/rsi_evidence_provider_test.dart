import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/providers/rsi_evidence_provider.dart';

void main() {
  const provider = RsiEvidenceProvider();

  MarketSnapshot createSnapshot({required List<double> closes}) {
    final candles = List<MarketCandle>.generate(closes.length, (index) {
      final close = closes[index];

      return MarketCandle(
        timestamp: DateTime(2026, 8, 14, 10).add(Duration(minutes: index * 5)),
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
          ? DateTime(2026, 8, 14)
          : candles.last.timestamp,
      currentPrice: candles.isEmpty ? 0 : candles.last.close,
      currentVolume: candles.isEmpty ? 0 : candles.last.volume,
      candles: candles,
    );
  }

  group('RsiEvidenceProvider', () {
    test('exposes its definition', () {
      expect(provider.name, 'RSI');
      expect(provider.definition.name, 'RSI');
    });

    test('returns insufficient data when fewer than 15 candles exist', () {
      final result = provider.evaluate(
        createSnapshot(
          closes: List<double>.generate(14, (index) => 100 + index.toDouble()),
        ),
      );

      expect(result.status, EvidenceStatus.insufficientData);
      expect(result.isAvailable, isFalse);
      expect(result.reliability, 0);
    });

    test('returns bearish evidence for strongly rising prices', () {
      final result = provider.evaluate(
        createSnapshot(
          closes: List<double>.generate(20, (index) => 100 + index.toDouble()),
        ),
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.bearish);
      expect(result.currentValue, '100.00');
      expect(result.relativeValue, 'Overbought');
    });

    test('returns bullish evidence for strongly falling prices', () {
      final result = provider.evaluate(
        createSnapshot(
          closes: List<double>.generate(20, (index) => 120 - index.toDouble()),
        ),
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.bullish);
      expect(result.currentValue, '0.00');
      expect(result.relativeValue, 'Oversold');
    });

    test('returns neutral evidence for alternating prices', () {
      final closes = List<double>.generate(
        20,
        (index) => index.isEven ? 100 : 101,
      );

      final result = provider.evaluate(createSnapshot(closes: closes));

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.neutral);
      expect(result.relativeValue, 'Neutral');
    });

    test('reliability does not exceed 90 percent', () {
      final result = provider.evaluate(
        createSnapshot(
          closes: List<double>.generate(60, (index) => 100 + (index * 0.1)),
        ),
      );

      expect(result.reliability, lessThanOrEqualTo(0.90));
    });
  });
}
