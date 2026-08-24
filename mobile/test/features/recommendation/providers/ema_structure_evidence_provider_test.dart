import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/providers/ema_structure_evidence_provider.dart';

void main() {
  const provider = EmaStructureEvidenceProvider();

  MarketSnapshot snapshotFromCloses(
    List<double> closes, {
    String timeframe = '5m',
  }) {
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
      timeframe: timeframe,
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
  group('Swing EMA Structure', () {
    test('1D Swing requires sufficient EMA history', () {
      final result = provider.evaluateForStrategy(
        snapshotFromCloses(
          List<double>.generate(54, (index) => 100 + (index * 0.2)),
          timeframe: '1d',
        ),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.insufficientData);
      expect(result.direction, EvidenceDirection.unknown);
    });

    test('Trader path remains unchanged through strategy interface', () {
      final snapshot = snapshotFromCloses(
        List<double>.generate(48, (index) => 100 + (index * 0.35)),
      );

      final legacy = provider.evaluate(snapshot);

      final strategyAware = provider.evaluateForStrategy(
        snapshot,
        strategy: StrategyType.trader,
      );

      expect(strategyAware.direction, legacy.direction);
      expect(strategyAware.score, legacy.score);
      expect(strategyAware.reliability, legacy.reliability);
      expect(strategyAware.currentValue, legacy.currentValue);
    });

    test('clean 1D structures preserve bullish and bearish parity', () {
      final bullish = provider.evaluateForStrategy(
        snapshotFromCloses(
          List<double>.generate(80, (index) => 100 + (index * 0.35)),
          timeframe: '1d',
        ),
        strategy: StrategyType.swing,
      );

      final bearish = provider.evaluateForStrategy(
        snapshotFromCloses(
          List<double>.generate(80, (index) => 120 - (index * 0.35)),
          timeframe: '1d',
        ),
        strategy: StrategyType.swing,
      );

      expect(bullish.direction, EvidenceDirection.bullish);
      expect(bearish.direction, EvidenceDirection.bearish);
      expect(bullish.score, bearish.score);
      expect(bullish.reliability, closeTo(bearish.reliability, 0.001));
      expect(bullish.baselineValue, contains('EMA 20'));
      expect(bullish.baselineValue, contains('EMA 50'));
      expect(bullish.relativeValue, contains('ATR separation'));
    });

    test('flat Swing structure stays neutral', () {
      final result = provider.evaluateForStrategy(
        snapshotFromCloses(List<double>.filled(80, 100), timeframe: '1d'),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.neutral);
      expect(result.score, 50);
    });

    test('4H Swing uses approved 20/50 EMA structure', () {
      final result = provider.evaluateForStrategy(
        snapshotFromCloses(
          List<double>.generate(60, (index) => 100 + (index * 0.30)),
          timeframe: '4h',
        ),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.bullish);
      expect(result.baselineValue, contains('EMA 20'));
      expect(result.baselineValue, contains('EMA 50'));
    });

    test('unsupported Swing interval and Investor stay unavailable', () {
      final closes = List<double>.generate(80, (index) => 100 + (index * 0.25));

      final unsupportedSwing = provider.evaluateForStrategy(
        snapshotFromCloses(closes, timeframe: '1h'),
        strategy: StrategyType.swing,
      );

      final investor = provider.evaluateForStrategy(
        snapshotFromCloses(closes, timeframe: '1d'),
        strategy: StrategyType.investor,
      );

      expect(unsupportedSwing.status, EvidenceStatus.unavailable);
      expect(unsupportedSwing.direction, EvidenceDirection.unknown);

      expect(investor.status, EvidenceStatus.unavailable);
      expect(investor.direction, EvidenceDirection.unknown);
    });
  });
}
