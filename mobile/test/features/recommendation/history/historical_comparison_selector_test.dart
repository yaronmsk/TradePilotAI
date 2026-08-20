import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/market_context_profile.dart';
import 'package:mobile/features/recommendation/context/stock_behavior_profile.dart';
import 'package:mobile/features/recommendation/history/historical_comparison_selector.dart';
import 'package:mobile/features/recommendation/history/historical_setup_case.dart';
import 'package:mobile/features/recommendation/history/historical_setup_fingerprint.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';

void main() {
  HistoricalSetupFingerprint fingerprint({
    StockBehaviorType behavior = StockBehaviorType.volatile,
    VolatilityRegime volatility = VolatilityRegime.elevated,
    MarketBackdrop backdrop = MarketBackdrop.supportive,
    double trend = 70,
  }) {
    return HistoricalSetupFingerprint(
      strategy: StrategyType.trader,
      primaryTimeframe: '5m',
      stockBehaviorType: behavior,
      volatilityRegime: volatility,
      marketBackdrop: backdrop,
      relativeStrengthState: RelativeStrengthState.outperforming,
      familyDirectionScores: {EvidenceFamily.trend: trend},
      familyStrengthScores: const {EvidenceFamily.trend: 80},
      familyImportanceWeights: const {EvidenceFamily.trend: 1},
    );
  }

  HistoricalComparisonObservation observation({
    String symbol = 'NVDA',
    required HistoricalSetupFingerprint fingerprint,
    double returnPercent = 1,
    int day = 1,
  }) {
    return HistoricalComparisonObservation(
      symbol: symbol,
      occurredAt: DateTime.utc(2025, 1, day),
      fingerprint: fingerprint,
      forwardReturnPercent: returnPercent,
    );
  }

  test(
    'keeps same-stock observations with matching profile and surrounding context',
    () {
      const selector = HistoricalComparisonSelector();
      final current = fingerprint();

      final selected = selector.select(
        currentSymbol: 'NVDA',
        current: current,
        observations: [
          observation(fingerprint: fingerprint(trend: -90), day: 1),
          observation(
            fingerprint: fingerprint(behavior: StockBehaviorType.steady),
            day: 2,
          ),
          observation(
            fingerprint: fingerprint(volatility: VolatilityRegime.normal),
            day: 3,
          ),
          observation(
            fingerprint: fingerprint(backdrop: MarketBackdrop.challenging),
            day: 4,
          ),
          observation(
            symbol: 'TSLA',
            fingerprint: fingerprint(trend: -90),
            day: 5,
          ),
        ],
      );

      expect(selected, hasLength(1));
      expect(selected.single.symbol, 'NVDA');
      // Evidence can be completely opposite: baseline selection deliberately
      // ignores today's specific evidence setup.
      expect(
        selected.single.fingerprint.directionScoreFor(EvidenceFamily.trend),
        -90,
      );
    },
  );
}
