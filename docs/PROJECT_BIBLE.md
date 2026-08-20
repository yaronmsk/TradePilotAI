# TradePilot AI Project Bible

Version: 1.6
Status: Living reference

## Mission

Build an explainable, statistically grounded investment analysis platform that helps users understand evidence, probability and risk rather than pretending to predict the future.

## Permanent principles

- Never claim to predict the market.
- Every recommendation must be traceable to measurable evidence.
- Supporting and opposing evidence are both displayed.
- Direction and confidence are separate concepts.
- Confidence is earned from coverage, reliability, agreement, independence and historical validation.
- Correlated indicators must not gain artificial voting power merely because several versions of the same idea are present.
- Dynamic thresholds and stock-specific baselines are preferred to one-size-fits-all thresholds.
- Trader, Swing and Investor are separate strategies with different horizons and logic.
- Every detailed Recommendation, Recommendation Insight, Evidence, Risk and future AI explanation must explicitly belong to a strategy.
- The Strategy Summary is the master strategy selector for the detail analysis below it.
- AI explains, mentors and analyzes; deterministic engines decide.
- Business logic is independent from the visual UI.
- Current UI is provisional and can be completely redesigned later.
- Buy and Sell capabilities receive equal treatment.
- When evidence is inadequate or conflicted, WAIT/HOLD is preferable to false certainty.

## Current architecture

Market data
→ Primary market snapshot / historical Stock DNA
→ Strategy-selected primary analysis interval + automatic confirmation / broader backdrop
→ Broad-market / sector relative context
→ Stock behavior profile
→ Evidence providers
→ Contextual evidence adjuster
→ Evidence report
→ Evidence-family aggregation
→ Consensus Engine
→ Strategy-specific recommendation
→ Historical Setup Validation (bounded confidence overlay)
→ Presentation / explainability
→ Future AI Analyst / Mentor

## Current implemented evidence

- Candle Trend — Trend family
- EMA Structure — Trend family
- Multi-Timeframe Trend — Trend family (same family by design; higher timeframes cannot create duplicate independent votes)
- RSI — Momentum family
- MACD Momentum — Momentum family
- Relative Volume — Participation family
- Volume Confirmation — Participation family
- VWAP Position — Price Structure family
- Support & Resistance — Price Structure family
- Price Extension — Volatility family
- Market & Sector Context — Market Context family

## Current brain outputs

Internal engine outputs:
- Direction Score
- Confidence
- Bullish / bearish evidence support
- Agreement / conflict
- Evidence Coverage
- Family Coverage
- Independent Family Count
- Per-family direction summary

Default user-facing Recommendation Insight:
- Signal Strength
- Confidence
- Signal Alignment
- Plain-English `Why this confidence?` explanation

Technical metrics remain available behind `How was this calculated?` and info controls. The default UI must not expose engine jargon when a clearer investor-facing term exists.

## Current stock context / Stock DNA

Preferred baseline: one trading year of daily price and volume history. If long-history data is unavailable, the engine falls back to the short Trader snapshot rather than blocking the recommendation.

Current Stock DNA inputs:
- Typical normalized daily ATR%.
- Recent and typical annualized realized volatility.
- Current volatility percentile versus the stock's own history.
- 20D and 60D average daily volume.
- Daily-volume variability and 20D/60D volume trend.
- 20D and 60D trend efficiency.
- Short-window relative volume and trend efficiency for the active Trader analysis.

The engine separates **Stock Type** (Steady / Balanced / Volatile structural behavior) from **Volatility Now** (Calm / Normal / Elevated relative to that stock's own history). This context changes evidence weights; it does not create a Buy/Sell signal by itself.

Same-time-of-day historical RVOL is intentionally deferred until the data provider supplies real prior intraday sessions at matching clock offsets. Daily data must not be used as a fake substitute.

## Strategy model

### Trader
Minutes to days. Technical, volume, volatility, market regime and event-aware. Active.

### Swing
Days to weeks. Multi-timeframe trend, support/resistance, volume confirmation, market/sector regime and event-aware. Planned.

### Investor
Months to years. Fundamentals, valuation, growth, quality, revisions, competitive position and long-term technical context. Planned.

The same stock may legitimately have different conclusions for all three strategies.

## Feature research rule

Before major features are designed:
1. Compare leading competing products using current public sources.
2. Identify what they do well.
3. Identify what TradePilot AI can make more adaptive, transparent or useful.
4. Design the architecture before coding.
5. Avoid adding a feature merely because competitors have it.

## Historical-validation discipline

When the brain begins learning from historical effectiveness:
- Separate training and validation data.
- Prefer walk-forward evaluation.
- Track out-of-sample results.
- Avoid repeatedly optimizing against the same backtest period.
- Do not promote a signal weight because of an attractive in-sample result alone.

## Development workflow

- Complete files / coherent implementation packages.
- Keep implementation packages compile-ready.
- Run dart format.
- Run flutter analyze.
- Run flutter test.
- Test the feature visually.
- Commit and push each completed release.
- Tag meaningful milestones.
- Update this Bible for major architectural decisions.

## Immediate brain roadmap

1. v0.4 — Relative Volume + short-window Stock Behavior context. Done.
2. v0.5 — Strategy-aware Consensus Engine, evidence-family de-duplication and Recommendation Insight. Done.
3. v0.6 — One-year Historical Context / Stock DNA foundation. Done.
4. v0.7 — Multi-timeframe Trader intelligence + market/sector relative strength. Done.
5. v0.8 — Advanced Trader evidence + selectable Trader primary analysis interval with strategy-specific timeframe policy. Done.
6. v0.9 — Historical Setup Validation / similar-case confidence overlay. Current.
7. v0.10 — Broader market regime, earnings/events and news/sentiment.
8. v1.0 — Swing and Investor brains.
9. v1.x — Real historical setup database, walk-forward calibration and AI Analyst / Mentor grounded in deterministic analysis.

## UI roadmap

Current UI remains functional/provisional. A dedicated commercial look-and-feel redesign will occur after the product intelligence is sufficiently mature.


## Multi-Timeframe / Market Context

Trader context uses a hierarchy rather than equal timeframe votes. The user selects the **Primary Analysis Interval** inside Trader Analysis Context; confirmation and broader-backdrop intervals are chosen automatically so the strategy remains coherent. Current Trader choices are 1m, 5m, 15m, 30m and 1h, with 5m as the default.

Examples:
- 1m primary → 5m confirmation → 1h broader backdrop.
- 5m primary → 1h confirmation → 1d broader backdrop.
- 15m primary → 1h confirmation → 1d broader backdrop.
- 30m / 1h primary → 4h confirmation → 1d broader backdrop.

The visual Price History range remains independent. Changing 1D/5D/1M/3M/1Y does not recalculate the recommendation; changing the Primary Analysis Interval does.

Future strategy defaults are intentionally different: Swing defaults to daily analysis with weekly/monthly context; Investor defaults to weekly technical context with monthly/quarterly backdrop, while fundamentals remain the dominant Investor inputs. Investor technical timeframes are therefore secondary rather than the main recommendation driver.

Higher-timeframe trend remains part of the Trend evidence family. Market/sector relative strength is a separate Market Context family. The user-facing label is Market Environment. Strategy Summary comes before Analysis Context so the selected strategy always establishes the meaning of the detailed context below it. Context may strengthen or weaken confidence but never replaces the full deterministic evidence set.


## Advanced Trader evidence rule

v0.8 expands provider-level detail without multiplying independent confidence. Trend contains Candle Trend, EMA Structure and Multi-Timeframe Trend; Momentum contains RSI and MACD; Participation contains Relative Volume and Volume Confirmation; Price Structure contains VWAP Position and Support & Resistance; Price Extension belongs to Volatility. The default Evidence UI groups providers by evidence family and keeps provider detail expandable. A bullish trend can be opposed by extension/entry-risk evidence without claiming the trend itself has reversed.


## Recommendation attribution rule

Every strategy recommendation must be able to explain both **direction** and **confidence** quantitatively. Direction influence and confidence contribution are separate concepts. Family-level percentages are shown first; exact provider-level impact remains expandable. Attribution must reconcile to the same deterministic Consensus Engine math used to create the recommendation. Correlated providers remain capped inside their evidence family, so adding another EMA/trend-style signal cannot manufacture extra independent influence. Confidence attribution must also show the global coverage, alignment and reliability adjustments that transform evidence strength into final confidence.


## Historical Setup Validation rule

Historical validation is an **external validation overlay**, not another evidence family. It is derived from the same current evidence, so counting it as an independent signal would double-count the setup.

The current setup fingerprint uses strategy/timeframe, de-duplicated evidence-family direction/strength, Stock DNA, volatility regime, Market Environment and Relative Strength. Historical outcomes are then evaluated only after the setup state is fixed. Future price data must never enter the fingerprint.

The layer reports similar-case count, effective sample size, match quality, similar-setup follow-through, a context-matched same-stock follow-through baseline, Historical Difference, median forward/directional move and favorable/adverse excursion. Historical setup analogs must share the current Stock Profile as a hard eligibility rule. The same-stock baseline must share strategy, analysis interval, Stock Profile, volatility regime and Market Environment, while deliberately not requiring today's specific evidence setup. Positive historical credit is allowed only when matched follow-through exceeds both 50% and this context-matched stock baseline.

Historical validation may adjust **confidence only**, currently capped at ±8 points. It cannot alter recommendation direction by itself. Evidence/provider attribution reconciles to evidence-derived confidence; the historical adjustment is displayed separately before final confidence.

The v0.9 mock provider is explicitly synthetic development data. It validates architecture and UX, not real-world performance. Production use requires a real historical setup/outcome store plus out-of-sample/walk-forward validation before any learned calibration can influence live weights.

## Historical Validation Scoring Principle

TradePilot AI must not treat all historical measurements as equally informative. Historical setup validation prioritizes the difference versus the context-matched same-stock baseline, then uses directional follow-through, normalized outcome magnitude, and excursion quality as supporting dimensions. Statistical sample depth and match quality are reliability gates rather than additional votes. The UI must expose the configured historical weights and reliability factors so the confidence adjustment is auditable.
