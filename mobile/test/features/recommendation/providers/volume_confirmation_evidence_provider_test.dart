import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/providers/volume_confirmation_evidence_provider.dart';

void main() {
  const provider = VolumeConfirmationEvidenceProvider();

  MarketSnapshot createSnapshot({
    required bool risingPrice,
    required bool risingVolume,
  }) {
    final candles = List<MarketCandle>.generate(20, (index) {
      final close = risingPrice ? 100 + (index * 0.25) : 105 - (index * 0.25);
      final volume = index < 10
          ? 1000000.0
          : risingVolume
          ? 1500000.0
          : 700000.0;
      return MarketCandle(
        timestamp: DateTime(2026, 8, 18, 10).add(Duration(minutes: index * 5)),
        open: close - (risingPrice ? 0.1 : -0.1),
        high: close + 0.3,
        low: close - 0.3,
        close: close,
        volume: volume,
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

  test('confirms a rising price move with expanding volume', () {
    final result = provider.evaluate(
      createSnapshot(risingPrice: true, risingVolume: true),
    );

    expect(result.direction, EvidenceDirection.bullish);
    expect(result.definition.family, EvidenceFamily.participation);
  });

  test('confirms a falling price move with expanding volume', () {
    final result = provider.evaluate(
      createSnapshot(risingPrice: false, risingVolume: true),
    );

    expect(result.direction, EvidenceDirection.bearish);
  });

  test('flags fading volume as divergence against a rising move', () {
    final result = provider.evaluate(
      createSnapshot(risingPrice: true, risingVolume: false),
    );

    expect(result.direction, EvidenceDirection.bearish);
    expect(result.explanation, contains('divergence'));
  });
}
