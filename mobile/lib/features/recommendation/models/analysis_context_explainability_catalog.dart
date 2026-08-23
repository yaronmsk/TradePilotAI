import 'analysis_context_metric.dart';
import 'metric_explainability.dart';
import 'strategy_summary.dart';

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
    AnalysisContextMetric.confirmationInterval: MetricExplainability(
      semanticRole: MetricSemanticRole.contextConfiguration,
      whatItIs:
          'The broader candle interval used to check whether the primary setup has trend support.',
      calculation:
          'TradePilot automatically derives the confirmation interval from the selected strategy and primary analysis interval, then evaluates trend behavior on that broader view.',
      whyItMatters:
          'A setup is generally better confirmed when the next broader trend agrees with it and less confirmed when that trend conflicts with it.',
      recommendationImpact:
          'The interval itself does not create bullish or bearish evidence. The trend observed on this interval participates inside Multi-Timeframe Trend evidence and is de-duplicated inside the Trend family.',
      limitations:
          'The broader confirmation trend can lag fast reversals. Disagreement is valid information and should weaken confirmation rather than automatically invalidate the primary setup.',
    ),
    AnalysisContextMetric.broaderRegimeInterval: MetricExplainability(
      semanticRole: MetricSemanticRole.contextConfiguration,
      whatItIs:
          'The slowest configured timeframe used to show the larger trend backdrop around the active setup.',
      calculation:
          'TradePilot automatically selects a regime interval from the active strategy timeframe plan and evaluates the broader trend on that interval.',
      whyItMatters:
          'A larger trend backdrop helps identify whether the active setup is occurring with, against or during a transition in the broader market structure.',
      recommendationImpact:
          'The interval itself is configuration and does not vote Buy or Sell. The trend measured on it contributes only through Multi-Timeframe Trend evidence inside the capped Trend family.',
      limitations:
          'A slow regime view reacts later than the primary setup. It should provide context rather than override fresh evidence merely because it changes more slowly.',
    ),
    AnalysisContextMetric.timeframeAlignment: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Shows whether the primary trend agrees with the confirmation and broader-regime trend views.',
      calculation:
          'TradePilot evaluates trend direction on the primary, confirmation and regime timeframes selected by the active strategy and compares their directional agreement.',
      whyItMatters:
          'An active setup generally has stronger confirmation when broader trend views agree with it and weaker confirmation when they oppose it.',
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

  static const _swingPrimaryAnalysisInterval = MetricExplainability(
    semanticRole: MetricSemanticRole.contextConfiguration,
    whatItIs: 'The candle interval used to identify the active Swing setup.',
    calculation:
        'Swing currently supports a 1-day primary interval by default or a 4-hour alternate interval. Selecting the primary interval automatically selects its confirmation and broader-regime views.',
    whyItMatters:
        'The primary interval defines the market structure TradePilot treats as the current Swing setup. It is analysis granularity, not a promise about how many days a position should be held.',
    recommendationImpact:
        'The interval itself does not create bullish or bearish evidence. Within Swing Multi-Timeframe Trend analysis, the trend measured on the primary interval anchors the active setup direction.',
    limitations:
        'Different primary intervals can legitimately produce different Swing setups. A 4-hour setup can change before the daily structure changes.',
  );

  static const _swingConfirmationInterval = MetricExplainability(
    semanticRole: MetricSemanticRole.contextConfiguration,
    whatItIs:
        'The next broader timeframe used to check whether the active Swing setup has trend confirmation.',
    calculation:
        'For a 1-day Swing setup, TradePilot uses 1-week candles for confirmation. For a 4-hour Swing setup, it uses 1-day candles.',
    whyItMatters:
        'A broader confirming trend can make a Swing setup more coherent. Opposition is a warning that the primary setup is moving against a larger trend.',
    recommendationImpact:
        'The interval itself is not bullish or bearish. The trend observed on it can strengthen or weaken Multi-Timeframe Trend evidence, but it cannot independently flip the primary Swing setup direction.',
    limitations:
        'Confirmation is intentionally slower than the primary setup. During genuine reversals it may initially disagree with a new primary trend.',
  );

  static const _swingBroaderRegimeInterval = MetricExplainability(
    semanticRole: MetricSemanticRole.contextConfiguration,
    whatItIs:
        'The slowest Swing timeframe used to describe the larger trend regime behind the setup.',
    calculation:
        'For a 1-day Swing setup, TradePilot uses 1-month candles as the broader regime view. For a 4-hour Swing setup, it uses 1-week candles.',
    whyItMatters:
        'The regime view helps show whether a Swing trade is aligned with the larger structure or attempting to move against it.',
    recommendationImpact:
        'The interval itself does not create direction. Its measured trend may reinforce or weaken Multi-Timeframe Trend evidence, but it is contextual and cannot independently reverse the primary Swing setup.',
    limitations:
        'The broader regime reacts slowly and can remain opposed during the early stage of a real trend change. It must not automatically veto newer evidence.',
  );

  static const _swingTimeframeAlignment = MetricExplainability(
    semanticRole: MetricSemanticRole.directionalEvaluative,
    whatItIs:
        'Shows whether the broader Swing trend views support or conflict with the active primary Swing setup.',
    calculation:
        'Within Swing Multi-Timeframe Trend context, the primary setup carries 60% of the internal role-weighted directional strength, confirmation 25%, and broader regime 15%. Confirmation quality uses the two broader views with 65% emphasis on the confirmation interval and 35% on the regime interval.',
    whyItMatters:
        'Swing setups are generally stronger when daily/weekly/monthly structure agrees and less reliable when the active setup is fighting broader trends.',
    supportiveInterpretation:
        'Broader timeframes aligned with the primary Swing setup strengthen trend confirmation.',
    opposingInterpretation:
        'Broader timeframes opposing the primary Swing setup reduce its trend strength and confidence.',
    neutralInterpretation:
        'Mixed or neutral broader views provide limited confirmation and can move the Multi-Timeframe Trend result toward neutral.',
    recommendationImpact:
        'The primary Swing timeframe anchors direction. Broader views may strengthen or weaken that setup, but they cannot independently flip it by simple voting. Multi-Timeframe Trend remains one capped Trend-family evidence source. The 60/25/15 figures are internal timeframe-role weights, not percentages of the final recommendation.',
    limitations:
        'These role weights are deterministic v0.11 policy assumptions, not statistically optimized performance weights. Broader-timeframe disagreement is common during real regime transitions.',
  );

  static MetricExplainability forMetric(
    AnalysisContextMetric metric, {
    StrategyType? strategy,
  }) {
    if (strategy == StrategyType.swing) {
      return switch (metric) {
        AnalysisContextMetric.primaryAnalysisInterval =>
          _swingPrimaryAnalysisInterval,
        AnalysisContextMetric.confirmationInterval =>
          _swingConfirmationInterval,
        AnalysisContextMetric.broaderRegimeInterval =>
          _swingBroaderRegimeInterval,
        AnalysisContextMetric.timeframeAlignment => _swingTimeframeAlignment,
        _ => definitions[metric]!,
      };
    }

    return definitions[metric]!;
  }

  static bool get coversAllMetrics =>
      AnalysisContextMetric.values.every(definitions.containsKey) &&
      definitions.length == AnalysisContextMetric.values.length;
}
