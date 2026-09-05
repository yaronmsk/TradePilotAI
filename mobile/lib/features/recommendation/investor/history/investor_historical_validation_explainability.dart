import '../../models/metric_explainability.dart';

class InvestorHistoricalValidationExplainability {
  InvestorHistoricalValidationExplainability._();

  static const MetricExplainability definition = MetricExplainability(
    semanticRole: MetricSemanticRole.confidenceRiskOnly,
    whatItIs:
        'Checks how similar point-in-time Investor fundamental setups historically behaved over mature 6-month, 12-month and 24-month forward windows.',
    calculation:
        'Matches the current six-core-family fingerprint against historical same-stock fingerprints that were knowable at their setup dates. Similar cases are de-overlapped, compared with the stock’s broader same-direction historical baseline, and evaluated on both absolute and benchmark-relative follow-through. Mature 6m/12m/24m horizon scores are combined once using 25%/50%/25% policy weights and then bounded to a single ±8 confidence-point overlay.',
    whyItMatters:
        'Historical follow-through can tell us whether a current long-term evidence pattern has previously behaved better or worse than that stock’s own usual same-direction setups.',
    recommendationImpact:
        'Historical validation changes confidence only. It contributes zero direction points, zero family breadth and zero evidence votes. The total impact across all horizons is hard-capped to ±8 confidence points.',
    limitations:
        'Historical similarity is not a probability of profit and does not prove causation. Regimes, business models and valuation relationships can change. Long horizons create overlapping observations and smaller mature samples, so Batch 9 de-overlaps cases, uses same-stock controls, requires 12-month evidence and keeps the confidence effect bounded.',
    boundedImpact:
        'At most +8 or -8 final-confidence points across the combined 6m/12m/24m validation. No horizon receives a separate ±8 allowance.',
  );
}
