# TradePilot AI Competitor Research

Research checkpoint: August 2026

## Research rule

Before a major feature is designed, compare the public implementation of leading products, identify the useful pattern, identify its limitations, and then design a TradePilot AI version that is more adaptive, transparent, strategy-aware or statistically disciplined.

## TradingView

Public documentation shows that TradingView Technical Ratings combines 26 constituent technical indicators and can display Moving Average, Oscillator and combined ratings across multiple timeframes. TradingView also exposes Relative Volume and Relative Volume at Time, including comparisons with historical volume at comparable time points.

Useful pattern:
- Broad technical coverage.
- Grouping of technical signals.
- Multi-timeframe visibility.
- Relative rather than raw volume context.

TradePilot AI enhancement:
- Do not count every indicator as an independent vote.
- Collapse related signals into evidence families before consensus.
- Separate recommendation direction from confidence.
- Make the selected Trader / Swing / Investor strategy explicit for every detailed recommendation and explanation.

Sources:
- https://www.tradingview.com/support/solutions/43000614331-technical-ratings/
- https://www.tradingview.com/support/solutions/43000705489-relative-volume-at-time/
- https://www.tradingview.com/support/solutions/43000635874-how-do-we-calculate-relative-volume-and-relative-volume-at-time/

## TrendSpider

Public documentation emphasizes multi-factor alerts, strategy testing, automated technical analysis, multi-timeframe conditions and normalized volatility tools such as Normalized ATR.

Useful pattern:
- Multiple conditions can be combined into one setup.
- Strategy testing encourages validation rather than relying on a single signal.
- Volatility can be normalized to make context more comparable.

TradePilot AI enhancement:
- The brain performs the factor grouping itself rather than requiring the user to manually decide which signals are independent.
- Correlated indicators cannot linearly multiply confidence.
- Context-adjusted weights remain explainable to the user.

Sources:
- https://trendspider.com/learning-center/multi-factor-price-alerts/
- https://help.trendspider.com/kb/strategy-tester/understanding-strategy-tester-from-trendspider
- https://help.trendspider.com/kb/indicators/atr-normalized

## Seeking Alpha

Seeking Alpha describes Quant Ratings built from more than 100 metrics that are rolled into five factor grades: Value, Growth, Profitability, Momentum and EPS Revisions. Metrics are compared with sector peers instead of being interpreted only as absolute numbers.

Useful pattern:
- Many raw metrics are organized into higher-level factors.
- Relative/peer comparison is central.
- Different categories capture different types of information.

TradePilot AI enhancement:
- Apply the same factor-family concept to technical and market evidence.
- Keep Trader, Swing and Investor engines separate so a short-term technical conclusion is never presented as a long-term investment conclusion.
- Surface agreement, opposition and family coverage instead of only one opaque aggregate number.

Sources:
- https://help.seekingalpha.com/premium/what-are-quant-ratings-and-how-do-i-use-them
- https://help.seekingalpha.com/premium/quant-ratings-and-factor-grades-faq

## TipRanks

TipRanks describes Smart Score as a proprietary 1–10 score built from eight market factors, including analyst, technical, fundamental and other market information.

Useful pattern:
- Heterogeneous data sources are summarized into one user-friendly score.
- Conflicting sources can coexist in the underlying analysis.

TradePilot AI enhancement:
- Keep the simple top-level recommendation, but expose the deterministic contribution structure beneath it.
- Show direction and confidence separately.
- Explain which independent evidence families support or oppose the conclusion.

Source:
- https://www.tipranks.com/glossary/s/smart-score

## Research implication for TradePilot AI

The public product documentation above supports a common pattern: successful analysis products aggregate many inputs, often group them into categories, and frequently provide relative or normalized context.

TradePilot AI v0.5 goes further in four deliberate ways:

1. Evidence-family de-duplication: Trend, Momentum, Participation and future families are aggregated before the final consensus so several correlated indicators cannot simply outvote one independent signal by quantity.
2. Direction is not confidence: a stock may have a bullish directional bias with only moderate confidence, or a neutral recommendation with high confidence because strong independent families conflict.
3. Strategy ownership: every recommendation, evidence view, risk view and future AI explanation is explicitly attached to Trader, Swing or Investor.
4. Explainable consensus: agreement, conflict, family coverage and bullish/bearish support are visible rather than hidden behind a single score.

## Statistical discipline

Future historical optimization must be treated cautiously. Research on backtest overfitting shows that repeated strategy selection against the same historical data can produce attractive in-sample results that fail out of sample. TradePilot AI therefore plans separate training/validation periods, walk-forward testing and explicit out-of-sample calibration before historical effectiveness is allowed to change live evidence weights.

Reference:
- Bailey et al., The Probability of Backtest Overfitting: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2326253

## Adopted in v0.5

- EvidenceFamily model.
- ConsensusEngine with family-level caps.
- Independent-family agreement and conflict.
- Provider coverage plus family coverage.
- Direction score separate from confidence.
- Strategy Summary becomes the context selector for the analysis below it.
- Recommendation, Recommendation Insight, Evidence and Risk are explicitly labeled with the selected strategy.
- Trader remains the only active strategy in v0.5; Swing and Investor remain Coming Soon.


## v0.5 UX refinement — explainability without jargon

A review of current competitor presentation patterns reinforced a useful separation:
- TradingView presents a simple overall technical Buy / Neutral / Sell style summary while allowing users to inspect the underlying technical groups.
- Seeking Alpha exposes a simple overall Quant Rating and score, with factor grades available underneath.
- TipRanks similarly surfaces a simple top-level Smart Score and then exposes the contributing factors.

TradePilot AI enhancement:
- Keep the full consensus mathematics inside the deterministic brain.
- Present only three primary concepts by default: Signal Strength, Confidence and Signal Alignment.
- Explain the conclusion in plain English with `Why this confidence?`.
- Keep agreement, conflict, coverage, reliability and evidence-group internals one level deeper under `How was this calculated?`.
- Preserve info buttons so users can learn the meaning of each primary metric without cluttering the default dashboard.
- Never describe Confidence as a guaranteed probability of profit.

## v0.6 research — Historical Context / Stock DNA

### TradingView: volume and volatility are relative to context

TradingView's Relative Volume calculation divides current volume by average volume. Its Relative Volume at Time goes further by comparing volume at a particular moment with historical volume at matching time offsets across prior periods. TradingView's ATR and Historical Volatility documentation also treat volatility as a measurable property of the instrument rather than a directional Buy/Sell signal.

Useful pattern:
- Compare activity with a historical norm instead of presenting raw volume alone.
- Treat volatility as context/risk information, not direction.
- Intraday volume comparisons should respect time-of-day effects when the required history exists.

TradePilot AI enhancement:
- Use long-term behavior as an input to the recommendation engine, not only as a chart indicator.
- Separate structural stock volatility from a temporary high/low volatility regime.
- Do not implement fake same-time-of-day RVOL from daily candles. Keep that capability reserved for a provider with real matching intraday sessions.

Sources:
- https://www.tradingview.com/support/solutions/43000635874-how-do-we-calculate-relative-volume-and-relative-volume-at-time/
- https://www.tradingview.com/support/solutions/43000705489-relative-volume-at-time/
- https://www.tradingview.com/support/solutions/43000501823-average-true-range-atr/
- https://www.tradingview.com/support/solutions/43000589145-historical-volatility/

### TrendSpider: normalize volatility and compare volume with historical norms

TrendSpider's Normalized ATR divides ATR by closing price and expresses it as a percentage, making volatility more comparable across different price levels and conditions. TrendSpider's Relative Volume compares the volume of a bar with average volume over prior bars to identify unusual activity.

Useful pattern:
- Normalize volatility by price.
- Compare volume with its own prior baseline.
- Use relative volatility to adapt strategy/risk interpretation.

TradePilot AI enhancement:
- Keep normalized ATR as one part of a broader historical profile rather than a standalone signal.
- Add realized-volatility percentile, volume stability and trend efficiency to describe the stock's normal behavior.
- Let that profile change evidence weights deterministically and explain why a weight changed.

Sources:
- https://help.trendspider.com/kb/indicators/atr-normalized
- https://help.trendspider.com/kb/indicators/relative-volume

### Seeking Alpha: relative comparisons and higher-level factor organization

Seeking Alpha's public Quant documentation describes more than 100 metrics organized into five factor groups, with metrics compared against sector peers. It also states that the overall Quant Rating is not a simple average of the factor grades.

Useful pattern:
- Raw metrics become more useful when compared to a relevant reference set.
- Many metrics should be organized into interpretable higher-level factors.
- An overall conclusion need not be a naïve average.

TradePilot AI enhancement for v0.6:
- First compare each stock against its own historical behavior because this directly addresses the difference between normally steady and normally volatile names.
- Preserve evidence-family de-duplication from v0.5.
- Add sector/peer cross-sectional context later when real market/sector data is connected rather than simulating it in mock data.

Sources:
- https://help.seekingalpha.com/premium/quant-ratings-and-factor-grades-faq
- https://help.seekingalpha.com/premium/what-are-quant-ratings-and-how-do-i-use-them

### Research discipline: volatility should affect risk interpretation

Moreira and Muir's volatility-managed-portfolio research documents materially different risk-adjusted outcomes when portfolio exposure is adjusted according to volatility. TradePilot AI does not copy that portfolio strategy or treat it as proof that high volatility predicts a price direction. The relevant design lesson is narrower: volatility is a meaningful state variable that should affect how confidently the system interprets other signals and risk.

Source:
- https://www.nber.org/papers/w22208

## Adopted in v0.6

- One-year daily historical profile as preferred stock-context baseline.
- Normalized daily ATR% baseline.
- Realized-volatility percentile against the stock's own history.
- Structural Stock Type separated from current Volatility Regime.
- 20D/60D average daily volume and historical volume variability.
- Trend efficiency over 20D/60D windows.
- Historical context changes RSI, Trend and Relative Volume weighting.
- User-facing Stock DNA card with simple language and deeper details on demand.
- Short-window fallback if history is unavailable.
- Same-time-of-day RVOL explicitly deferred until suitable intraday history exists.


## v0.7 research — Multi-Timeframe + Market Context

### TradingView

TradingView Multi-Timeframe Analysis lets users view a ticker or indicator from a higher timeframe in the context of the current chart. Its Compare tool supports benchmarking assets against each other and explicitly mentions both broad-market comparison and same-sector company comparison.

TradePilot enhancement:
- Timeframes receive strategy-specific roles instead of equal votes.
- Trader uses 5m Primary, 1h Confirmation and 1D Regime.
- Multi-timeframe trend remains in the Trend family so correlated timeframe observations cannot inflate independent-family confidence.
- Benchmark comparison becomes deterministic brain evidence rather than only a visual overlay.

Sources:
- https://www.tradingview.com/support/solutions/43000591555-leveraging-multi-timeframe-analysis/
- https://www.tradingview.com/support/solutions/43000543053-how-to-use-the-compare-tool/

### TrendSpider

TrendSpider Market Scanner supports different timeframes in the same scan and documents up to three timeframes for multi-timeframe scanning.

TradePilot enhancement:
- The brain automatically loads the timeframe hierarchy appropriate to the selected strategy.
- Higher-timeframe opposition reduces confirmation but does not automatically veto a valid primary signal.
- The relationship is exposed in plain language as Timeframe Alignment.

Sources:
- https://help.trendspider.com/kb/scanner/multiple-timeframes-and-the-current-candle
- https://trendspider.com/learning-center/real-time-scanning/

### StockCharts

StockCharts Price Relative/Relative Strength compares a stock with a benchmark and can evaluate performance relative to a sector or industry. Relative Rotation Graphs compare relative-strength trends against a common benchmark.

TradePilot enhancement:
- Stock-vs-market and stock-vs-sector leadership become a separate Market Context evidence family.
- Context prioritizes the stock's own relative leadership rather than simply treating a rising market as bullish evidence.
- Sector-vs-market and broad-market trend contribute smaller environmental weights.

Sources:
- https://chartschool.stockcharts.com/table-of-contents/technical-indicators-and-overlays/technical-indicators/price-relative-relative-strength
- https://chartschool.stockcharts.com/table-of-contents/chart-analysis/chart-types/relative-rotation-graphs-rrg-charts

### v0.7 product rule

Multi-timeframe analysis is hierarchical, not democratic. A 5m, 1h and 1D trend observation may improve trend reliability, but those observations are still related price-trend evidence and must not be counted as three independent evidence families.
