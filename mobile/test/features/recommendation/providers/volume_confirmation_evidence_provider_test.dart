import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/providers/volume_confirmation_evidence_provider.dart';

void main() {
  const provider = VolumeConfirmationEvidenceProvider();

  MarketSnapshot createSnapshot({
    required bool risingPrice,
    required bool risingVolume,
    String timeframe = '5m',
    int candleCount = 20,
    double priceStep = 0.25,
    double halfRange = 0.30,
    double priorVolume = 1000000,
    double expandingVolume = 1500000,
    double fadingVolume = 700000,
  }) {
    final candles = List<MarketCandle>.generate(candleCount, (index) {
      final startClose = risingPrice ? 100.0 : 105.0;

      final close = risingPrice
          ? startClose + (index * priceStep)
          : startClose - (index * priceStep);

      final split = candleCount ~/ 2;

      final volume = index < split
          ? priorVolume
          : risingVolume
          ? expandingVolume
          : fadingVolume;

      final timestamp = switch (timeframe.toLowerCase()) {
        '1d' => DateTime(2026, 7, 1).add(Duration(days: index)),
        '4h' => DateTime(2026, 8, 1, 10).add(Duration(hours: index * 4)),
        _ => DateTime(2026, 8, 18, 10).add(Duration(minutes: index * 5)),
      };

      return MarketCandle(
        timestamp: timestamp,
        open: close,
        high: close + halfRange,
        low: close - halfRange,
        close: close,
        volume: volume,
      );
    });

    return MarketSnapshot(
      symbol: 'TEST',
      timeframe: timeframe,
      timestamp: candles.last.timestamp,
      currentPrice: candles.last.close,
      currentVolume: candles.last.volume,
      candles: candles,
    );
  }

  group('Trader Volume Confirmation regression', () {
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

    test('strategy-aware Trader path preserves legacy result', () {
      final snapshot = createSnapshot(risingPrice: true, risingVolume: true);

      final legacy = provider.evaluate(snapshot);

      final strategyResult = provider.evaluateForStrategy(
        snapshot,
        strategy: StrategyType.trader,
      );

      expect(strategyResult.direction, legacy.direction);
      expect(strategyResult.strength, legacy.strength);
      expect(strategyResult.score, legacy.score);
      expect(strategyResult.currentValue, legacy.currentValue);
      expect(strategyResult.relativeValue, legacy.relativeValue);
    });
  });

  group('Swing Volume Confirmation', () {
    test(
      '1D uses ATR significance instead of the Trader fixed percent gate',
      () {
        final snapshot = createSnapshot(
          risingPrice: true,
          risingVolume: true,
          timeframe: '1d',
          candleCount: 20,
          priceStep: 0.02,
          halfRange: 0.03,
        );

        final rawPercent =
            ((snapshot.candles.last.close - snapshot.candles.first.close) /
                snapshot.candles.first.close) *
            100;

        expect(rawPercent.abs(), lessThan(0.50));

        final result = provider.evaluateForStrategy(
          snapshot,
          strategy: StrategyType.swing,
        );

        expect(result.status, EvidenceStatus.available);
        expect(result.direction, EvidenceDirection.bullish);
        expect(result.relativeValue, contains('ATR'));
      },
    );

    test(
      'large raw percent move can remain neutral when small relative to ATR',
      () {
        final snapshot = createSnapshot(
          risingPrice: true,
          risingVolume: true,
          timeframe: '1d',
          candleCount: 20,
          priceStep: 0.10,
          halfRange: 3.00,
        );

        final rawPercent =
            ((snapshot.candles.last.close - snapshot.candles.first.close) /
                snapshot.candles.first.close) *
            100;

        expect(rawPercent.abs(), greaterThan(0.50));

        final result = provider.evaluateForStrategy(
          snapshot,
          strategy: StrategyType.swing,
        );

        expect(result.status, EvidenceStatus.available);
        expect(result.direction, EvidenceDirection.neutral);
        expect(result.explanation, contains('not large enough'));
      },
    );

    test('expanding participation preserves BUY and SELL parity', () {
      final bullish = provider.evaluateForStrategy(
        createSnapshot(risingPrice: true, risingVolume: true, timeframe: '1d'),
        strategy: StrategyType.swing,
      );

      final bearish = provider.evaluateForStrategy(
        createSnapshot(risingPrice: false, risingVolume: true, timeframe: '1d'),
        strategy: StrategyType.swing,
      );

      expect(bullish.direction, EvidenceDirection.bullish);
      expect(bearish.direction, EvidenceDirection.bearish);
      expect(bullish.score, bearish.score);
      expect(bullish.reliability, bearish.reliability);
    });

    test('fading participation creates symmetric divergence evidence', () {
      final rising = provider.evaluateForStrategy(
        createSnapshot(risingPrice: true, risingVolume: false, timeframe: '1d'),
        strategy: StrategyType.swing,
      );

      final falling = provider.evaluateForStrategy(
        createSnapshot(
          risingPrice: false,
          risingVolume: false,
          timeframe: '1d',
        ),
        strategy: StrategyType.swing,
      );

      expect(rising.direction, EvidenceDirection.bearish);
      expect(falling.direction, EvidenceDirection.bullish);
      expect(rising.score, falling.score);
      expect(rising.explanation, contains('divergence'));
      expect(falling.explanation, contains('divergence'));
    });

    test('4H Swing uses its own volatility-aware policy', () {
      final result = provider.evaluateForStrategy(
        createSnapshot(
          risingPrice: true,
          risingVolume: true,
          timeframe: '4h',
          candleCount: 30,
          priceStep: 0.15,
          halfRange: 0.20,
        ),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.bullish);
      expect(result.baselineValue, contains('30-candle'));
      expect(result.explanation, contains('1.50 ATR'));
    });

    test('Swing requires sufficient strategy-specific history', () {
      final result = provider.evaluateForStrategy(
        createSnapshot(
          risingPrice: true,
          risingVolume: true,
          timeframe: '1d',
          candleCount: 10,
        ),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.insufficientData);
      expect(result.direction, EvidenceDirection.unknown);
    });

    test('unsupported Swing interval and Investor remain unavailable', () {
      final unsupported = provider.evaluateForStrategy(
        createSnapshot(risingPrice: true, risingVolume: true, timeframe: '1h'),
        strategy: StrategyType.swing,
      );

      final investor = provider.evaluateForStrategy(
        createSnapshot(risingPrice: true, risingVolume: true, timeframe: '1d'),
        strategy: StrategyType.investor,
      );

      expect(unsupported.status, EvidenceStatus.unavailable);
      expect(unsupported.direction, EvidenceDirection.unknown);
      expect(investor.status, EvidenceStatus.unavailable);
      expect(investor.direction, EvidenceDirection.unknown);
    });
  });
}
