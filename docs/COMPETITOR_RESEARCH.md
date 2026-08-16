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
