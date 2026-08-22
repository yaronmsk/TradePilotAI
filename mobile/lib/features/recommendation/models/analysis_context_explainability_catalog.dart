import 'analysis_context_metric.dart';
import 'metric_explainability.dart';

class AnalysisContextExplainabilityCatalog {
  const AnalysisContextExplainabilityCatalog._();

  static const Map<AnalysisContextMetric, MetricExplainability> definitions = {
    AnalysisContextMetric.primaryAnalysisInterval: MetricExplainability(
      semanticRole: MetricSemanticRole.contextConfiguration,
      whatItIs:
          'The candle interval used by the selected strategy for its primary technical analysis.',
      calculation:
          'The user selects one of the primary intervals supported by the active strategy. TradePilot then derives the confirmation and broader-regime intervals from the strategy timeframe plan.',
      whyItMatters:
          'Changing the primary interval changes the market granularity examined by the technical evidence. Shorter intervals react faster but usually contain more noise, while longer intervals describe broader price structure.',
      recommendationImpact:
          'The interval changes the data supplied to the analysis engine, so the resulting evidence can change. The interval itself does not create bullish or bearish evidence.',
      limitations:
          'A candle interval is not the expected holding period. Different intervals can legitimately show different market conditions, especially during transitions.',
    ),

    AnalysisContextMetric.timeframeAlignment: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Shows whether the primary trend agrees with the confirmation and broader-regime trend views.',
      calculation:
          'TradePilot evaluates trend direction on the primary, confirmation and regime timeframes selected by the active strategy and compares their directional agreement.',
      whyItMatters:
          'A short-term setup generally has stronger confirmation when broader trend views agree with it and weaker confirmation when they oppose it.',
      supportiveInterpretation:
          'Alignment between the active setup and broader trend views strengthens confirmation in that direction.',
      opposingInterpretation:
          'Broader trend views pointing against the active setup create conflict and weaken confirmation.',
      neutralInterpretation:
          'Mixed timeframe direction provides partial or limited confirmation rather than forcing a directional conclusion.',
      recommendationImpact:
          'Timeframe alignment contributes through Trend-family evidence. Related trend signals are aggregated and de-duplicated rather than counted as separate independent votes.',
      limitations:
          'Different timeframes can legitimately disagree during reversals and regime changes. Alignment improves context but does not guarantee continuation.',
    ),

    AnalysisContextMetric.marketEnvironment: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Describes whether the broad market and relevant sector backdrop are supportive, neutral or challenging for the stock.',
      calculation:
          'TradePilot combines broad-market performance, sector performance and the stock-specific benchmark relationships used by the Market Context analysis.',
      whyItMatters:
          'Stocks do not trade in isolation. A favorable broad and sector backdrop can reinforce a setup, while a hostile environment can create a headwind.',
      supportiveInterpretation:
          'A supportive broad-market and sector backdrop can strengthen bullish context.',
      opposingInterpretation:
          'A challenging broad-market and sector backdrop can strengthen bearish context or oppose an otherwise bullish setup.',
      neutralInterpretation:
          'A mixed or neutral backdrop provides limited directional confirmation.',
      recommendationImpact:
          'Market Environment contributes through the Market Context evidence family. It is aggregated with related context such as Relative Strength and Market Breadth so correlated information cannot multiply confidence independently.',
      limitations:
          'Benchmark and sector selection matter, and stock-specific events can overwhelm the broader environment. Market context is supporting evidence, not a standalone trading decision.',
    ),

    AnalysisContextMetric.marketBreadth: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Measures how broadly market movement is supported across underlying stocks and sectors.',
      calculation:
          'TradePilot combines advancing-stock participation, stocks above a medium-term reference, sector participation and a volatility-regime adjustment.',
      whyItMatters:
          'An index can rise or fall because of only a small number of large stocks. Breadth helps determine whether participation underneath the headline move is genuinely broad.',
      supportiveInterpretation:
          'Strong or healthy participation can contribute supportive bullish market context.',
      opposingInterpretation:
          'Weak or stressed participation can contribute bearish context and challenge bullish confirmation.',
      neutralInterpretation:
          'Mixed participation provides little additional directional confirmation.',
      recommendationImpact:
          'Market Breadth remains inside the Market Context evidence family and is therefore de-duplicated with related market-context signals.',
      limitations:
          'Breadth quality depends on the completeness of the underlying stock universe. The current development source is synthetic and must not be treated as authoritative live market intelligence.',
    ),

    AnalysisContextMetric.relativeStrength: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Measures how the analyzed stock is performing relative to its broad-market and sector benchmarks.',
      calculation:
          'TradePilot compares the stock return with the relevant broad-market return and, when available, the stock return with its sector benchmark.',
      whyItMatters:
          'Relative performance can reveal whether a stock is demonstrating genuine leadership or weakness rather than merely following the overall market.',
      supportiveInterpretation:
          'Outperformance versus relevant benchmarks can strengthen bullish stock-specific context.',
      opposingInterpretation:
          'Underperformance versus relevant benchmarks can strengthen bearish context or challenge an otherwise bullish setup.',
      neutralInterpretation:
          'Performance broadly in line with benchmarks provides little stock-specific directional advantage.',
      recommendationImpact:
          'Relative Strength contributes through the Market Context family. It must not be counted independently from correlated Market Environment or Market Breadth evidence.',
      limitations:
          'Relative performance depends on the selected benchmark and observation window. Short-lived divergence does not necessarily indicate a lasting trend.',
    ),

    AnalysisContextMetric.eventRisk: MetricExplainability(
      semanticRole: MetricSemanticRole.confidenceRiskOnly,
      whatItIs:
          'Measures uncertainty created by nearby scheduled catalysts such as earnings and important macroeconomic events.',
      calculation:
          'TradePilot evaluates the proximity and importance of known scheduled events and converts elevated event proximity into a confidence penalty.',
      whyItMatters:
          'Scheduled catalysts can cause abrupt gaps, volatility and price behavior that normal technical evidence may not anticipate.',
      recommendationImpact:
          'Event Risk can reduce confidence when scheduled-event uncertainty is elevated. It never creates bullish or bearish evidence and never determines Buy or Sell direction.',
      limitations:
          'Only known scheduled events can be evaluated. Unexpected news and unscheduled catalysts cannot be anticipated by this metric, and the current development event source is synthetic.',
      boundedImpact:
          'Event Risk can reduce confidence by at most 12 points. It cannot increase confidence and cannot create Buy/Sell direction.',
    ),

    AnalysisContextMetric.newsSentiment: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Summarizes the directional tone of recent company-specific news while considering the reliability of that information.',
      calculation:
          'TradePilot evaluates signed sentiment together with article count, independent source diversity, freshness and estimated materiality.',
      whyItMatters:
          'Material company news can reinforce, contradict or invalidate a technical setup.',
      supportiveInterpretation:
          'Sufficiently reliable positive news can contribute bullish sentiment evidence.',
      opposingInterpretation:
          'Sufficiently reliable negative news can contribute bearish sentiment evidence.',
      neutralInterpretation:
          'Mixed, weak, stale or insufficiently diverse news should not be forced into a directional conclusion.',
      recommendationImpact:
          'News Sentiment contributes through its own capped Sentiment evidence family. Reliability and family controls prevent repeated or low-quality headlines from dominating the recommendation.',
      limitations:
          'Sentiment analysis can misinterpret nuance and repeated reporting can exaggerate apparent coverage. The current development news source is synthetic rather than authoritative live news intelligence.',
    ),
  };

  static MetricExplainability forMetric(AnalysisContextMetric metric) {
    return definitions[metric]!;
  }

  static bool get coversAllMetrics =>
      AnalysisContextMetric.values.every(definitions.containsKey) &&
      definitions.length == AnalysisContextMetric.values.length;
}
