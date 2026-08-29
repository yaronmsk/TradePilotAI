import 'metric_explainability.dart';

class RecommendationAttributionExplainability {
  const RecommendationAttributionExplainability._();

  static const directionInfluence = MetricExplainability(
    semanticRole: MetricSemanticRole.directionalEvaluative,
    whatItIs:
        'The share of the current post-cap directional evidence basis owned '
        'by one independent evidence family.',
    calculation:
        'TradePilot first combines correlated providers inside each evidence '
        'family and applies the family cap. The absolute signed direction '
        'impact of each resulting family is then divided by the total '
        'absolute family-level direction impact. Active family shares sum to '
        '100%.',
    whyItMatters:
        'It shows which independent evidence groups actually drove the '
        'directional conclusion after correlated indicators were '
        'de-duplicated.',
    supportiveInterpretation:
        'The family has signed direction impact in the same direction as the '
        'current overall directional conclusion.',
    opposingInterpretation:
        'The family has signed direction impact against the current overall '
        'directional conclusion.',
    neutralInterpretation:
        'The family has no material net directional impact in the current '
        'case.',
    recommendationImpact:
        'Family direction-impact points reconcile to the Direction Score. '
        'This percentage describes the existing directional basis; it does '
        'not create an additional vote.',
    limitations:
        'This is a family-level attribution percentage, not a probability of '
        'profit and not an indicator-level percentage. Providers inside one '
        'family may oppose and partially cancel each other.',
  );

  static const evidenceConfidenceShare = MetricExplainability(
    semanticRole: MetricSemanticRole.confidenceRiskOnly,
    whatItIs:
        'The portion of evidence-derived confidence attributed to one '
        'independent evidence family.',
    calculation:
        'Evidence confidence is distributed across the capped evidence '
        'families according to their effective evidence-strength '
        'contribution after coverage, alignment and reliability treatment.',
    whyItMatters:
        'It shows which independent evidence groups supplied the evidence '
        'quality behind confidence without mixing confidence with direction.',
    recommendationImpact:
        'It explains evidence-derived confidence only and cannot create, '
        'remove or flip BUY/SELL direction.',
    limitations:
        'It does not include Event Risk or Historical Validation. It is not a '
        'probability that the trade will succeed.',
    boundedImpact:
        'Family confidence shares partition evidence-derived confidence only; '
        'they do not add extra confidence points or directional influence.',
  );

  static const providerDirectionImpact = MetricExplainability(
    semanticRole: MetricSemanticRole.directionalEvaluative,
    whatItIs:
        'The signed direction points allocated to one provider inside its '
        'already capped evidence family.',
    calculation:
        'Providers first participate in their shared evidence-family '
        'calculation. The family cap is applied before provider impacts are '
        'reconciled back to signed direction points. Provider points inside '
        'the family sum to that family\'s signed direction impact.',
    whyItMatters:
        'It lets advanced users inspect which indicators supported or opposed '
        'their family result without pretending correlated indicators are '
        'independent votes.',
    supportiveInterpretation:
        'Positive or negative signed points that align with the overall '
        'direction support the current conclusion.',
    opposingInterpretation:
        'Signed points that oppose the overall direction weaken the family\'s '
        'net directional result.',
    neutralInterpretation:
        'Near-zero signed impact means the provider had little net '
        'directional effect in this case.',
    recommendationImpact:
        'Provider signed impacts reconcile into the capped family impact and '
        'cannot bypass the family cap.',
    limitations:
        'Provider-level percentages are intentionally not presented as a '
        'percentage of the recommendation. Opposing providers can create '
        'large absolute internal shares while mostly cancelling in the '
        'family\'s net result.',
  );

  static const providerConfidenceContribution = MetricExplainability(
    semanticRole: MetricSemanticRole.confidenceRiskOnly,
    whatItIs:
        'The evidence-confidence points attributable to one provider after '
        'its evidence family has been aggregated.',
    calculation:
        'The provider receives its reconciled portion of the family\'s '
        'evidence-confidence contribution after family aggregation, coverage, '
        'alignment and reliability treatment.',
    whyItMatters:
        'It shows how much of evidence-derived confidence came from the '
        'provider without confusing that value with directional influence.',
    recommendationImpact:
        'It contributes to evidence-derived confidence only. Event Risk and '
        'Historical Validation are calculated separately.',
    limitations:
        'It is not a probability of profit and cannot be interpreted as an '
        'independent indicator vote when multiple providers share a family.',
    boundedImpact:
        'Provider confidence contributions only partition evidence-derived '
        'confidence and cannot create or flip recommendation direction.',
  );

  static const evidenceStrengthBaseline = MetricExplainability(
    semanticRole: MetricSemanticRole.confidenceRiskOnly,
    whatItIs:
        'The evidence-strength starting point before confidence-quality '
        'adjustments are applied.',
    calculation:
        'TradePilot combines the effective strength of the available capped '
        'evidence families into a 0-100 evidence-strength baseline.',
    whyItMatters:
        'It provides the starting point from which evidence coverage, '
        'alignment and reliability determine evidence confidence.',
    recommendationImpact:
        'It is a confidence input only and does not independently create '
        'BUY/SELL direction.',
    limitations:
        'A strong baseline can still produce lower confidence when coverage, '
        'agreement or reliability are weak.',
    boundedImpact:
        'Displayed on a 0-100 confidence scale and cannot independently alter '
        'direction.',
  );

  static const evidenceQualityAdjustment = MetricExplainability(
    semanticRole: MetricSemanticRole.confidenceRiskOnly,
    whatItIs:
        'The combined confidence change caused by evidence-quality factors.',
    calculation:
        'TradePilot sums the actual point changes produced by confidence '
        'modifiers whose semantic source is evidence quality, including '
        'coverage, alignment and reliability treatment.',
    whyItMatters:
        'Strong directional evidence should not receive the same confidence '
        'when the data is incomplete, unreliable or internally conflicted.',
    recommendationImpact:
        'It changes evidence-derived confidence only and leaves Direction '
        'Score unchanged.',
    limitations:
        'It summarizes several internal quality factors into one point change '
        'for readability. Technical details remain available elsewhere.',
    boundedImpact:
        'Cannot create or flip recommendation direction; evidence confidence '
        'remains bounded by the scoring engine.',
  );

  static const evidenceDerivedConfidence = MetricExplainability(
    semanticRole: MetricSemanticRole.confidenceRiskOnly,
    whatItIs:
        'Confidence produced by the current evidence engine before external '
        'Event Risk and Historical Validation adjustments.',
    calculation:
        'Evidence-strength baseline plus the actual evidence-quality point '
        'adjustments from coverage, alignment and reliability.',
    whyItMatters:
        'It separates what the current evidence itself supports from later '
        'risk or historical-validation overlays.',
    recommendationImpact:
        'It forms the confidence base for the recommendation but does not '
        'change the Direction Score.',
    limitations:
        'It is not a probability of profit and does not yet include external '
        'risk or historical-validation adjustments.',
    boundedImpact:
        'Confidence-only metric on the 0-100 scale; it cannot create or flip '
        'BUY/SELL direction.',
  );

  static const eventRiskAdjustment = MetricExplainability(
    semanticRole: MetricSemanticRole.confidenceRiskOnly,
    whatItIs:
        'A bounded confidence penalty for relevant upcoming earnings or '
        'high-impact macro events.',
    calculation:
        'The strategy-specific Event Risk policy converts event timing into a '
        'confidence-only point adjustment.',
    whyItMatters:
        'Important scheduled events can make otherwise strong evidence less '
        'reliable because price behavior around the event may change sharply.',
    recommendationImpact:
        'Event Risk may reduce final confidence but cannot create, remove or '
        'flip directional evidence.',
    limitations:
        'The adjustment reflects known modeled event timing only and cannot '
        'capture every surprise or unmodeled event.',
    boundedImpact:
        'No positive confidence bonus and maximum 12-point confidence penalty. '
        'Directional influence is exactly zero.',
  );

  static const historicalValidationAdjustment = MetricExplainability(
    semanticRole: MetricSemanticRole.confidenceRiskOnly,
    whatItIs:
        'The bounded confidence adjustment produced by context-matched '
        'Historical Setup Validation.',
    calculation:
        'Matched historical setups are evaluated against strategy/timeframe '
        'specific forward outcomes and a same-stock contextual baseline. The '
        'validated result is converted into a bounded confidence adjustment.',
    whyItMatters:
        'It checks whether sufficiently similar historical setups support or '
        'weaken confidence in the current evidence-driven conclusion.',
    recommendationImpact:
        'Historical Validation can strengthen or weaken final confidence but '
        'cannot create or flip recommendation direction.',
    limitations:
        'Historical similarity does not guarantee future performance. '
        'Synthetic development history must never be described as real market '
        'performance.',
    boundedImpact:
        'Maximum ±8 final-confidence points and zero directional influence.',
  );

  static const finalConfidence = MetricExplainability(
    semanticRole: MetricSemanticRole.confidenceRiskOnly,
    whatItIs: 'The final confidence score shown with the recommendation.',
    calculation:
        'Evidence-derived confidence plus the actual bounded Event Risk and '
        'Historical Validation point adjustments.',
    whyItMatters:
        'It summarizes how strongly TradePilot trusts the current '
        'recommendation after evidence quality and allowed external '
        'confidence-only adjustments.',
    recommendationImpact:
        'Recommendation policy uses final confidence together with direction, '
        'coverage, conflict and independent-family requirements.',
    limitations:
        'Confidence is not a probability of profit, a price forecast or a '
        'guarantee that the recommendation will be correct.',
    boundedImpact:
        'Final confidence is bounded to the scoring range and cannot by itself '
        'create BUY/SELL direction.',
  );

  static const all = <MetricExplainability>[
    directionInfluence,
    evidenceConfidenceShare,
    providerDirectionImpact,
    providerConfidenceContribution,
    evidenceStrengthBaseline,
    evidenceQualityAdjustment,
    evidenceDerivedConfidence,
    eventRiskAdjustment,
    historicalValidationAdjustment,
    finalConfidence,
  ];
}
