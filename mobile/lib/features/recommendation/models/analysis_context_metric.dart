enum AnalysisContextMetric {
  primaryAnalysisInterval,
  confirmationInterval,
  broaderRegimeInterval,
  timeframeAlignment,
  marketEnvironment,
  marketBreadth,
  relativeStrength,
  eventRisk,
  newsSentiment,
}

extension AnalysisContextMetricPresentation on AnalysisContextMetric {
  String get label {
    return switch (this) {
      AnalysisContextMetric.primaryAnalysisInterval =>
        'Primary Analysis Interval',
      AnalysisContextMetric.confirmationInterval => 'Confirmation Interval',
      AnalysisContextMetric.broaderRegimeInterval => 'Broader Regime Interval',
      AnalysisContextMetric.timeframeAlignment => 'Timeframe Alignment',
      AnalysisContextMetric.marketEnvironment => 'Market Environment',
      AnalysisContextMetric.marketBreadth => 'Market Breadth',
      AnalysisContextMetric.relativeStrength => 'Relative Strength',
      AnalysisContextMetric.eventRisk => 'Event Risk',
      AnalysisContextMetric.newsSentiment => 'News Sentiment',
    };
  }
}
