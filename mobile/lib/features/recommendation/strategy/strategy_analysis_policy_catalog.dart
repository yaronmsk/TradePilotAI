import '../models/evidence_family.dart';
import '../models/evidence_kind.dart';
import '../models/strategy_summary.dart';
import 'strategy_analysis_policy.dart';
import 'strategy_evidence_policy.dart';

class StrategyAnalysisPolicyCatalog {
  StrategyAnalysisPolicyCatalog._();

  static final StrategyAnalysisPolicy trader = StrategyAnalysisPolicy(
    strategy: StrategyType.trader,
    status: StrategyAnalysisPolicyStatus.active,
    evidencePolicies: Map.unmodifiable(
      _productionPolicies(
        strategy: StrategyType.trader,
        builder: (kind) => _entry(
          strategy: StrategyType.trader,
          kind: kind,
          applicability: StrategyEvidenceApplicability.reuseCurrentBehavior,
          implementationReady: true,
          affectsDirection: true,
          affectsConfidence: true,
          affectsRiskOrEntryQuality:
              kind == EvidenceKind.priceExtension ||
              kind == EvidenceKind.supportResistance,
          rationale:
              'Preserves the validated v0.10.1 Trader behavior while the '
              'strategy-policy architecture is introduced.',
        ),
      ),
    ),
  );

  static final StrategyAnalysisPolicy swing = StrategyAnalysisPolicy(
    strategy: StrategyType.swing,
    status: StrategyAnalysisPolicyStatus.scopeApproved,
    evidencePolicies: Map.unmodifiable({
      EvidenceKind.candleTrend: _entry(
        strategy: StrategyType.swing,
        kind: EvidenceKind.candleTrend,
        applicability: StrategyEvidenceApplicability.recalibrateForStrategy,
        implementationReady: true,
        affectsDirection: true,
        affectsConfidence: true,
        affectsRiskOrEntryQuality: false,
        rationale:
            'Persistent multi-session price direction is important for Swing, '
            'but the current Trader-oriented movement assumptions cannot be '
            'reused unchanged.',
        calibrationNotes:
            'Use a Swing-specific lookback and volatility-aware or '
            'stock-context-aware trend-strength interpretation.',
      ),
      EvidenceKind.rsi: _entry(
        strategy: StrategyType.swing,
        kind: EvidenceKind.rsi,
        applicability: StrategyEvidenceApplicability.recalibrateForStrategy,
        implementationReady: true,
        affectsDirection: true,
        affectsConfidence: true,
        affectsRiskOrEntryQuality: true,
        rationale:
            'RSI is useful for Swing momentum and stretch, but overbought and '
            'oversold levels must not automatically imply reversal.',
        calibrationNotes:
            'Make RSI trend/regime-aware so it can distinguish momentum '
            'confirmation, pullback quality, deterioration and excessive '
            'stretch without using a simplistic 70=SELL / 30=BUY rule.',
      ),
      EvidenceKind.relativeVolume: _entry(
        strategy: StrategyType.swing,
        kind: EvidenceKind.relativeVolume,
        applicability: StrategyEvidenceApplicability.conditionalOnDataQuality,
        implementationReady: true,
        affectsDirection: true,
        affectsConfidence: true,
        affectsRiskOrEntryQuality: false,
        rationale:
            'Relative participation can confirm meaningful Swing moves, but '
            'the comparison must be appropriate for the selected timeframe.',
        calibrationNotes:
            'Daily Swing may compare daily volume with daily history. 4H '
            'Swing must use comparable-session normalization or reduce/'
            'withhold the signal.',
        dataQualityRequirement:
            'Do not fabricate same-time-of-day 4H volume normalization when '
            'matching intraday history is unavailable.',
      ),
      EvidenceKind.emaStructure: _entry(
        strategy: StrategyType.swing,
        kind: EvidenceKind.emaStructure,
        applicability: StrategyEvidenceApplicability.recalibrateForStrategy,
        implementationReady: true,
        affectsDirection: true,
        affectsConfidence: true,
        affectsRiskOrEntryQuality: false,
        rationale:
            'Moving-average structure is useful for intermediate Swing trend '
            'assessment but requires Swing-appropriate periods.',
        calibrationNotes:
            'Move EMA periods and structure-strength thresholds behind the '
            'Swing strategy policy rather than inheriting Trader constants.',
      ),
      EvidenceKind.macdMomentum: _entry(
        strategy: StrategyType.swing,
        kind: EvidenceKind.macdMomentum,
        applicability: StrategyEvidenceApplicability.recalibrateForStrategy,
        implementationReady: true,
        affectsDirection: true,
        affectsConfidence: true,
        affectsRiskOrEntryQuality: false,
        rationale:
            'MACD is useful for multi-session trend momentum and transition.',
        calibrationNotes:
            'Audit Swing periods and interpretation using MACD line, signal '
            'line, zero-line context and momentum transition rather than '
            'histogram magnitude alone.',
      ),
      EvidenceKind.vwapPosition: _entry(
        strategy: StrategyType.swing,
        kind: EvidenceKind.vwapPosition,
        applicability: StrategyEvidenceApplicability.excluded,
        affectsDirection: false,
        affectsConfidence: false,
        affectsRiskOrEntryQuality: false,
        rationale:
            'The current analysis-window VWAP implementation is oriented to '
            'intraday/session analysis and is not semantically valid as '
            'initial Swing evidence.',
      ),
      EvidenceKind.supportResistance: _entry(
        strategy: StrategyType.swing,
        kind: EvidenceKind.supportResistance,
        applicability: StrategyEvidenceApplicability.recalibrateForStrategy,
        implementationReady: true,
        affectsDirection: true,
        affectsConfidence: true,
        affectsRiskOrEntryQuality: true,
        rationale:
            'Structural levels are important to Swing entries, exits and '
            'breakout/breakdown interpretation.',
        calibrationNotes:
            'Use Swing-appropriate structure lookbacks and confirmation-aware '
            'semantics. Proximity alone must not create bullish or bearish '
            'direction.',
      ),
      EvidenceKind.volumeConfirmation: _entry(
        strategy: StrategyType.swing,
        kind: EvidenceKind.volumeConfirmation,
        applicability: StrategyEvidenceApplicability.recalibrateForStrategy,
        implementationReady: true,
        affectsDirection: true,
        affectsConfidence: true,
        affectsRiskOrEntryQuality: false,
        rationale:
            'Volume expansion or contraction can confirm or weaken multi-day '
            'price moves.',
        calibrationNotes:
            'Replace universal small price-move thresholds with '
            'volatility-aware Swing move significance while preserving the '
            'Participation family cap.',
      ),
      EvidenceKind.priceExtension: _entry(
        strategy: StrategyType.swing,
        kind: EvidenceKind.priceExtension,
        applicability: StrategyEvidenceApplicability.recalibrateForStrategy,
        implementationReady: true,
        affectsDirection: false,
        affectsConfidence: true,
        affectsRiskOrEntryQuality: true,
        rationale:
            'A strong Swing trend can remain directionally valid while price '
            'is too extended to provide a good new entry.',
        calibrationNotes:
            'Use extension primarily to describe entry quality, stretch and '
            'risk. It must not independently claim that the opposite trend '
            'has begun.',
      ),
      EvidenceKind.multiTimeframeTrend: _entry(
        strategy: StrategyType.swing,
        kind: EvidenceKind.multiTimeframeTrend,
        applicability: StrategyEvidenceApplicability.recalibrateForStrategy,
        implementationReady: true,
        affectsDirection: true,
        affectsConfidence: true,
        affectsRiskOrEntryQuality: false,
        rationale:
            'Agreement between primary, confirmation and regime timeframes is '
            'core Swing evidence.',
        calibrationNotes:
            'Use the approved 1D->1W->1M default and 4H->1D->1W alternate '
            'hierarchies with Swing-specific timeframe-role weighting.',
      ),
      EvidenceKind.marketContext: _entry(
        strategy: StrategyType.swing,
        kind: EvidenceKind.marketContext,
        applicability: StrategyEvidenceApplicability.recalibrateForStrategy,
        implementationReady: true,
        affectsDirection: true,
        affectsConfidence: true,
        affectsRiskOrEntryQuality: false,
        rationale:
            'Market regime, sector behavior and relative strength can '
            'materially influence a days-to-weeks setup.',
        calibrationNotes:
            'Use Swing-relevant stock-vs-market and stock-vs-sector '
            'observation periods while preserving the Market Context family.',
      ),
      EvidenceKind.marketBreadth: _entry(
        strategy: StrategyType.swing,
        kind: EvidenceKind.marketBreadth,
        applicability: StrategyEvidenceApplicability.recalibrateForStrategy,
        implementationReady: true,
        affectsDirection: true,
        affectsConfidence: true,
        affectsRiskOrEntryQuality: false,
        rationale:
            'Broad participation helps assess whether a multi-day market move '
            'has sustainable support.',
        calibrationNotes:
            'Audit breadth components against the Swing horizon and keep '
            'breadth de-duplicated inside the Market Context family.',
      ),
      EvidenceKind.newsSentiment: _entry(
        strategy: StrategyType.swing,
        kind: EvidenceKind.newsSentiment,
        applicability: StrategyEvidenceApplicability.recalibrateForStrategy,
        implementationReady: true,
        affectsDirection: true,
        affectsConfidence: true,
        affectsRiskOrEntryQuality: false,
        rationale:
            'Reliable material news can influence price behavior across '
            'multiple Swing sessions.',
        calibrationNotes:
            'Use Swing-specific freshness decay and materiality while '
            'preserving source diversity and repeated-headline de-duplication.',
      ),
    }),
  );

  static final StrategyAnalysisPolicy investor = StrategyAnalysisPolicy(
    strategy: StrategyType.investor,
    status: StrategyAnalysisPolicyStatus.planned,
    evidencePolicies: Map.unmodifiable(
      _productionPolicies(
        strategy: StrategyType.investor,
        builder: (kind) => _entry(
          strategy: StrategyType.investor,
          kind: kind,
          applicability: StrategyEvidenceApplicability.deferred,
          affectsDirection: false,
          affectsConfidence: false,
          affectsRiskOrEntryQuality: false,
          rationale:
              'Investor evidence applicability is intentionally deferred to '
              'v0.12.0 so v0.11.0 does not pre-decide long-horizon semantics.',
        ),
      ),
    ),
  );

  static StrategyAnalysisPolicy forStrategy(StrategyType strategy) {
    return switch (strategy) {
      StrategyType.trader => trader,
      StrategyType.swing => swing,
      StrategyType.investor => investor,
    };
  }

  static Map<EvidenceKind, StrategyEvidencePolicy> _productionPolicies({
    required StrategyType strategy,
    required StrategyEvidencePolicy Function(EvidenceKind kind) builder,
  }) {
    return {
      for (final kind in EvidenceKind.values)
        if (kind != EvidenceKind.generic) kind: builder(kind),
    };
  }

  static StrategyEvidencePolicy _entry({
    required StrategyType strategy,
    required EvidenceKind kind,
    required StrategyEvidenceApplicability applicability,
    required bool affectsDirection,
    required bool affectsConfidence,
    required bool affectsRiskOrEntryQuality,
    required String rationale,
    String? calibrationNotes,
    String? dataQualityRequirement,
    bool implementationReady = false,
  }) {
    return StrategyEvidencePolicy(
      strategy: strategy,
      kind: kind,
      family: _familyFor(kind),
      applicability: applicability,
      implementationReady: implementationReady,
      affectsDirection: affectsDirection,
      affectsConfidence: affectsConfidence,
      affectsRiskOrEntryQuality: affectsRiskOrEntryQuality,
      rationale: rationale,
      calibrationNotes: calibrationNotes,
      dataQualityRequirement: dataQualityRequirement,
    );
  }

  static EvidenceFamily _familyFor(EvidenceKind kind) {
    return switch (kind) {
      EvidenceKind.generic => EvidenceFamily.generic,
      EvidenceKind.candleTrend => EvidenceFamily.trend,
      EvidenceKind.rsi => EvidenceFamily.momentum,
      EvidenceKind.relativeVolume => EvidenceFamily.participation,
      EvidenceKind.emaStructure => EvidenceFamily.trend,
      EvidenceKind.macdMomentum => EvidenceFamily.momentum,
      EvidenceKind.vwapPosition => EvidenceFamily.priceStructure,
      EvidenceKind.supportResistance => EvidenceFamily.priceStructure,
      EvidenceKind.volumeConfirmation => EvidenceFamily.participation,
      EvidenceKind.priceExtension => EvidenceFamily.volatility,
      EvidenceKind.multiTimeframeTrend => EvidenceFamily.trend,
      EvidenceKind.marketContext => EvidenceFamily.marketContext,
      EvidenceKind.marketBreadth => EvidenceFamily.marketContext,
      EvidenceKind.newsSentiment => EvidenceFamily.sentiment,
    };
  }
}
