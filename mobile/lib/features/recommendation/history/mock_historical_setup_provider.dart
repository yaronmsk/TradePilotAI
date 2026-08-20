import 'dart:math' as math;

import '../context/market_context_profile.dart';
import '../context/stock_behavior_profile.dart';
import '../models/evidence_family.dart';
import '../models/strategy_summary.dart';
import 'historical_setup_case.dart';
import 'historical_setup_fingerprint.dart';
import 'historical_setup_provider.dart';

class MockHistoricalSetupProvider implements HistoricalSetupProvider {
  const MockHistoricalSetupProvider({
    this.caseCount = 72,
    this.comparisonCount = 144,
  });

  final int caseCount;
  final int comparisonCount;

  @override
  Future<HistoricalSetupDataset> loadDataset({
    required String symbol,
    required StrategyType strategy,
    required String primaryTimeframe,
    required HistoricalSetupFingerprint currentFingerprint,
    required int forwardBars,
  }) async {
    final normalizedSymbol = symbol.trim().toUpperCase();
    final directionSign = _currentDirectionSign(currentFingerprint);
    final alignmentBias = _alignmentBiasForSymbol(normalizedSymbol);
    final magnitudeBase = _moveMagnitudeFor(currentFingerprint);
    final peers = _peerSymbols(
      normalizedSymbol,
      currentFingerprint.stockBehaviorType,
    );

    final cases = List<HistoricalSetupCase>.generate(caseCount, (index) {
      final unit = _unit('$normalizedSymbol|$primaryTimeframe|case|$index');
      final secondaryUnit = _unit(
        '$normalizedSymbol|$primaryTimeframe|case2|$index',
      );
      final tertiaryUnit = _unit(
        '$normalizedSymbol|$primaryTimeframe|case3|$index',
      );

      final shouldAlign = unit < alignmentBias;
      final caseDirection = directionSign == 0
          ? (secondaryUnit >= 0.5 ? 1.0 : -1.0)
          : (shouldAlign ? directionSign : -directionSign);

      final magnitude = magnitudeBase * (0.45 + (secondaryUnit * 1.35));
      final noise = (tertiaryUnit - 0.5) * magnitudeBase * 0.45;
      final forwardReturn = (caseDirection * magnitude) + noise;

      final favorable = math.max(
        0.15,
        forwardReturn > 0
            ? forwardReturn + (magnitudeBase * (0.25 + secondaryUnit * 0.4))
            : magnitudeBase * (0.20 + secondaryUnit * 0.35),
      );
      final adverseMagnitude = math.max(
        0.10,
        forwardReturn < 0
            ? forwardReturn.abs() +
                  (magnitudeBase * (0.20 + tertiaryUnit * 0.35))
            : magnitudeBase * (0.16 + tertiaryUnit * 0.30),
      );

      final caseSymbol = index % 3 == 0
          ? normalizedSymbol
          : peers[index % peers.length];

      return HistoricalSetupCase(
        symbol: caseSymbol,
        occurredAt: DateTime.utc(
          2025,
          12,
          31,
        ).subtract(Duration(days: 5 + (index * 6))),
        fingerprint: _jitterSetupFingerprint(
          currentFingerprint,
          seedPrefix: '$normalizedSymbol|$primaryTimeframe|fingerprint|$index',
          index: index,
        ),
        forwardReturnPercent: forwardReturn,
        maxFavorableExcursionPercent: favorable,
        maxAdverseExcursionPercent: -adverseMagnitude,
      );
    }, growable: false);

    final comparisonObservations =
        List<HistoricalComparisonObservation>.generate(comparisonCount, (
          index,
        ) {
          final unit = _unit(
            '$normalizedSymbol|$primaryTimeframe|comparison|$index',
          );
          final secondary = _unit(
            '$normalizedSymbol|$primaryTimeframe|comparison2|$index',
          );
          final drift = _comparisonDriftForSymbol(normalizedSymbol);
          final forwardReturn =
              drift +
              ((unit - 0.5) * magnitudeBase * 1.6) +
              ((secondary - 0.5) * magnitudeBase * 0.35);

          return HistoricalComparisonObservation(
            symbol: normalizedSymbol,
            occurredAt: DateTime.utc(
              2025,
              12,
              31,
            ).subtract(Duration(days: 2 + (index * 3))),
            fingerprint: _comparisonFingerprint(
              currentFingerprint,
              seedPrefix:
                  '$normalizedSymbol|$primaryTimeframe|comparisonFp|$index',
              index: index,
            ),
            forwardReturnPercent: forwardReturn,
          );
        }, growable: false);

    return HistoricalSetupDataset(
      cases: List<HistoricalSetupCase>.unmodifiable(cases),
      comparisonObservations:
          List<HistoricalComparisonObservation>.unmodifiable(
            comparisonObservations,
          ),
      isSynthetic: true,
      sourceLabel: 'Development simulation',
    );
  }

  HistoricalSetupFingerprint _jitterSetupFingerprint(
    HistoricalSetupFingerprint current, {
    required String seedPrefix,
    required int index,
  }) {
    final directions = <EvidenceFamily, double>{};
    final strengths = <EvidenceFamily, double>{};

    for (final family in current.familyDirectionScores.keys) {
      final directionNoise =
          (_unit('$seedPrefix|dir|${family.name}') - 0.5) *
          (index % 7 == 0 ? 105 : 48);
      final strengthNoise =
          (_unit('$seedPrefix|strength|${family.name}') - 0.5) *
          (index % 7 == 0 ? 55 : 28);

      directions[family] = (current.directionScoreFor(family) + directionNoise)
          .clamp(-100.0, 100.0);
      strengths[family] = (current.strengthScoreFor(family) + strengthNoise)
          .clamp(0.0, 100.0);
    }

    return HistoricalSetupFingerprint(
      strategy: current.strategy,
      primaryTimeframe: current.primaryTimeframe,
      // Most generated setup candidates share the current Stock Profile. A
      // minority intentionally do not so tests and the matcher exercise the
      // hard profile gate instead of relying on friendly mock data.
      stockBehaviorType: index % 11 == 0
          ? _differentBehaviorType(current.stockBehaviorType)
          : current.stockBehaviorType,
      volatilityRegime: _maybeChangeVolatilityRegime(
        current.volatilityRegime,
        _unit('$seedPrefix|volatility'),
        index,
      ),
      marketBackdrop: _maybeChangeBackdrop(
        current.marketBackdrop,
        _unit('$seedPrefix|backdrop'),
        index,
      ),
      relativeStrengthState: _maybeChangeRelativeStrength(
        current.relativeStrengthState,
        _unit('$seedPrefix|relativeStrength'),
        index,
      ),
      familyDirectionScores: directions,
      familyStrengthScores: strengths,
      familyImportanceWeights: current.familyImportanceWeights,
    );
  }

  HistoricalSetupFingerprint _comparisonFingerprint(
    HistoricalSetupFingerprint current, {
    required String seedPrefix,
    required int index,
  }) {
    final directions = <EvidenceFamily, double>{};
    final strengths = <EvidenceFamily, double>{};

    // The comparison group deliberately does NOT copy today's evidence
    // pattern. Its purpose is to represent the current stock's usual behavior
    // under comparable surrounding conditions, not another set of setup
    // matches.
    for (final family in current.familyDirectionScores.keys) {
      directions[family] =
          ((_unit('$seedPrefix|dir|${family.name}') * 200) - 100).clamp(
            -100.0,
            100.0,
          );
      strengths[family] =
          (20 + (_unit('$seedPrefix|strength|${family.name}') * 75)).clamp(
            0.0,
            100.0,
          );
    }

    return HistoricalSetupFingerprint(
      strategy: current.strategy,
      primaryTimeframe: current.primaryTimeframe,
      stockBehaviorType: index % 13 == 0
          ? _differentBehaviorType(current.stockBehaviorType)
          : current.stockBehaviorType,
      volatilityRegime: index % 5 == 0
          ? _differentVolatilityRegime(current.volatilityRegime)
          : current.volatilityRegime,
      marketBackdrop: index % 6 == 0
          ? _differentBackdrop(current.marketBackdrop)
          : current.marketBackdrop,
      relativeStrengthState: _maybeChangeRelativeStrength(
        current.relativeStrengthState,
        _unit('$seedPrefix|relativeStrength'),
        index,
      ),
      familyDirectionScores: directions,
      familyStrengthScores: strengths,
      familyImportanceWeights: current.familyImportanceWeights,
    );
  }

  StockBehaviorType _differentBehaviorType(StockBehaviorType current) {
    return switch (current) {
      StockBehaviorType.steady => StockBehaviorType.balanced,
      StockBehaviorType.balanced => StockBehaviorType.volatile,
      StockBehaviorType.volatile => StockBehaviorType.balanced,
      StockBehaviorType.unknown => StockBehaviorType.balanced,
    };
  }

  VolatilityRegime _differentVolatilityRegime(VolatilityRegime current) {
    return switch (current) {
      VolatilityRegime.calm => VolatilityRegime.normal,
      VolatilityRegime.normal => VolatilityRegime.elevated,
      VolatilityRegime.elevated => VolatilityRegime.normal,
      VolatilityRegime.unknown => VolatilityRegime.normal,
    };
  }

  MarketBackdrop _differentBackdrop(MarketBackdrop current) {
    return switch (current) {
      MarketBackdrop.supportive => MarketBackdrop.neutral,
      MarketBackdrop.neutral => MarketBackdrop.challenging,
      MarketBackdrop.challenging => MarketBackdrop.neutral,
      MarketBackdrop.unknown => MarketBackdrop.neutral,
    };
  }

  VolatilityRegime _maybeChangeVolatilityRegime(
    VolatilityRegime current,
    double unit,
    int index,
  ) {
    if (index % 6 != 0 || unit > 0.70) {
      return current;
    }
    return _differentVolatilityRegime(current);
  }

  MarketBackdrop _maybeChangeBackdrop(
    MarketBackdrop current,
    double unit,
    int index,
  ) {
    if (index % 8 != 0 || unit > 0.70) {
      return current;
    }
    return _differentBackdrop(current);
  }

  RelativeStrengthState _maybeChangeRelativeStrength(
    RelativeStrengthState current,
    double unit,
    int index,
  ) {
    if (index % 9 != 0 || unit > 0.70) {
      return current;
    }

    return switch (current) {
      RelativeStrengthState.outperforming => RelativeStrengthState.inLine,
      RelativeStrengthState.inLine =>
        unit < 0.35
            ? RelativeStrengthState.outperforming
            : RelativeStrengthState.underperforming,
      RelativeStrengthState.underperforming => RelativeStrengthState.inLine,
      RelativeStrengthState.unknown => RelativeStrengthState.inLine,
    };
  }

  double _currentDirectionSign(HistoricalSetupFingerprint fingerprint) {
    if (fingerprint.familyDirectionScores.isEmpty) {
      return 0;
    }

    double weighted = 0;
    double totalWeight = 0;

    for (final entry in fingerprint.familyDirectionScores.entries) {
      final weight = fingerprint.importanceFor(entry.key) > 0
          ? fingerprint.importanceFor(entry.key)
          : 1 / fingerprint.familyDirectionScores.length;
      weighted += entry.value * weight;
      totalWeight += weight;
    }

    if (totalWeight == 0) {
      return 0;
    }

    final score = weighted / totalWeight;
    if (score > 5) {
      return 1;
    }
    if (score < -5) {
      return -1;
    }
    return 0;
  }

  double _alignmentBiasForSymbol(String symbol) {
    return switch (symbol) {
      'NVDA' => 0.76,
      'MSFT' => 0.67,
      'AAPL' => 0.64,
      'TSLA' => 0.69,
      'AMD' => 0.63,
      'PLTR' => 0.52,
      'GOOG' => 0.46,
      _ => 0.57 + ((_stableHash(symbol) % 13) / 100),
    };
  }

  double _comparisonDriftForSymbol(String symbol) {
    return switch (symbol) {
      'NVDA' => 0.20,
      'MSFT' => 0.12,
      'AAPL' => 0.10,
      'TSLA' => 0.02,
      'PLTR' => 0.08,
      'GOOG' => 0.06,
      _ => 0.05,
    };
  }

  double _moveMagnitudeFor(HistoricalSetupFingerprint fingerprint) {
    final behaviorMagnitude = switch (fingerprint.stockBehaviorType) {
      StockBehaviorType.steady => 0.75,
      StockBehaviorType.balanced => 1.25,
      StockBehaviorType.volatile => 2.10,
      StockBehaviorType.unknown => 1.10,
    };

    final volatilityMultiplier = switch (fingerprint.volatilityRegime) {
      VolatilityRegime.calm => 0.75,
      VolatilityRegime.normal => 1.0,
      VolatilityRegime.elevated => 1.35,
      VolatilityRegime.unknown => 1.0,
    };

    return behaviorMagnitude * volatilityMultiplier;
  }

  List<String> _peerSymbols(String symbol, StockBehaviorType behaviorType) {
    final peers = switch (behaviorType) {
      StockBehaviorType.steady => <String>['AAPL', 'MSFT', 'KO', 'JNJ', 'PG'],
      StockBehaviorType.balanced => <String>['GOOG', 'META', 'AMZN', 'AMD'],
      StockBehaviorType.volatile => <String>[
        'NVDA',
        'TSLA',
        'PLTR',
        'AMD',
        'COIN',
      ],
      StockBehaviorType.unknown => <String>['AAPL', 'MSFT', 'NVDA', 'GOOG'],
    };

    final filtered = peers.where((item) => item != symbol).toList();
    return filtered.isEmpty ? peers : filtered;
  }

  double _unit(String value) {
    final hash = _stableHash(value);
    final mixed = ((hash * 1103515245) + 12345) & 0x7fffffff;
    return mixed / 0x7fffffff;
  }

  int _stableHash(String value) {
    var hash = 17;
    for (final codeUnit in value.codeUnits) {
      hash = 37 * hash + codeUnit;
      hash &= 0x7fffffff;
    }
    return hash;
  }
}
