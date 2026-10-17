import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/data/data_provenance.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/context/stock_behavior_profile_service.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/providers/candle_trend_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/relative_volume_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/volume_confirmation_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/vwap_position_evidence_provider.dart';

void main() {
  const live = DataProvenance(
    state: DataState.live,
    source: 'Batch 3B2 test',
    observedAt: null,
    fetchedAt: null,
  );

  List<double> linearCloses({
    required double start,
    required double end,
    required int count,
  }) {
    return List<double>.generate(count, (index) {
      if (count == 1) {
        return start;
      }
      final progress = index / (count - 1);
      return start + ((end - start) * progress);
    });
  }

  MarketSnapshot trendSnapshot({
    required String timeframe,
    required List<double> closes,
    required double rangePercent,
    DataProvenance provenance = live,
  }) {
    final intervalMinutes = switch (timeframe) {
      '1m' => 1,
      '5m' => 5,
      '15m' => 15,
      '30m' => 30,
      '1h' => 60,
      _ => 5,
    };

    final candles = List<MarketCandle>.generate(closes.length, (index) {
      final close = closes[index];
      final halfRange = close * (rangePercent / 200);

      return MarketCandle(
        timestamp: DateTime(
          2026,
          10,
          2,
          10,
        ).add(Duration(minutes: intervalMinutes * index)),
        open: close,
        high: close + halfRange,
        low: close - halfRange,
        close: close,
        volume: 1000000,
      );
    }, growable: false);

    return MarketSnapshot(
      symbol: 'TEST',
      timeframe: timeframe,
      timestamp: candles.last.timestamp,
      currentPrice: candles.last.close,
      currentVolume: candles.last.volume,
      candles: candles,
      provenance: provenance,
    );
  }

  MarketSnapshot volumeSnapshot({
    String timeframe = '5m',
    double currentVolume = 2000000,
  }) {
    final candles = List<MarketCandle>.generate(21, (index) {
      final isLast = index == 20;
      final close = 100 + (index * 0.05);

      return MarketCandle(
        timestamp: DateTime(2026, 10, 2, 10).add(Duration(minutes: 5 * index)),
        open: close - 0.05,
        high: close + 0.20,
        low: close - 0.20,
        close: close,
        volume: isLast ? currentVolume : 1000000,
      );
    }, growable: false);

    return MarketSnapshot(
      symbol: 'TEST',
      timeframe: timeframe,
      timestamp: candles.last.timestamp,
      currentPrice: candles.last.close,
      currentVolume: candles.last.volume,
      candles: candles,
      provenance: live,
    );
  }

  group('LIVE Trader Candle Trend', () {
    const provider = CandleTrendEvidenceProvider();

    test(
      'same raw move changes interpretation when interval noise changes',
      () {
        final lowNoise = provider.evaluate(
          trendSnapshot(
            timeframe: '5m',
            closes: linearCloses(start: 100, end: 101, count: 48),
            rangePercent: 0.20,
          ),
        );

        final highNoise = provider.evaluate(
          trendSnapshot(
            timeframe: '5m',
            closes: linearCloses(start: 100, end: 101, count: 48),
            rangePercent: 3.00,
          ),
        );

        expect(lowNoise.direction, EvidenceDirection.bullish);
        expect(highNoise.direction, EvidenceDirection.neutral);
        expect(lowNoise.relativeValue, contains('volatility-normalized'));
        expect(highNoise.relativeValue, contains('volatility-normalized'));
      },
    );

    test('preserves bullish and bearish symmetry', () {
      final bullish = provider.evaluate(
        trendSnapshot(
          timeframe: '5m',
          closes: linearCloses(start: 100, end: 101.5, count: 48),
          rangePercent: 0.20,
        ),
      );

      final bearish = provider.evaluate(
        trendSnapshot(
          timeframe: '5m',
          closes: linearCloses(start: 100, end: 98.5, count: 48),
          rangePercent: 0.20,
        ),
      );

      expect(bullish.direction, EvidenceDirection.bullish);
      expect(bearish.direction, EvidenceDirection.bearish);
      expect(bullish.score, bearish.score);
    });

    test('all supported Trader intervals have a LIVE calibrated path', () {
      for (final timeframe in const ['1m', '5m', '15m', '30m', '1h']) {
        final count = timeframe == '1m' ? 60 : 48;

        final result = provider.evaluate(
          trendSnapshot(
            timeframe: timeframe,
            closes: linearCloses(start: 100, end: 101.5, count: count),
            rangePercent: 0.25,
          ),
        );

        expect(
          result.status,
          EvidenceStatus.available,
          reason: '$timeframe should have an active LIVE Trader calibration.',
        );
      }
    });

    test('synthetic fixture path preserves legacy fixed-percent behavior', () {
      final result = provider.evaluate(
        trendSnapshot(
          timeframe: '5m',
          closes: linearCloses(start: 100, end: 101, count: 48),
          rangePercent: 0.20,
          provenance: const DataProvenance.synthetic(),
        ),
      );

      expect(result.direction, EvidenceDirection.neutral);
      expect(result.score, 50);
    });
  });

  group('LIVE Trader intraday volume safety', () {
    const relativeVolume = RelativeVolumeEvidenceProvider();
    const confirmation = VolumeConfirmationEvidenceProvider();

    test('withholds RVOL without comparable session-position history', () {
      final result = relativeVolume.evaluate(volumeSnapshot());

      expect(result.status, EvidenceStatus.unavailable);
      expect(result.direction, EvidenceDirection.unknown);
      expect(result.unavailableReason, contains('same-session-position'));
    });

    test('withholds volume confirmation without session-aware history', () {
      final result = confirmation.evaluate(volumeSnapshot());

      expect(result.status, EvidenceStatus.unavailable);
      expect(result.direction, EvidenceDirection.unknown);
      expect(result.unavailableReason, contains('session-position'));
    });

    test('Stock Behavior exposes that short-term LIVE RVOL is unavailable', () {
      const service = StockBehaviorProfileService();

      final profile = service.evaluate(volumeSnapshot());

      expect(profile.hasComparableShortTermVolume, isFalse);
      expect(profile.averageVolume, 0);
    });
  });

  group('LIVE Trader VWAP', () {
    const provider = VwapPositionEvidenceProvider();

    MarketSnapshot snapshot(double halfRange) {
      final candles = List<MarketCandle>.generate(20, (index) {
        final close = index == 19 ? 100.6 : 100.0;

        return MarketCandle(
          timestamp: DateTime(
            2026,
            10,
            2,
            10,
          ).add(Duration(minutes: index * 5)),
          open: close,
          high: close + halfRange,
          low: close - halfRange,
          close: close,
          volume: 1000000,
        );
      }, growable: false);

      return MarketSnapshot(
        symbol: 'TEST',
        timeframe: '5m',
        timestamp: candles.last.timestamp,
        currentPrice: candles.last.close,
        currentVolume: candles.last.volume,
        candles: candles,
        provenance: live,
      );
    }

    test('normalizes price distance by current ATR', () {
      final lowNoise = provider.evaluate(snapshot(0.10));
      final highNoise = provider.evaluate(snapshot(2.00));

      expect(lowNoise.direction, EvidenceDirection.bullish);
      expect(highNoise.direction, EvidenceDirection.neutral);
      expect(lowNoise.relativeValue, contains('ATR'));
      expect(lowNoise.explanation, contains('analysis-window'));
    });
  });
}
