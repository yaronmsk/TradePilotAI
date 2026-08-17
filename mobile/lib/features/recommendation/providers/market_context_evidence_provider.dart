import '../context/market_context_profile.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';

class MarketContextEvidenceProvider {
  const MarketContextEvidenceProvider();

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    kind: EvidenceKind.marketContext,
    family: EvidenceFamily.marketContext,
    name: 'Market & Sector Context',
    description:
        'Measures whether the stock is receiving a market/sector tailwind and whether it is outperforming or underperforming those benchmarks.',
    whyItMatters:
        'A stock does not trade in isolation. Relative strength can distinguish stock-specific leadership from a move that merely follows the broader market.',
    calculation:
        'TradePilot compares the stock with the broad-market and sector benchmarks on the Trader confirmation and regime timeframes. Stock-vs-market and stock-vs-sector relative performance receive the most weight; sector leadership and broad-market direction contribute smaller context weights.',
  );

  EvidenceResult evaluate(MarketContextProfile profile) {
    if (!profile.hasSufficientData) {
      return EvidenceResult(
        providerName: kDefinition.name,
        definition: kDefinition,
        status: EvidenceStatus.insufficientData,
        direction: EvidenceDirection.unknown,
        strength: EvidenceStrength.veryWeak,
        score: 0,
        baseWeight: 0.85,
        dynamicWeight: 1,
        reliability: 0,
        currentValue: 'Unavailable',
        baselineValue: profile.target.marketSymbol,
        relativeValue: 'Benchmark context unavailable',
        explanation:
            'Market and sector context could not be calculated from the available benchmark data.',
        unavailableReason: 'Benchmark snapshots are unavailable.',
      );
    }

    final score = profile.directionScore.abs().clamp(0.0, 100.0);
    final direction = profile.directionScore > 8
        ? EvidenceDirection.bullish
        : profile.directionScore < -8
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    return EvidenceResult(
      providerName: kDefinition.name,
      definition: kDefinition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: _strength(score),
      score: score,
      baseWeight: 0.85,
      dynamicWeight: 1,
      reliability: profile.reliability,
      currentValue: _relativeStrengthLabel(profile.relativeStrength),
      baselineValue: profile.target.hasSectorBenchmark
          ? '${profile.target.marketSymbol} + ${profile.target.sectorSymbol}'
          : profile.target.marketSymbol,
      relativeValue: profile.target.hasSectorBenchmark
          ? 'vs market ${_signed(profile.stockVsMarketPercent)} pp • vs sector ${_signed(profile.stockVsSectorPercent)} pp'
          : 'vs market ${_signed(profile.stockVsMarketPercent)} pp',
      explanation:
          'The broader backdrop is ${_backdropLabel(profile.backdrop).toLowerCase()}. '
          'The stock is ${_relativeStrengthLabel(profile.relativeStrength).toLowerCase()} relative to its benchmarks. '
          '${profile.target.hasSectorBenchmark ? '${profile.target.sectorName} is compared with ${profile.target.marketSymbol} as an additional independent context check.' : 'A dedicated sector benchmark is not available for this symbol, so reliability is reduced.'}',
    );
  }

  EvidenceStrength _strength(double score) {
    if (score >= 80) {
      return EvidenceStrength.exceptional;
    }
    if (score >= 60) {
      return EvidenceStrength.strong;
    }
    if (score >= 35) {
      return EvidenceStrength.moderate;
    }
    if (score >= 15) {
      return EvidenceStrength.weak;
    }
    return EvidenceStrength.veryWeak;
  }

  String _relativeStrengthLabel(RelativeStrengthState state) {
    switch (state) {
      case RelativeStrengthState.outperforming:
        return 'Outperforming';
      case RelativeStrengthState.inLine:
        return 'In Line';
      case RelativeStrengthState.underperforming:
        return 'Underperforming';
      case RelativeStrengthState.unknown:
        return 'Unknown';
    }
  }

  String _backdropLabel(MarketBackdrop backdrop) {
    switch (backdrop) {
      case MarketBackdrop.supportive:
        return 'Supportive';
      case MarketBackdrop.neutral:
        return 'Neutral';
      case MarketBackdrop.challenging:
        return 'Challenging';
      case MarketBackdrop.unknown:
        return 'Unknown';
    }
  }

  String _signed(double value) {
    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(1)}';
  }
}
