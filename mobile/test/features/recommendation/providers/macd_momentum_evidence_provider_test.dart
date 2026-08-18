import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/providers/macd_momentum_evidence_provider.dart';

void main() {
  const provider = MacdMomentumEvidenceProvider();

  MarketSnapshot snapshotFromCloses(List<double> closes) {
    final candles = List<MarketCandle>.generate(closes.length, (index) {
      final close = closes[index];
      return MarketCandle(
        timestamp: DateTime(2026, 8, 18, 10).add(Duration(minutes: index * 5)),
        open: close - 0.1,
        high: close + 0.5,
        low: close - 0.5,
        close: close,
        volume: 1000000,
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

  test(
    'returns bullish momentum when recent price acceleration is positive',
    () {
      final closes = List<double>.generate(48, (index) {
        final acceleration = index < 28
            ? index * 0.05
            : 1.4 + ((index - 28) * 0.55);
        return 100 + acceleration;
      });

      final result = provider.evaluate(snapshotFromCloses(closes));

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.bullish);
      expect(result.definition.family, EvidenceFamily.momentum);
      expect(result.relativeValue, contains('Histogram'));
    },
  );

  test(
    'returns bearish momentum when recent price acceleration is negative',
    () {
      final closes = List<double>.generate(48, (index) {
        final acceleration = index < 28
            ? index * -0.05
            : -1.4 - ((index - 28) * 0.55);
        return 120 + acceleration;
      });

      final result = provider.evaluate(snapshotFromCloses(closes));

      expect(result.direction, EvidenceDirection.bearish);
    },
  );

  test('returns insufficient data with fewer than required candles', () {
    final result = provider.evaluate(snapshotFromCloses(List.filled(20, 100)));

    expect(result.status, EvidenceStatus.insufficientData);
  });
}
