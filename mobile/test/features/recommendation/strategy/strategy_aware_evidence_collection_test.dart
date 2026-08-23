import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/context/recommendation_analysis_context.dart';
import 'package:mobile/features/recommendation/models/evidence_definition.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/providers/evidence_provider.dart';
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

    test(
      'Swing evidence is in scope but not executable before calibration',
      () {
        final policy = StrategyAnalysisPolicyCatalog.swing;

        expect(policy.eligibleEvidenceKinds, isNotEmpty);
        expect(policy.implementationReadyEvidenceKinds, isEmpty);
      },
    );

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

    test('Swing does not execute an uncalibrated provider', () {
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
      expect(swingResults, isEmpty);
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
