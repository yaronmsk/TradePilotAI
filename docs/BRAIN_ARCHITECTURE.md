# TradePilot AI Brain Architecture

Version: 0.5 strategy-aware consensus
Status: Living design

## Core rule

A recommendation is not an indicator vote. It is a strategy-specific, context-aware conclusion built from independent evidence families whose meaning and weight change according to the stock, market regime, timeframe, data quality and investment horizon.

## Decision pipeline

Market data
→ Stock behavior profile
→ Evidence providers
→ Contextual evidence weighting
→ Evidence report
→ Evidence-family aggregation
→ Consensus Engine
→ Strategy-specific recommendation
→ Deterministic explanation
→ Future AI Mentor / Analyst explanation

## Strategy ownership

Every detailed output must belong to a StrategyType:
- Trader — Hours to Days
- Swing — Days to Weeks
- Investor — Months to Years

The Strategy Summary is the master context selector. Selecting a strategy controls the Recommendation, Recommendation Insight, Evidence, Risk and future AI explanation below it.

The same stock can legitimately be:
- Sell for Trader
- Hold for Swing
- Buy for Investor

These are not contradictions because the horizons, data and decision rules differ.

## Evidence families

Evidence is grouped by the economic/market behavior it measures rather than treated as an unlimited collection of votes.

Current families:
- Trend
- Momentum
- Participation

Reserved future families:
- Volatility
- Market Context
- Fundamentals
- Sentiment
- Other

Current mappings:
- Candle Trend → Trend
- RSI → Momentum
- Relative Volume → Participation

Future example:
- EMA, SMA, MACD trend component and Candle Trend may all contain overlapping trend information. Adding all of them must improve detail, not multiply trend voting power four times.

## Family de-duplication rule

Inside each family:
- All usable signals influence the family's direction and strength.
- Internal agreement is measured.
- Reliability remains relevant.
- The family's final influence is capped by the strongest effective evidence weight in that family.

Therefore adding another correlated indicator can refine a family conclusion but cannot linearly multiply that family's influence.

## Consensus outputs

The Consensus Engine exposes:
- Direction Score: -100 bearish to +100 bullish.
- Confidence: 0–100 evidence quality/coverage/agreement score.
- Bullish Support.
- Bearish Support.
- Agreement.
- Conflict.
- Provider Coverage.
- Family Coverage.
- Independent Family Count.
- Per-family direction, strength, reliability and evidence count.


## Presentation rule: simple first, technical on demand

The Consensus Engine may calculate detailed internal metrics, but the default investor-facing surface must remain understandable. The primary Recommendation Insight presents only:
- Signal Strength — how strongly the combined evidence leans bullish or bearish.
- Confidence — how much trust the engine places in the conclusion after coverage, alignment and reliability adjustments.
- Signal Alignment — whether independent evidence groups agree.

Agreement, conflict, family coverage, provider coverage, reliability and per-family internals are preserved behind `How was this calculated?` and info controls. Confidence must be described as model confidence, not a guaranteed probability of profit.

## Direction is not confidence

Examples:

BUY
- Direction: +58 bullish
- Confidence: 61%

This means bullish evidence leads, but the evidence quality, breadth or agreement is only moderate.

HOLD
- Direction: +2 neutral
- Confidence: 78%
- Conflict: high

This can be valid when strong independent bullish and bearish families cancel each other. The engine may be highly confident that there is no clear directional edge.

## Stock-normalized analysis

TradePilot AI should prefer comparisons against a stock's own normal behavior over universal thresholds whenever possible.

Examples:
- Current volume vs recent average volume.
- Intraday volume vs the same time-of-day across previous sessions.
- ATR% vs the stock's historical ATR%.
- Current volatility vs its historical volatility regime.
- Momentum and trend persistence vs the stock's own history.

## Current context-aware weighting

Implemented in v0.4 and consumed by v0.5:
- RSI is discounted when a stock is volatile or strongly directional.
- Candle Trend is boosted when a volatile stock moves with high directional efficiency.
- Candle Trend is discounted when a volatile stock is noisy.
- Relative Volume receives more weight when current volume is materially abnormal.

## Brain roadmap

### v0.6 — Historical Context / Stock DNA foundation
- Separate short-term regime from long-term stock personality.
- 20/60/252-day volatility baselines.
- Daily and same-time-of-day volume baselines.
- Volatility percentiles rather than only fixed thresholds.
- Trend persistence and gap behavior.

### v0.7 — Multi-factor Trader intelligence
- EMA/SMA structure.
- MACD.
- ADX / trend quality.
- VWAP.
- Support/resistance.
- Relative strength vs market and sector.
- Multi-timeframe alignment.

### v0.8 — Event and market context
- Earnings calendar/risk.
- News and sentiment.
- Market breadth/regime.
- Sector context.

### v0.9 — Swing and Investor brains
- Swing-specific daily/weekly evidence.
- Investor fundamentals, valuation, growth, quality and revisions.

### v1.x — Historical conditional validation
- Similar-setup outcomes.
- Walk-forward / out-of-sample calibration.
- Evidence effectiveness by stock and regime.
- No live weight optimization from in-sample performance alone.

## Explainability rule

AI explains deterministic facts; AI does not invent the recommendation.

Every recommendation should eventually answer:
- What supports it?
- What opposes it?
- Which evidence families are independent?
- What evidence is redundant?
- How reliable is each input?
- How did stock context change its weight?
- What would change the recommendation?
- How did similar historical conditions perform out of sample?
