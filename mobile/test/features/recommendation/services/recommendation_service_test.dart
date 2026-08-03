import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/recommendation.dart';
import 'package:mobile/features/recommendation/providers/evidence_provider.dart';
import 'package:mobile/features/recommendation/services/recommendation_service.dart';

class FakeEvidenceProvider implements EvidenceProvider {
  const FakeEvidenceProvider(this.name, this.result);

  @override
  final String name;

  final EvidenceResult result;

  @override
  EvidenceResult evaluate(MarketSnapshot snapshot) => result;
}

void main() {
  MarketSnapshot createSnapshot() {
    final candle = MarketCandle(
      timestamp: DateTime(2026, 8, 3),
      open: 100,
      high: 101,
      low: 99,
      close: 100,
      volume: 1000000,
    );

    return MarketSnapshot(
      symbol: 'TEST',
      timeframe: '5m',
      timestamp: candle.timestamp,
      currentPrice: candle.close,
      currentVolume: candle.volume,
      candles: [candle],
    );
  }

  EvidenceResult createResult(String providerName) {
    return EvidenceResult(
      providerName: providerName,
      status: EvidenceStatus.available,
      direction: EvidenceDirection.neutral,
      strength: EvidenceStrength.moderate,
      score: 50,
      baseWeight: 1,
      dynamicWeight: 1,
      reliability: 1,
      currentValue: '50',
      baselineValue: '50',
      relativeValue: '0',
      explanation: providerName,
    );
  }

  group('RecommendationService', () {
    test('returns evidence from all registered providers', () {
      final service = RecommendationService(
        providers: [
          FakeEvidenceProvider('Provider A', createResult('Provider A')),
          FakeEvidenceProvider('Provider B', createResult('Provider B')),
        ],
      );

      final evidence = service.collectEvidence(createSnapshot());

      expect(evidence.length, 2);
      expect(evidence[0].providerName, 'Provider A');
      expect(evidence[1].providerName, 'Provider B');
    });

    test('returns an empty list when no providers are registered', () {
      const service = RecommendationService(providers: []);

      final evidence = service.collectEvidence(createSnapshot());

      expect(evidence, isEmpty);
    });

    test('produces a complete recommendation from evidence', () {
      final service = RecommendationService(
        providers: [
          FakeEvidenceProvider(
            'Bullish Provider',
            EvidenceResult(
              providerName: 'Bullish Provider',
              status: EvidenceStatus.available,
              direction: EvidenceDirection.bullish,
              strength: EvidenceStrength.exceptional,
              score: 90,
              baseWeight: 1,
              dynamicWeight: 1,
              reliability: 1,
              currentValue: '90',
              baselineValue: '50',
              relativeValue: '40',
              explanation: 'Strong bullish evidence.',
            ),
          ),
        ],
      );

      final recommendation = service.analyze(createSnapshot());

      expect(recommendation.type, RecommendationType.strongBuy);

      expect(recommendation.evidenceScore, 90);
      expect(recommendation.evidenceReport.results.length, 1);
      expect(recommendation.timeframe, '5m');
      expect(recommendation.candleCount, 1);
    });
  });
}
