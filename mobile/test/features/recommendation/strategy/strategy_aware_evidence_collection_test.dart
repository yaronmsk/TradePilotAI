import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/context/recommendation_analysis_context.dart';
import 'package:mobile/features/recommendation/models/evidence_definition.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/providers/candle_trend_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/ema_structure_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/rsi_evidence_provider.dart';
import 'package:mobile/features/recommendation/services/recommendation_service.dart';
import 'package:mobile/features/recommendation/strategy/strategy_analysis_policy_catalog.dart';
import 'package:mobile/features/recommendation/strategy/strategy_evidence_selector.dart';

class _CountingEvidenceProvider implements EvidenceProvider {
  _CountingEvidenceProvider({required this.definition});

  @override
  final EvidenceDefinition definition;

  int evaluationCount = 0;

  @override
  String get name => definition.name;

  @override
  EvidenceResult evaluate(MarketSnapshot snapshot) {
    evaluationCount++;

    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.available,
      direction: EvidenceDirection.bullish,
      strength: EvidenceStrength.moderate,
      score: 50,
      baseWeight: 1,
      dynamicWeight: 1,
      reliability: 1,
      currentValue: '50',
      baselineValue: '50',
      relativeValue: '0',
      explanation: 'Strategy collection test evidence.',
    );
  }
}

void main() {
  MarketSnapshot createSnapshot() {
    final candle = MarketCandle(
      timestamp: DateTime(2026, 8, 23),
      open: 100,
      high: 102,
      low: 99,
      close: 101,
      volume: 1000000,
    );

    return MarketSnapshot(
      symbol: 'TEST',
      timeframe: '1D',
      timestamp: candle.timestamp,
      currentPrice: candle.close,
      currentVolume: candle.volume,
      candles: [candle],
    );
  }

  EvidenceDefinition productionDefinition({
    required EvidenceKind kind,
    required EvidenceFamily family,
    required String name,
  }) {
    return EvidenceDefinition(
      kind: kind,
      family: family,
      name: name,
      description: 'Test production evidence.',
      whyItMatters: 'Verifies strategy-aware evidence collection.',
      calculation: 'Uses deterministic test data.',
    );
  }

  group('strategy-aware evidence collection', () {
    test('Trader production evidence remains implementation-ready', () {
      final policy = StrategyAnalysisPolicyCatalog.trader;

      expect(
        policy.implementationReadyEvidenceKinds.toSet(),
        policy.eligibleEvidenceKinds.toSet(),
      );

      expect(
        policy.implementationReadyEvidenceKinds.length,
        EvidenceKind.values.length - 1,
      );
    });

    test('only calibrated Swing evidence is implementation-ready', () {
      final policy = StrategyAnalysisPolicyCatalog.swing;

      expect(policy.eligibleEvidenceKinds, isNotEmpty);
      expect(policy.implementationReadyEvidenceKinds, <EvidenceKind>[
        EvidenceKind.candleTrend,
        EvidenceKind.rsi,
        EvidenceKind.emaStructure,
        EvidenceKind.multiTimeframeTrend,
      ]);
    });

    test('Trader executes a classified production provider', () {
      final provider = _CountingEvidenceProvider(
        definition: productionDefinition(
          kind: EvidenceKind.rsi,
          family: EvidenceFamily.momentum,
          name: 'Test RSI',
        ),
      );

      final service = RecommendationService(providers: [provider]);

      final results = service.collectEvidence(
        createSnapshot(),
        strategy: StrategyType.trader,
      );

      expect(results, hasLength(1));
      expect(provider.evaluationCount, 1);
    });

    test(
      'Swing rejects a non-strategy-aware implementation even for a ready kind',
      () {
        final provider = _CountingEvidenceProvider(
          definition: productionDefinition(
            kind: EvidenceKind.candleTrend,
            family: EvidenceFamily.trend,
            name: 'Fake Candle Trend',
          ),
        );

        final service = RecommendationService(providers: [provider]);

        final results = service.collectEvidence(
          createSnapshot(),
          strategy: StrategyType.swing,
        );

        expect(results, isEmpty);
        expect(provider.evaluationCount, 0);
      },
    );

    test('Swing executes the calibrated Candle Trend implementation', () {
      final candles = List<MarketCandle>.generate(20, (index) {
        final close = 100 + ((8 / 19) * index);
        final halfRange = close * 0.0075;

        return MarketCandle(
          timestamp: DateTime(2026, 8, 1).add(Duration(days: index)),
          open: close,
          high: close + halfRange,
          low: close - halfRange,
          close: close,
          volume: 1000000,
        );
      });

      final snapshot = MarketSnapshot(
        symbol: 'TEST',
        timeframe: '1d',
        timestamp: candles.last.timestamp,
        currentPrice: candles.last.close,
        currentVolume: candles.last.volume,
        candles: candles,
      );

      const service = RecommendationService(
        providers: [CandleTrendEvidenceProvider()],
      );

      final results = service.collectEvidence(
        snapshot,
        strategy: StrategyType.swing,
      );

      expect(results, hasLength(1));
      expect(results.single.definition.kind, EvidenceKind.candleTrend);
      expect(results.single.direction, EvidenceDirection.bullish);
      expect(results.single.currentValue, contains('Rising'));
    });

    test('Swing executes calibrated EMA Structure', () {
      final candles = List<MarketCandle>.generate(60, (index) {
        final close = 100 + (index * 0.30);

        return MarketCandle(
          timestamp: DateTime(2026, 8, 1).add(Duration(hours: index * 4)),
          open: close,
          high: close + 0.4,
          low: close - 0.4,
          close: close,
          volume: 1000000,
        );
      });

      final snapshot = MarketSnapshot(
        symbol: 'TEST',
        timeframe: '4h',
        timestamp: candles.last.timestamp,
        currentPrice: candles.last.close,
        currentVolume: candles.last.volume,
        candles: candles,
      );

      const service = RecommendationService(
        providers: [EmaStructureEvidenceProvider()],
      );

      final results = service.collectEvidence(
        snapshot,
        strategy: StrategyType.swing,
      );

      expect(results, hasLength(1));
      expect(results.single.definition.kind, EvidenceKind.emaStructure);
      expect(results.single.direction, EvidenceDirection.bullish);
      expect(results.single.baselineValue, contains('EMA 20'));
      expect(results.single.baselineValue, contains('EMA 50'));
    });

    test('Swing executes calibrated RSI', () {
      final candles = List<MarketCandle>.generate(60, (index) {
        final close = 100 + (index * 0.30);

        return MarketCandle(
          timestamp: DateTime(2026, 8, 1).add(Duration(hours: index * 4)),
          open: close,
          high: close + 0.4,
          low: close - 0.4,
          close: close,
          volume: 1000000,
        );
      });

      final snapshot = MarketSnapshot(
        symbol: 'TEST',
        timeframe: '4h',
        timestamp: candles.last.timestamp,
        currentPrice: candles.last.close,
        currentVolume: candles.last.volume,
        candles: candles,
      );

      const service = RecommendationService(providers: [RsiEvidenceProvider()]);

      final results = service.collectEvidence(
        snapshot,
        strategy: StrategyType.swing,
      );

      expect(results, hasLength(1));
      expect(results.single.definition.kind, EvidenceKind.rsi);
      expect(results.single.direction, EvidenceDirection.bullish);
      expect(results.single.currentValue, 'RSI 100.00');
      expect(results.single.relativeValue, contains('extended'));
    });

    test('Swing does not execute an uncalibrated provider', () {
      final provider = _CountingEvidenceProvider(
        definition: productionDefinition(
          kind: EvidenceKind.macdMomentum,
          family: EvidenceFamily.momentum,
          name: 'Test MACD',
        ),
      );

      final service = RecommendationService(providers: [provider]);

      final results = service.collectEvidence(
        createSnapshot(),
        strategy: StrategyType.swing,
      );

      expect(results, isEmpty);
      expect(provider.evaluationCount, 0);
    });

    test('generic evidence remains Trader-only', () {
      const selector = StrategyEvidenceSelector();

      const genericDefinition = EvidenceDefinition(
        name: 'Generic test evidence',
        description: 'Generic test evidence.',
        whyItMatters: 'Used only for compatibility testing.',
        calculation: 'Predetermined.',
      );

      expect(
        selector.allowsDefinition(
          definition: genericDefinition,
          strategy: StrategyType.trader,
        ),
        isTrue,
      );

      expect(
        selector.allowsDefinition(
          definition: genericDefinition,
          strategy: StrategyType.swing,
        ),
        isFalse,
      );

      expect(
        selector.allowsDefinition(
          definition: genericDefinition,
          strategy: StrategyType.investor,
        ),
        isFalse,
      );
    });

    test('context evidence is filtered through the same strategy gate', () {
      const service = RecommendationService(providers: []);
      final snapshot = createSnapshot();
      final context = RecommendationAnalysisContext.unknown();

      final traderResults = service.collectContextualEvidence(
        snapshot,
        strategy: StrategyType.trader,
        analysisContext: context,
      );

      final swingResults = service.collectContextualEvidence(
        snapshot,
        strategy: StrategyType.swing,
        analysisContext: context,
      );

      expect(traderResults, hasLength(4));
      expect(swingResults, hasLength(1));
      expect(
        swingResults.single.definition.kind,
        EvidenceKind.multiTimeframeTrend,
      );
    });

    test('production Swing recommendation cannot run before activation', () {
      const service = RecommendationService(providers: []);

      expect(
        () => service.analyze(createSnapshot(), strategy: StrategyType.swing),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Swing recommendation is not active yet'),
          ),
        ),
      );
    });

    test('Investor recommendation also remains inactive', () {
      const service = RecommendationService(providers: []);

      expect(
        () =>
            service.analyze(createSnapshot(), strategy: StrategyType.investor),
        throwsA(isA<StateError>()),
      );
    });
  });
}
