import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/market_context_profile.dart';
import 'package:mobile/features/recommendation/context/stock_behavior_profile.dart';
import 'package:mobile/features/recommendation/history/historical_setup_fingerprint.dart';
import 'package:mobile/features/recommendation/history/mock_historical_setup_provider.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';

void main() {
  HistoricalSetupFingerprint fingerprint() {
    return HistoricalSetupFingerprint(
      strategy: StrategyType.trader,
      primaryTimeframe: '5m',
      stockBehaviorType: StockBehaviorType.balanced,
      volatilityRegime: VolatilityRegime.normal,
      marketBackdrop: MarketBackdrop.supportive,
      relativeStrengthState: RelativeStrengthState.outperforming,
      familyDirectionScores: const {
        EvidenceFamily.trend: 70,
        EvidenceFamily.momentum: 45,
      },
      familyStrengthScores: const {
        EvidenceFamily.trend: 80,
        EvidenceFamily.momentum: 65,
      },
      familyImportanceWeights: const {
        EvidenceFamily.trend: 0.65,
        EvidenceFamily.momentum: 0.35,
      },
    );
  }

  test(
    'returns deterministic synthetic setups and stock comparison observations',
    () async {
      const provider = MockHistoricalSetupProvider(
        caseCount: 12,
        comparisonCount: 16,
      );
      final current = fingerprint();

      final first = await provider.loadDataset(
        symbol: 'AAPL',
        strategy: StrategyType.trader,
        primaryTimeframe: '5m',
        currentFingerprint: current,
        forwardBars: 24,
      );
      final second = await provider.loadDataset(
        symbol: 'AAPL',
        strategy: StrategyType.trader,
        primaryTimeframe: '5m',
        currentFingerprint: current,
        forwardBars: 24,
      );

      expect(first.isSynthetic, isTrue);
      expect(first.cases, hasLength(12));
      expect(first.comparisonObservations, hasLength(16));
      expect(
        first.comparisonObservations.every((item) => item.symbol == 'AAPL'),
        isTrue,
      );
      expect(
        first.cases.map((item) => item.forwardReturnPercent).toList(),
        second.cases.map((item) => item.forwardReturnPercent).toList(),
      );
      expect(
        first.comparisonObservations
            .map((item) => item.forwardReturnPercent)
            .toList(),
        second.comparisonObservations
            .map((item) => item.forwardReturnPercent)
            .toList(),
      );
    },
  );

  test(
    'development scenarios can produce different historical alignment by symbol',
    () async {
      const provider = MockHistoricalSetupProvider(
        caseCount: 60,
        comparisonCount: 60,
      );
      final current = fingerprint();

      final nvda = await provider.loadDataset(
        symbol: 'NVDA',
        strategy: StrategyType.trader,
        primaryTimeframe: '5m',
        currentFingerprint: current,
        forwardBars: 24,
      );
      final goog = await provider.loadDataset(
        symbol: 'GOOG',
        strategy: StrategyType.trader,
        primaryTimeframe: '5m',
        currentFingerprint: current,
        forwardBars: 24,
      );

      final nvdaPositive = nvda.cases
          .where((item) => item.forwardReturnPercent > 0)
          .length;
      final googPositive = goog.cases
          .where((item) => item.forwardReturnPercent > 0)
          .length;

      expect(nvdaPositive, greaterThan(googPositive));
    },
  );
}
