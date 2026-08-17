import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/controllers/recommendation_controller.dart';
import 'package:mobile/features/recommendation/models/recommendation.dart';
import 'package:mobile/features/recommendation/models/recommendation_state.dart';
import 'package:mobile/features/recommendation/providers/candle_trend_evidence_provider.dart';
import 'package:mobile/features/recommendation/services/recommendation_service.dart';

void main() {
  MarketSnapshot createSnapshot({
    required double firstClose,
    required double lastClose,
  }) {
    final candles = [
      MarketCandle(
        timestamp: DateTime(2026, 8, 3, 10),
        open: firstClose,
        high: firstClose,
        low: firstClose,
        close: firstClose,
        volume: 1000000,
      ),
      MarketCandle(
        timestamp: DateTime(2026, 8, 3, 10, 5),
        open: lastClose,
        high: lastClose,
        low: lastClose,
        close: lastClose,
        volume: 1200000,
      ),
    ];

    return MarketSnapshot(
      symbol: 'TEST',
      timeframe: '5m',
      timestamp: candles.last.timestamp,
      currentPrice: lastClose,
      currentVolume: candles.last.volume,
      candles: candles,
    );
  }

  List<MarketCandle> createDailyHistory() {
    var close = 100.0;

    return List<MarketCandle>.generate(252, (index) {
      final open = close;
      final move = index.isEven ? 0.004 : -0.0037;
      close = open * (1 + move);

      return MarketCandle(
        timestamp: DateTime(2025, 1, 1).add(Duration(days: index)),
        open: open,
        high: (open > close ? open : close) * 1.004,
        low: (open < close ? open : close) * 0.996,
        close: close,
        volume: 1000000,
      );
    }, growable: false);
  }

  group('RecommendationController', () {
    late RecommendationController controller;

    setUp(() {
      controller = RecommendationController(
        const RecommendationService(providers: [CandleTrendEvidenceProvider()]),
      );
    });

    test('starts with initial state', () {
      expect(controller.state.status, RecommendationStatus.initial);
      expect(controller.state.recommendation, isNull);
      expect(controller.state.errorMessage, isNull);
    });

    test('creates a strong buy recommendation from bullish evidence', () {
      controller.analyze(createSnapshot(firstClose: 100, lastClose: 106));

      expect(controller.state.status, RecommendationStatus.ready);

      expect(
        controller.state.recommendation?.type,
        RecommendationType.strongBuy,
      );

      expect(controller.state.errorMessage, isNull);
    });

    test('creates a strong sell recommendation from bearish evidence', () {
      controller.analyze(createSnapshot(firstClose: 100, lastClose: 94));

      expect(controller.state.status, RecommendationStatus.ready);

      expect(
        controller.state.recommendation?.type,
        RecommendationType.strongSell,
      );
    });

    test('reset returns to initial state', () {
      controller.analyze(createSnapshot(firstClose: 100, lastClose: 106));

      controller.reset();

      expect(controller.state.status, RecommendationStatus.initial);

      expect(controller.state.recommendation, isNull);
      expect(controller.state.errorMessage, isNull);
    });

    test('notifies listeners after analysis', () {
      var notificationCount = 0;

      controller.addListener(() {
        notificationCount++;
      });

      controller.analyze(createSnapshot(firstClose: 100, lastClose: 106));

      expect(notificationCount, 2);
    });

    test('stores a one-year Stock DNA profile when history is supplied', () {
      controller.analyze(
        createSnapshot(firstClose: 100, lastClose: 106),
        historicalDailyCandles: createDailyHistory(),
      );

      expect(controller.state.status, RecommendationStatus.ready);
      expect(controller.state.stockBehaviorProfile, isNotNull);
      expect(
        controller.state.stockBehaviorProfile!.hasHistoricalBaseline,
        isTrue,
      );
      expect(controller.state.stockBehaviorProfile!.historicalSampleSize, 252);
    });
  });
}
