# TradePilot AI Project Bible

Version: 1.3
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
→ Strategy timeframe context (Trader: 5m Primary / 1H Confirmation / 1D Regime)
→ Broad-market / sector relative context
→ Stock behavior profile
→ Evidence providers
→ Contextual evidence adjuster
→ Evidence report
→ Evidence-family aggregation
→ Consensus Engine
→ Strategy-specific recommendation
→ Presentation / explainability
→ Future AI Analyst / Mentor

## Current implemented evidence

- Candle Trend — Trend family
- Multi-Timeframe Trend — Trend family (same family by design; higher timeframes cannot create duplicate independent votes)
- RSI — Momentum family
- Relative Volume — Participation family
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
4. v0.7 — Multi-timeframe Trader intelligence + market/sector relative strength. Current.
5. v0.8 — MACD, EMA/SMA, ADX, VWAP and support/resistance with evidence-family de-duplication.
6. v0.9 — Market regime, earnings/events, news/sentiment.
7. v1.0 — Swing and Investor brains.
8. v1.x — Historical setup similarity, walk-forward calibration and AI Analyst / Mentor grounded in deterministic analysis.

## UI roadmap

Current UI remains functional/provisional. A dedicated commercial look-and-feel redesign will occur after the product intelligence is sufficiently mature.


## Multi-Timeframe / Market Context

Trader context uses a hierarchy rather than equal timeframe votes. User-facing wording emphasizes role and candle interval rather than a bare timeframe label:
- Short-term trend (5-minute candles) — Primary
- Near-term trend (1-hour candles) — Confirmation
- Daily backdrop (1-day candles) — Regime

Higher-timeframe trend remains part of the Trend evidence family. Market/sector relative strength is a separate Market Context family. The user-facing label is Market Environment. Strategy Summary comes before Analysis Context so the selected strategy always establishes the meaning of the detailed context below it. Context may strengthen or weaken confidence but never replaces the full deterministic evidence set.
