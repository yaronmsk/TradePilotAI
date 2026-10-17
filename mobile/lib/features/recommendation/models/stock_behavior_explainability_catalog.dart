import 'metric_explainability.dart';

enum StockBehaviorMetric {
  stockType,
  volatilityNow,
  typicalDailyRange,
  volumePattern,
}

class StockBehaviorExplainabilityCatalog {
  StockBehaviorExplainabilityCatalog._();

  static const Map<StockBehaviorMetric, MetricExplainability> _definitions = {
    StockBehaviorMetric.stockType: MetricExplainability(
      semanticRole: MetricSemanticRole.contextConfiguration,
      whatItIs:
          'A long-term classification of whether this stock normally behaves as steady, balanced or volatile.',
      calculation:
          'With a valid daily historical baseline, TradePilot compares the stock\'s typical normalized daily ATR and typical realized volatility. The current deterministic classification treats a stock as steady when typical ATR is at most 1.8% and typical realized volatility is at most 30%; volatile when ATR is at least 3.0% or realized volatility is at least 50%; otherwise it is balanced.',
      whyItMatters:
          'The same indicator reading can mean different things in a naturally quiet stock and a naturally volatile stock.',
      recommendationImpact:
          'Stock Type does not create or flip Buy/Sell direction. It may only change how much trust TradePilot gives to evidence that already exists. Swing Stock DNA adjustments require a valid daily historical baseline.',
      limitations:
          'The classification compresses complex behavior into three categories and can change as the historical window changes. The thresholds are deterministic policy assumptions rather than statistically optimized breakpoints.',
    ),
    StockBehaviorMetric.volatilityNow: MetricExplainability(
      semanticRole: MetricSemanticRole.contextConfiguration,
      whatItIs:
          'Shows whether current realized volatility is calm, normal or elevated compared with this stock\'s own history.',
      calculation:
          'TradePilot calculates recent 20-session annualized realized volatility and ranks it against the stock\'s historical distribution. Up to the 25th percentile is calm, the 75th percentile or higher is elevated, and values between those levels are normal.',
      whyItMatters:
          'Evidence that is useful in normal conditions may deserve less trust when the stock is moving unusually erratically.',
      recommendationImpact:
          'Volatility Now does not create or flip Buy/Sell direction. For Swing it may modestly reduce the weight of evidence that is less reliable in unusually volatile conditions.',
      limitations:
          'A volatility percentile describes movement magnitude, not direction. Elevated volatility can occur during both strong advances and strong declines.',
    ),
    StockBehaviorMetric.typicalDailyRange: MetricExplainability(
      semanticRole: MetricSemanticRole.contextConfiguration,
      whatItIs:
          'The stock\'s typical normalized daily trading range measured with ATR.',
      calculation:
          'TradePilot calculates a 14-session ATR as a percentage of price across the daily historical baseline and uses the median historical value as the typical daily range.',
      whyItMatters:
          'A move that is exceptional for a normally quiet stock may be routine for a stock that regularly travels several percent per day.',
      recommendationImpact:
          'Typical Daily Range is context only. It cannot create or flip Buy/Sell direction and is used to interpret how unusual other price and volatility evidence is.',
      limitations:
          'ATR measures range, not direction, and historical daily behavior may not describe future volatility regimes.',
    ),
    StockBehaviorMetric.volumePattern: MetricExplainability(
      semanticRole: MetricSemanticRole.contextConfiguration,
      whatItIs:
          'With a daily historical baseline, this describes whether the stock\'s volume is normally stable or erratic. Without that baseline, TradePilot may show short-term Relative Volume only when the comparison is valid.',
      calculation:
          'Historical Volume Pattern uses the coefficient of variation of the latest 60 daily volume observations. Short-term Relative Volume compares current volume with a recent comparable baseline. LIVE intraday RVOL is withheld when comparable same-session-position history is unavailable.',
      whyItMatters:
          'A volume expansion is more informative when it is genuinely unusual for that stock and that point in the trading session.',
      recommendationImpact:
          'This context does not create or flip Buy/Sell direction. It may only adjust existing Participation evidence when its volume baseline is valid.',
      limitations:
          'Intraday volume changes systematically through the session. Ordinary adjacent candles are not interchangeable time-of-day baselines, so TradePilot reports the short-term value as unavailable rather than inventing a comparison.',
    ),
  };

  static MetricExplainability forMetric(StockBehaviorMetric metric) {
    return _definitions[metric]!;
  }
}
