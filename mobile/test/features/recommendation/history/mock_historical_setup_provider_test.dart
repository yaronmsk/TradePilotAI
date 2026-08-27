import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/market_context_profile.dart';
import 'package:mobile/features/recommendation/context/stock_behavior_profile.dart';
import 'package:mobile/features/recommendation/history/historical_setup_fingerprint.dart';
import 'package:mobile/features/recommendation/history/mock_historical_setup_provider.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';

void main() {
  HistoricalSetupFingerprint fingerprint({
    StrategyType strategy = StrategyType.trader,
    String primaryTimeframe = '5m',
  }) {
    return HistoricalSetupFingerprint(
      strategy: strategy,
      primaryTimeframe: primaryTimeframe,
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

  test(
    'rejects strategy or timeframe requests that disagree with the fingerprint',
    () async {
      const provider = MockHistoricalSetupProvider(
        caseCount: 8,
        comparisonCount: 8,
      );

      final current = fingerprint(
        strategy: StrategyType.swing,
        primaryTimeframe: '1d',
      );

      await expectLater(
        provider.loadDataset(
          symbol: 'AAPL',
          strategy: StrategyType.trader,
          primaryTimeframe: '1d',
          currentFingerprint: current,
          forwardBars: 10,
        ),
        throwsArgumentError,
      );

      await expectLater(
        provider.loadDataset(
          symbol: 'AAPL',
          strategy: StrategyType.swing,
          primaryTimeframe: '4h',
          currentFingerprint: current,
          forwardBars: 15,
        ),
        throwsArgumentError,
      );
    },
  );

  test('rejects a non-positive historical outcome horizon', () async {
    const provider = MockHistoricalSetupProvider(
      caseCount: 8,
      comparisonCount: 8,
    );

    final current = fingerprint(
      strategy: StrategyType.swing,
      primaryTimeframe: '1d',
    );

    await expectLater(
      provider.loadDataset(
        symbol: 'AAPL',
        strategy: StrategyType.swing,
        primaryTimeframe: '1d',
        currentFingerprint: current,
        forwardBars: 0,
      ),
      throwsArgumentError,
    );
  });

  test('Trader synthetic outcomes preserve legacy horizon behavior', () async {
    const provider = MockHistoricalSetupProvider(
      caseCount: 16,
      comparisonCount: 16,
    );

    final current = fingerprint();

    final shortWindow = await provider.loadDataset(
      symbol: 'AAPL',
      strategy: StrategyType.trader,
      primaryTimeframe: '5m',
      currentFingerprint: current,
      forwardBars: 8,
    );

    final legacyWindow = await provider.loadDataset(
      symbol: 'AAPL',
      strategy: StrategyType.trader,
      primaryTimeframe: '5m',
      currentFingerprint: current,
      forwardBars: 24,
    );

    expect(
      shortWindow.cases.map((item) => item.forwardReturnPercent).toList(),
      legacyWindow.cases.map((item) => item.forwardReturnPercent).toList(),
    );

    expect(
      shortWindow.comparisonObservations
          .map((item) => item.forwardReturnPercent)
          .toList(),
      legacyWindow.comparisonObservations
          .map((item) => item.forwardReturnPercent)
          .toList(),
    );
  });

  test('Swing 1D synthetic outcome magnitude respects forwardBars', () async {
    const provider = MockHistoricalSetupProvider(
      caseCount: 24,
      comparisonCount: 24,
    );

    final current = fingerprint(
      strategy: StrategyType.swing,
      primaryTimeframe: '1d',
    );

    final fiveBars = await provider.loadDataset(
      symbol: 'AAPL',
      strategy: StrategyType.swing,
      primaryTimeframe: '1d',
      currentFingerprint: current,
      forwardBars: 5,
    );

    final tenBars = await provider.loadDataset(
      symbol: 'AAPL',
      strategy: StrategyType.swing,
      primaryTimeframe: '1d',
      currentFingerprint: current,
      forwardBars: 10,
    );

    double meanAbsolute(List<double> values) {
      return values.fold<double>(0, (sum, value) => sum + value.abs()) /
          values.length;
    }

    final fiveBarMagnitude = meanAbsolute(
      fiveBars.cases.map((item) => item.forwardReturnPercent).toList(),
    );

    final tenBarMagnitude = meanAbsolute(
      tenBars.cases.map((item) => item.forwardReturnPercent).toList(),
    );

    expect(tenBarMagnitude, greaterThan(fiveBarMagnitude));

    expect(tenBarMagnitude / fiveBarMagnitude, closeTo(1.4142, 0.01));
  });

  test('Swing 4H synthetic outcome magnitude respects forwardBars', () async {
    const provider = MockHistoricalSetupProvider(
      caseCount: 24,
      comparisonCount: 24,
    );

    final current = fingerprint(
      strategy: StrategyType.swing,
      primaryTimeframe: '4h',
    );

    final eightBars = await provider.loadDataset(
      symbol: 'AAPL',
      strategy: StrategyType.swing,
      primaryTimeframe: '4h',
      currentFingerprint: current,
      forwardBars: 8,
    );

    final fifteenBars = await provider.loadDataset(
      symbol: 'AAPL',
      strategy: StrategyType.swing,
      primaryTimeframe: '4h',
      currentFingerprint: current,
      forwardBars: 15,
    );

    double meanAbsolute(List<double> values) {
      return values.fold<double>(0, (sum, value) => sum + value.abs()) /
          values.length;
    }

    final eightBarMagnitude = meanAbsolute(
      eightBars.cases.map((item) => item.forwardReturnPercent).toList(),
    );

    final fifteenBarMagnitude = meanAbsolute(
      fifteenBars.cases.map((item) => item.forwardReturnPercent).toList(),
    );

    expect(fifteenBarMagnitude, greaterThan(eightBarMagnitude));

    expect(fifteenBarMagnitude / eightBarMagnitude, closeTo(1.3693, 0.01));
  });
}
