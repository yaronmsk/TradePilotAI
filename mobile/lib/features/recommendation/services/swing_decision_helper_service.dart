import '../models/evidence_kind.dart';
import '../models/evidence_result.dart';
import '../models/metric_explainability.dart';
import '../models/recommendation.dart';
import '../models/strategy_recommendation.dart';
import '../models/strategy_summary.dart';
import '../models/swing_decision_helper.dart';

class SwingDecisionHelperService {
  const SwingDecisionHelperService();

  static const _entryQualityExplainability = MetricExplainability(
    semanticRole: MetricSemanticRole.confidenceRiskOnly,
    whatItIs:
        'A plain-language summary of whether the current Swing setup looks comfortable to enter now, deserves extra care, or should be avoided until conditions improve.',
    calculation:
        'Uses only the already-calculated Swing Price Extension and Support & Resistance results plus whether the current recommendation is an active BUY/SELL. Extended price or confirmed opposing structure produces Caution; elevated stretch or unresolved nearby structure produces Watch; normal stretch with non-opposing structure can be Favorable. HOLD/WAIT remains Wait.',
    whyItMatters:
        'Direction and entry timing are different questions. A valid Swing trend can still offer a poor new entry when price is stretched or sitting at an unresolved structural level.',
    neutralInterpretation:
        'Wait or Not enough data means the current analysis does not justify a fresh directional entry-quality conclusion.',
    recommendationImpact:
        'This helper is presentation-only. It summarizes evidence that has already been processed by the recommendation engine and does not recalculate direction or confidence.',
    limitations:
        'Entry quality is not a profit probability, target, stop-loss recommendation, or guarantee that waiting will improve the setup. It depends on the currently available Swing evidence.',
    boundedImpact:
        'The helper itself adds exactly 0 direction points and 0 confidence points. It cannot create, flip, strengthen, or weaken a recommendation.',
  );

  static const _priceStretchExplainability = MetricExplainability(
    semanticRole: MetricSemanticRole.confidenceRiskOnly,
    whatItIs:
        'Shows whether price is trading a normal or unusually stretched distance from the Swing equilibrium reference after adjusting for volatility.',
    calculation:
        'Reads the existing Swing Price Extension evidence and translates its already-calculated quality band into Normal, Elevated, Extended, or Very extended. The helper does not recompute EMA, ATR, or evidence weight.',
    whyItMatters:
        'A strong directional setup can remain valid while the current price becomes a worse place to chase a new position.',
    neutralInterpretation:
        'Normal means price extension is not currently a material entry-quality concern. Elevated or extended conditions call for more entry caution without claiming a reversal.',
    recommendationImpact:
        'This row only surfaces the existing Swing Price Extension interpretation. Any confidence or risk effect was already handled upstream; the helper adds no new effect.',
    limitations:
        'Strong trends can remain extended for long periods. Stretch does not prove that price will reverse or mean-revert.',
    boundedImpact:
        'The helper adds 0 direction points and 0 confidence points. Under the Swing policy, Price Extension itself also has exactly zero directional influence.',
  );

  static const _structureWatchExplainability = MetricExplainability(
    semanticRole: MetricSemanticRole.directionalEvaluative,
    whatItIs:
        'Summarizes whether Swing price structure is confirmed bullish, confirmed bearish, close to an unresolved key level, or trading between active support and resistance.',
    calculation:
        'Reads the already-calculated Swing Support & Resistance evidence. Confirmed bullish/bearish structure comes from its existing directional result; a weak neutral result is shown as Near key level; other neutral structure is shown as Between key levels.',
    whyItMatters:
        'Confirmed breakouts, breakdowns, and rejections can matter directionally, while simple proximity to support or resistance mainly affects entry timing and risk.',
    supportiveInterpretation:
        'Confirmed structure in the same direction as the active setup supports that setup through the existing Price Structure evidence family.',
    opposingInterpretation:
        'Confirmed structure against the active setup opposes it through the existing Price Structure evidence family.',
    neutralInterpretation:
        'Near key level or Between key levels does not create a new bullish or bearish vote. Proximity alone remains directionally neutral for Swing.',
    recommendationImpact:
        'This helper does not add another Price Structure vote. It only presents the Support & Resistance result that the Consensus Engine has already counted and de-duplicated.',
    limitations:
        'Support and resistance are local structural references rather than guaranteed barriers. News, gaps, or volatility can invalidate levels quickly.',
  );

  SwingDecisionHelperSummary? build(
    StrategyRecommendation strategyRecommendation,
  ) {
    if (strategyRecommendation.strategy != StrategyType.swing) {
      return null;
    }

    final recommendation = strategyRecommendation.recommendation;
    final extension = _findEvidence(
      recommendation,
      EvidenceKind.priceExtension,
    );
    final structure = _findEvidence(
      recommendation,
      EvidenceKind.supportResistance,
    );

    return SwingDecisionHelperSummary(
      entryQuality: _entryQualityMetric(
        recommendation,
        extension: extension,
        structure: structure,
      ),
      priceStretch: _priceStretchMetric(extension),
      structureWatch: _structureWatchMetric(structure),
    );
  }

  EvidenceResult? _findEvidence(
    Recommendation recommendation,
    EvidenceKind kind,
  ) {
    for (final result in recommendation.evidenceReport.results) {
      if (result.definition.kind == kind && result.isAvailable) {
        return result;
      }
    }

    return null;
  }

  SwingDecisionHelperMetric _entryQualityMetric(
    Recommendation recommendation, {
    required EvidenceResult? extension,
    required EvidenceResult? structure,
  }) {
    final activeDirection = _activeDirection(recommendation.type);

    if (activeDirection == null) {
      return const SwingDecisionHelperMetric(
        label: 'Entry Quality',
        value: 'Wait',
        detail: 'No active BUY/SELL entry is currently recommended.',
        explainability: _entryQualityExplainability,
      );
    }

    if (extension == null && structure == null) {
      return const SwingDecisionHelperMetric(
        label: 'Entry Quality',
        value: 'Not enough data',
        detail: 'Price stretch and structure evidence are both unavailable.',
        explainability: _entryQualityExplainability,
      );
    }

    final stretch = _stretchState(extension);
    final structureState = _structureState(structure, activeDirection);
    final side = activeDirection == EvidenceDirection.bullish
        ? 'long'
        : 'short';

    if (stretch == _StretchState.veryExtended ||
        stretch == _StretchState.extended) {
      return SwingDecisionHelperMetric(
        label: 'Entry Quality',
        value: 'Caution',
        detail:
            'Price is ${_stretchLabel(stretch).toLowerCase()}, so chasing a new $side entry carries worse timing risk.',
        explainability: _entryQualityExplainability,
      );
    }

    if (structureState == _StructureState.opposing) {
      return SwingDecisionHelperMetric(
        label: 'Entry Quality',
        value: 'Caution',
        detail:
            'Confirmed price structure currently points against the active $side setup.',
        explainability: _entryQualityExplainability,
      );
    }

    if (stretch == _StretchState.elevated ||
        structureState == _StructureState.nearLevel) {
      return SwingDecisionHelperMetric(
        label: 'Entry Quality',
        value: 'Watch',
        detail: structureState == _StructureState.nearLevel
            ? 'Price is close to a key structural level, so confirmation matters before a new $side entry.'
            : 'Price is somewhat stretched, so entry timing deserves extra care.',
        explainability: _entryQualityExplainability,
      );
    }

    if (stretch == _StretchState.unavailable ||
        structureState == _StructureState.unavailable) {
      return const SwingDecisionHelperMetric(
        label: 'Entry Quality',
        value: 'Watch',
        detail:
            'One of the key entry-timing inputs is unavailable, so entry quality is only partially confirmed.',
        explainability: _entryQualityExplainability,
      );
    }

    final structureDetail = structureState == _StructureState.aligned
        ? 'confirmed structure supports the active setup'
        : 'price is between the active structure levels';

    return SwingDecisionHelperMetric(
      label: 'Entry Quality',
      value: 'Favorable',
      detail: 'Price stretch is normal and $structureDetail.',
      explainability: _entryQualityExplainability,
    );
  }

  SwingDecisionHelperMetric _priceStretchMetric(EvidenceResult? result) {
    if (result == null) {
      return const SwingDecisionHelperMetric(
        label: 'Price Stretch',
        value: 'Not enough data',
        detail: 'Swing Price Extension is unavailable for this analysis.',
        explainability: _priceStretchExplainability,
      );
    }

    final stretch = _stretchState(result);

    return SwingDecisionHelperMetric(
      label: 'Price Stretch',
      value: _stretchLabel(stretch),
      detail: 'Current stretch: ${result.currentValue}.',
      explainability: _priceStretchExplainability,
    );
  }

  SwingDecisionHelperMetric _structureWatchMetric(EvidenceResult? result) {
    if (result == null) {
      return const SwingDecisionHelperMetric(
        label: 'Structure Watch',
        value: 'Not enough data',
        detail: 'Swing Support & Resistance is unavailable for this analysis.',
        explainability: _structureWatchExplainability,
      );
    }

    switch (result.direction) {
      case EvidenceDirection.bullish:
        return const SwingDecisionHelperMetric(
          label: 'Structure Watch',
          value: 'Bullish structure confirmed',
          detail:
              'A confirmed breakout or support rejection is already present in Price Structure evidence.',
          explainability: _structureWatchExplainability,
        );
      case EvidenceDirection.bearish:
        return const SwingDecisionHelperMetric(
          label: 'Structure Watch',
          value: 'Bearish structure confirmed',
          detail:
              'A confirmed breakdown or resistance rejection is already present in Price Structure evidence.',
          explainability: _structureWatchExplainability,
        );
      case EvidenceDirection.neutral:
        if (result.strength == EvidenceStrength.weak) {
          return const SwingDecisionHelperMetric(
            label: 'Structure Watch',
            value: 'Near key level',
            detail:
                'Price is close to support or resistance; proximity alone remains directionally neutral.',
            explainability: _structureWatchExplainability,
          );
        }

        return const SwingDecisionHelperMetric(
          label: 'Structure Watch',
          value: 'Between key levels',
          detail:
              'Price is between the active Swing support and resistance levels without a confirmed structural event.',
          explainability: _structureWatchExplainability,
        );
      case EvidenceDirection.unknown:
        return const SwingDecisionHelperMetric(
          label: 'Structure Watch',
          value: 'Not enough data',
          detail: 'Current structure does not have a usable interpretation.',
          explainability: _structureWatchExplainability,
        );
    }
  }

  EvidenceDirection? _activeDirection(RecommendationType type) {
    switch (type) {
      case RecommendationType.strongBuy:
      case RecommendationType.buy:
        return EvidenceDirection.bullish;
      case RecommendationType.strongSell:
      case RecommendationType.sell:
        return EvidenceDirection.bearish;
      case RecommendationType.hold:
      case RecommendationType.wait:
      case RecommendationType.unknown:
        return null;
    }
  }

  _StretchState _stretchState(EvidenceResult? result) {
    if (result == null) {
      return _StretchState.unavailable;
    }

    if (result.strength == EvidenceStrength.veryWeak || result.score < 40) {
      return _StretchState.veryExtended;
    }

    if (result.strength == EvidenceStrength.weak || result.score < 55) {
      return _StretchState.extended;
    }

    if (result.score < 70) {
      return _StretchState.elevated;
    }

    return _StretchState.normal;
  }

  _StructureState _structureState(
    EvidenceResult? result,
    EvidenceDirection activeDirection,
  ) {
    if (result == null || result.direction == EvidenceDirection.unknown) {
      return _StructureState.unavailable;
    }

    if (result.direction == EvidenceDirection.neutral) {
      return result.strength == EvidenceStrength.weak
          ? _StructureState.nearLevel
          : _StructureState.betweenLevels;
    }

    return result.direction == activeDirection
        ? _StructureState.aligned
        : _StructureState.opposing;
  }

  String _stretchLabel(_StretchState state) {
    switch (state) {
      case _StretchState.normal:
        return 'Normal';
      case _StretchState.elevated:
        return 'Elevated';
      case _StretchState.extended:
        return 'Extended';
      case _StretchState.veryExtended:
        return 'Very extended';
      case _StretchState.unavailable:
        return 'Not enough data';
    }
  }
}

enum _StretchState { normal, elevated, extended, veryExtended, unavailable }

enum _StructureState {
  aligned,
  opposing,
  nearLevel,
  betweenLevels,
  unavailable,
}
