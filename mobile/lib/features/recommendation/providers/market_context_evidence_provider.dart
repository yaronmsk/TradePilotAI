import '../context/market_context_profile.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';
import '../models/strategy_summary.dart';
import '../strategy/market_context_strategy_policy.dart';

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
        'TradePilot compares the stock with broad-market and sector benchmarks over strategy-specific confirmation and regime horizons. Relative stock leadership receives most of the context weight, while sector leadership and broad-market direction remain smaller supporting inputs.',
  );

  EvidenceResult evaluate(
    MarketContextProfile profile, {
    StrategyType strategy = StrategyType.trader,
  }) {
    final policy = MarketContextStrategyPolicy.forStrategy(strategy);

    if (policy == null) {
      return _unavailable(
        profile,
        'Market & Sector Context has not been calibrated for Investor yet.',
      );
    }

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

    final hasConflict =
        strategy == StrategyType.swing && profile.hasContextConflict;

    final directionThreshold = hasConflict
        ? policy.conflictDirectionThreshold
        : policy.directionThreshold;

    final direction = profile.directionScore > directionThreshold
        ? EvidenceDirection.bullish
        : profile.directionScore < -directionThreshold
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    final dynamicWeight = hasConflict ? policy.conflictDynamicWeight : 1.0;

    return EvidenceResult(
      providerName: kDefinition.name,
      definition: kDefinition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: _strength(score),
      score: score,
      baseWeight: policy.providerBaseWeight,
      dynamicWeight: dynamicWeight,
      reliability: profile.reliability,
      currentValue: _relativeStrengthLabel(profile.relativeStrength),
      baselineValue: profile.target.hasSectorBenchmark
          ? '${profile.target.marketSymbol} + ${profile.target.sectorSymbol}'
          : profile.target.marketSymbol,
      relativeValue: profile.target.hasSectorBenchmark
          ? 'vs market ${_signed(profile.stockVsMarketPercent)} pp • vs sector ${_signed(profile.stockVsSectorPercent)} pp'
          : 'vs market ${_signed(profile.stockVsMarketPercent)} pp',
      explanation:
          '${strategy == StrategyType.swing ? 'Swing context uses the approved confirmation and regime horizons. ' : ''}'
          'The broader backdrop is ${_backdropLabel(profile.backdrop).toLowerCase()}. '
          'The stock is ${_relativeStrengthLabel(profile.relativeStrength).toLowerCase()} relative to its benchmarks. '
          '${hasConflict ? 'Stock relative strength and the broader backdrop conflict, so Market Context influence is deliberately reduced rather than forcing certainty. ' : ''}'
          '${profile.target.hasSectorBenchmark ? '${profile.target.sectorName} provides a sector-relative comparison alongside ${profile.target.marketSymbol}.' : 'A dedicated sector benchmark is unavailable, so Swing does not manufacture a second independent relative-strength comparison and reliability is reduced.'}',
    );
  }

  EvidenceResult _unavailable(MarketContextProfile profile, String reason) {
    return EvidenceResult(
      providerName: kDefinition.name,
      definition: kDefinition,
      status: EvidenceStatus.unavailable,
      direction: EvidenceDirection.unknown,
      strength: EvidenceStrength.veryWeak,
      score: 0,
      baseWeight: 0.85,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Unavailable',
      baselineValue: profile.target.marketSymbol,
      relativeValue: 'Strategy context unavailable',
      explanation: reason,
      unavailableReason: reason,
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
