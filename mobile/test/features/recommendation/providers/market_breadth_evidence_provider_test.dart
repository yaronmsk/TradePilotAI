import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/external_context_profile.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/providers/market_breadth_evidence_provider.dart';

void main() {
  const provider = MarketBreadthEvidenceProvider();

  MarketBreadthProfile profile({
    required double advancing,
    required double above50,
    required double sectors,
    double volatility = 40,
    double legacyDirectionScore = 0,
    MarketBreadthState legacyState = MarketBreadthState.mixed,
  }) {
    return MarketBreadthProfile(
      state: legacyState,
      advancingPercent: advancing,
      above50DayPercent: above50,
      sectorParticipationPercent: sectors,
      volatilityPercentile: volatility,
      directionScore: legacyDirectionScore,
      reliability: 0.90,
      summary: 'Synthetic breadth test profile.',
    );
  }

  group('Trader Market Breadth regression', () {
    test('maps healthy breadth into bullish Market Context evidence', () {
      const breadth = MarketBreadthProfile(
        state: MarketBreadthState.healthy,
        advancingPercent: 62,
        above50DayPercent: 64,
        sectorParticipationPercent: 59,
        volatilityPercentile: 40,
        directionScore: 38,
        reliability: 0.9,
        summary: 'Healthy participation.',
      );

      final result = provider.evaluate(breadth);

      expect(result.definition.family, EvidenceFamily.marketContext);
      expect(result.direction, EvidenceDirection.bullish);
      expect(result.reliability, 0.9);
      expect(result.baseWeight, 0.65);
    });

    test('strategy-aware Trader call preserves legacy result', () {
      const breadth = MarketBreadthProfile(
        state: MarketBreadthState.healthy,
        advancingPercent: 62,
        above50DayPercent: 64,
        sectorParticipationPercent: 59,
        volatilityPercentile: 40,
        directionScore: 38,
        reliability: 0.9,
        summary: 'Healthy participation.',
      );

      final legacy = provider.evaluate(breadth);

      final strategyResult = provider.evaluate(
        breadth,
        strategy: StrategyType.trader,
      );

      expect(strategyResult.direction, legacy.direction);
      expect(strategyResult.score, legacy.score);
      expect(strategyResult.baseWeight, legacy.baseWeight);
      expect(strategyResult.currentValue, legacy.currentValue);
    });

    test('keeps breadth unavailable when data is missing', () {
      final result = provider.evaluate(
        const MarketBreadthProfile.unavailable(),
      );

      expect(result.status, EvidenceStatus.insufficientData);
      expect(result.direction, EvidenceDirection.unknown);
    });
  });

  group('Swing Market Breadth', () {
    test(
      'recalculates broad participation instead of trusting legacy score',
      () {
        final result = provider.evaluate(
          profile(
            advancing: 70,
            above50: 70,
            sectors: 70,
            legacyDirectionScore: -60,
            legacyState: MarketBreadthState.stressed,
          ),
          strategy: StrategyType.swing,
        );

        expect(result.status, EvidenceStatus.available);
        expect(result.direction, EvidenceDirection.bullish);
        expect(result.currentValue, 'Healthy');
        expect(result.baseWeight, 0.55);
      },
    );

    test('preserves bullish and bearish breadth parity', () {
      final bullish = provider.evaluate(
        profile(advancing: 70, above50: 70, sectors: 70),
        strategy: StrategyType.swing,
      );

      final bearish = provider.evaluate(
        profile(advancing: 30, above50: 30, sectors: 30),
        strategy: StrategyType.swing,
      );

      expect(bullish.direction, EvidenceDirection.bullish);
      expect(bearish.direction, EvidenceDirection.bearish);
      expect(bullish.score, bearish.score);
      expect(bullish.baseWeight, bearish.baseWeight);
    });

    test('mixed breadth remains neutral', () {
      final result = provider.evaluate(
        profile(advancing: 55, above50: 48, sectors: 52),
        strategy: StrategyType.swing,
      );

      expect(result.direction, EvidenceDirection.neutral);
      expect(result.currentValue, 'Mixed');
    });

    test('high volatility reduces influence without creating direction', () {
      final normalVolatility = provider.evaluate(
        profile(advancing: 70, above50: 70, sectors: 70, volatility: 40),
        strategy: StrategyType.swing,
      );

      final extremeVolatility = provider.evaluate(
        profile(advancing: 70, above50: 70, sectors: 70, volatility: 92),
        strategy: StrategyType.swing,
      );

      expect(normalVolatility.direction, EvidenceDirection.bullish);
      expect(extremeVolatility.direction, EvidenceDirection.bullish);

      expect(normalVolatility.dynamicWeight, 1);
      expect(extremeVolatility.dynamicWeight, 0.70);
      expect(
        extremeVolatility.explanation,
        contains('does not create bearish direction'),
      );
    });

    test('Investor remains unavailable', () {
      final result = provider.evaluate(
        profile(advancing: 70, above50: 70, sectors: 70),
        strategy: StrategyType.investor,
      );

      expect(result.status, EvidenceStatus.unavailable);
      expect(result.direction, EvidenceDirection.unknown);
    });
  });
}
