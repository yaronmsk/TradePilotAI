import '../models/metric_explainability.dart';

class HistoricalSetupValidationExplainability {
  const HistoricalSetupValidationExplainability._();

  static const definition = MetricExplainability(
    semanticRole: MetricSemanticRole.confidenceRiskOnly,
    whatItIs:
        'Checks how similar historical setups performed and compares that behavior with what the same stock normally did under comparable surrounding conditions.',
    calculation:
        'TradePilot first finds historical setups with a compatible Stock Profile and similar evidence, volatility, market context, strategy and analysis interval. It then compares their recommendation-direction follow-through with a same-stock baseline that uses comparable surrounding conditions without requiring today\'s exact evidence pattern. Outcome quality is scored across several weighted dimensions, while sample depth and match quality act as reliability gates.',
    whyItMatters:
        'A setup can look technically strong while its historical analogs performed poorly, or it can receive additional confidence when genuinely similar setups repeatedly outperformed the stock\'s normal behavior under comparable conditions.',
    supportiveInterpretation:
        'Historical results are supportive when similar setups show sufficiently strong recommendation-direction follow-through and outperform the same stock\'s comparable-condition baseline. Positive confidence credit requires follow-through above both 50% and the same-stock baseline, and reliability can still reduce the size of that credit.',
    opposingInterpretation:
        'Historical results are opposing when similar setups show weak recommendation-direction follow-through, perform worse than the same stock normally did under comparable conditions, or other weighted historical outcome measures materially challenge the current setup. This can reduce confidence but cannot reverse the recommendation direction.',
    neutralInterpretation:
        'Mixed historical outcomes, limited samples, weak match quality, or a currently balanced directional signal can result in little or no confidence adjustment.',
    recommendationImpact:
        'Historical Setup Validation modifies final confidence only after the evidence-derived recommendation has been calculated. It does not create bullish or bearish evidence, does not change the recommendation direction, and does not alter evidence confidence.',
    limitations:
        'Historical similarity does not guarantee future performance. Results depend on the quality and relevance of the historical dataset, matching assumptions, outcome horizon and available sample size. Current development historical outcomes may be synthetic and must not be interpreted as real-world performance evidence.',
    boundedImpact:
        'Historical Setup Validation can adjust final confidence by no more than ±8 points. Supportive history can increase confidence and opposing history can decrease confidence. Historical validation cannot create or flip Buy/Sell direction.',
  );
}
