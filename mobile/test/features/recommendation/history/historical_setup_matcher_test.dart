import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/market_context_profile.dart';
import 'package:mobile/features/recommendation/context/stock_behavior_profile.dart';
import 'package:mobile/features/recommendation/history/historical_setup_case.dart';
import 'package:mobile/features/recommendation/history/historical_setup_fingerprint.dart';
import 'package:mobile/features/recommendation/history/historical_setup_matcher.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';

void main() {
  HistoricalSetupFingerprint fingerprint({
    double trend = 70,
    double momentum = 55,
    StockBehaviorType behavior = StockBehaviorType.balanced,
    VolatilityRegime volatility = VolatilityRegime.normal,
    MarketBackdrop backdrop = MarketBackdrop.supportive,
    RelativeStrengthState relativeStrength =
        RelativeStrengthState.outperforming,
  }) {
    return HistoricalSetupFingerprint(
      strategy: StrategyType.trader,
      primaryTimeframe: '5m',
      stockBehaviorType: behavior,
      volatilityRegime: volatility,
      marketBackdrop: backdrop,
      relativeStrengthState: relativeStrength,
      familyDirectionScores: {
        EvidenceFamily.trend: trend,
        EvidenceFamily.momentum: momentum,
      },
      familyStrengthScores: const {
        EvidenceFamily.trend: 80,
        EvidenceFamily.momentum: 65,
      },
      familyImportanceWeights: const {
        EvidenceFamily.trend: 0.6,
        EvidenceFamily.momentum: 0.4,
      },
    );
  }

  HistoricalSetupCase setupCase(
    HistoricalSetupFingerprint setupFingerprint, {
    String symbol = 'AAPL',
  }) {
    return HistoricalSetupCase(
      symbol: symbol,
      occurredAt: DateTime.utc(2025, 1, 1),
      fingerprint: setupFingerprint,
      forwardReturnPercent: 1.2,
      maxFavorableExcursionPercent: 1.8,
      maxAdverseExcursionPercent: -0.6,
    );
  }

  test(
    'exact setup ranks ahead of a materially different same-profile setup',
    () {
      const matcher = HistoricalSetupMatcher(minimumSimilarity: 0.2);
      final current = fingerprint();
      final exact = setupCase(current);
      final distant = setupCase(
        fingerprint(
          trend: -75,
          momentum: -60,
          volatility: VolatilityRegime.elevated,
          backdrop: MarketBackdrop.challenging,
          relativeStrength: RelativeStrengthState.underperforming,
        ),
        symbol: 'GOOG',
      );

      final matches = matcher.match(
        currentSymbol: 'AAPL',
        current: current,
        candidates: [distant, exact],
      );

      expect(matches, hasLength(2));
      expect(matches.first.setupCase.symbol, 'AAPL');
      expect(matches.first.similarity, closeTo(1, 0.001));
      expect(matches.first.similarity, greaterThan(matches.last.similarity));
    },
  );

  test(
    'different Stock Profile is excluded even when evidence is identical',
    () {
      const matcher = HistoricalSetupMatcher(minimumSimilarity: 0.0);
      final current = fingerprint(behavior: StockBehaviorType.volatile);
      final sameProfile = setupCase(current, symbol: 'NVDA');
      final wrongProfile = setupCase(
        fingerprint(behavior: StockBehaviorType.steady),
        symbol: 'MSFT',
      );

      final matches = matcher.match(
        currentSymbol: 'NVDA',
        current: current,
        candidates: [wrongProfile, sameProfile],
      );

      expect(matches, hasLength(1));
      expect(matches.single.setupCase.symbol, 'NVDA');
      expect(
        matches.single.setupCase.fingerprint.stockBehaviorType,
        StockBehaviorType.volatile,
      );
    },
  );

  test('same-symbol preference changes statistical weight, not similarity', () {
    const matcher = HistoricalSetupMatcher(minimumSimilarity: 0.5);
    final current = fingerprint();
    final sameSymbol = setupCase(current, symbol: 'AAPL');
    final peer = setupCase(current, symbol: 'MSFT');

    final matches = matcher.match(
      currentSymbol: 'AAPL',
      current: current,
      candidates: [peer, sameSymbol],
    );

    final aapl = matches.firstWhere(
      (match) => match.setupCase.symbol == 'AAPL',
    );
    final msft = matches.firstWhere(
      (match) => match.setupCase.symbol == 'MSFT',
    );

    expect(aapl.similarity, closeTo(msft.similarity, 0.001));
    expect(aapl.weight, greaterThan(msft.weight));
  });
}
