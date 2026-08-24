import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/providers/candle_trend_evidence_provider.dart';

void main() {
  const provider = CandleTrendEvidenceProvider();

  MarketSnapshot createSnapshot({
    required List<double> closes,
    String timeframe = '5m',
    double rangePercent = 0,
  }) {
    final candles = List<MarketCandle>.generate(closes.length, (index) {
      final close = closes[index];
      final halfRange = close * (rangePercent / 200);

      return MarketCandle(
        timestamp: DateTime(2026, 8, 10, 10).add(Duration(hours: index * 4)),
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
      timestamp: candles.isEmpty
          ? DateTime(2026, 8, 10)
          : candles.last.timestamp,
      currentPrice: candles.isEmpty ? 0 : candles.last.close,
      currentVolume: candles.isEmpty ? 0 : candles.last.volume,
      candles: candles,
    );
  }

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

  group('CandleTrendEvidenceProvider Trader compatibility', () {
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

    test('clean trend has higher reliability than noisy trend', () {
      final cleanResult = provider.evaluate(
        createSnapshot(closes: const [100, 102, 104, 106]),
      );

      final noisyResult = provider.evaluate(
        createSnapshot(closes: const [100, 110, 95, 112, 106]),
      );

      expect(cleanResult.reliability, greaterThan(noisyResult.reliability));
    });

    test('larger candle sample increases reliability', () {
      final shortResult = provider.evaluate(
        createSnapshot(closes: const [100, 106]),
      );

      final longCloses = List<double>.generate(
        48,
        (index) => 100 + (index * 0.2),
      );

      final longResult = provider.evaluate(createSnapshot(closes: longCloses));

      expect(longResult.reliability, greaterThan(shortResult.reliability));
    });

    test('reliability never exceeds 95 percent', () {
      final closes = List<double>.generate(
        60,
        (index) => 100 + index.toDouble(),
      );

      final result = provider.evaluate(createSnapshot(closes: closes));

      expect(result.reliability, lessThanOrEqualTo(0.95));
    });
  });

  group('CandleTrendEvidenceProvider Swing calibration', () {
    test('1D Swing requires at least 12 candles', () {
      final result = provider.evaluateForStrategy(
        createSnapshot(
          timeframe: '1d',
          closes: linearCloses(start: 100, end: 108, count: 11),
          rangePercent: 1.5,
        ),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.insufficientData);
      expect(result.direction, EvidenceDirection.unknown);
    });

    test('same 3 percent move is not treated like Trader fixed threshold', () {
      final snapshot = createSnapshot(
        timeframe: '1d',
        closes: linearCloses(start: 100, end: 103, count: 20),
        rangePercent: 3,
      );

      final trader = provider.evaluate(snapshot);

      final swing = provider.evaluateForStrategy(
        snapshot,
        strategy: StrategyType.swing,
      );

      expect(trader.direction, EvidenceDirection.bullish);
      expect(trader.score, 80);

      expect(swing.direction, EvidenceDirection.neutral);
      expect(swing.score, 35);
      expect(swing.relativeValue, contains('volatility-normalized'));
    });

    test('clean daily rise creates bullish Swing trend evidence', () {
      final result = provider.evaluateForStrategy(
        createSnapshot(
          timeframe: '1d',
          closes: linearCloses(start: 100, end: 108, count: 20),
          rangePercent: 1.5,
        ),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.bullish);
      expect(
        result.strength,
        anyOf(EvidenceStrength.strong, EvidenceStrength.exceptional),
      );
      expect(result.currentValue, contains('Rising'));
      expect(result.explanation, contains('volatility-normalized'));
    });

    test('clean daily fall creates symmetric bearish Swing evidence', () {
      final bullish = provider.evaluateForStrategy(
        createSnapshot(
          timeframe: '1d',
          closes: linearCloses(start: 100, end: 108, count: 20),
          rangePercent: 1.5,
        ),
        strategy: StrategyType.swing,
      );

      final bearish = provider.evaluateForStrategy(
        createSnapshot(
          timeframe: '1d',
          closes: linearCloses(start: 100, end: 92, count: 20),
          rangePercent: 1.5,
        ),
        strategy: StrategyType.swing,
      );

      expect(bullish.direction, EvidenceDirection.bullish);
      expect(bearish.direction, EvidenceDirection.bearish);

      expect(bullish.score, bearish.score);
      expect(bullish.reliability, closeTo(bearish.reliability, 0.01));
    });

    test('noisy path has lower reliability than clean Swing trend', () {
      final clean = provider.evaluateForStrategy(
        createSnapshot(
          timeframe: '1d',
          closes: linearCloses(start: 100, end: 108, count: 20),
          rangePercent: 1.5,
        ),
        strategy: StrategyType.swing,
      );

      final noisy = provider.evaluateForStrategy(
        createSnapshot(
          timeframe: '1d',
          closes: const [
            100,
            106,
            97,
            107,
            98,
            108,
            99,
            109,
            100,
            110,
            101,
            111,
            102,
            112,
            103,
            111,
            104,
            110,
            105,
            108,
          ],
          rangePercent: 1.5,
        ),
        strategy: StrategyType.swing,
      );

      expect(clean.reliability, greaterThan(noisy.reliability));
    });

    test(
      'Swing uses the most recent strategy window rather than old history',
      () {
        final oldHistory = linearCloses(start: 150, end: 100, count: 20);

        final recentHistory = linearCloses(start: 100, end: 101, count: 20);

        final result = provider.evaluateForStrategy(
          createSnapshot(
            timeframe: '1d',
            closes: [...oldHistory, ...recentHistory],
            rangePercent: 2,
          ),
          strategy: StrategyType.swing,
        );

        expect(result.direction, EvidenceDirection.neutral);
        expect(result.currentValue, contains('1.00%'));
        expect(result.baselineValue, contains('20 daily candles'));
      },
    );

    test('4H Swing uses its dedicated longer candle window', () {
      final result = provider.evaluateForStrategy(
        createSnapshot(
          timeframe: '4h',
          closes: linearCloses(start: 100, end: 108, count: 30),
          rangePercent: 1.2,
        ),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.bullish);
      expect(result.baselineValue, contains('30 4-hour candles'));
    });

    test('unsupported Swing primary interval remains unavailable', () {
      final result = provider.evaluateForStrategy(
        createSnapshot(
          timeframe: '1h',
          closes: linearCloses(start: 100, end: 110, count: 30),
          rangePercent: 1,
        ),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.unavailable);
      expect(result.direction, EvidenceDirection.unknown);
      expect(result.unavailableReason, contains('1D and 4H'));
    });

    test('Investor Candle Trend remains unavailable in v0.11', () {
      final result = provider.evaluateForStrategy(
        createSnapshot(
          timeframe: '1d',
          closes: linearCloses(start: 100, end: 110, count: 20),
          rangePercent: 1,
        ),
        strategy: StrategyType.investor,
      );

      expect(result.status, EvidenceStatus.unavailable);
      expect(result.direction, EvidenceDirection.unknown);
    });
  });
}
