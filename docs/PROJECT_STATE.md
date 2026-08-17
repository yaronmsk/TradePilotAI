# TradePilot AI Project State

Document ID: TP-012
Version: 1.2
Status: Active
Last Updated: 2026-08-17
Primary Branch: develop

## Current release baseline

Committed baseline before this package: v0.6.0 — Historical Stock DNA / Adaptive Context Engine.

Release currently being prepared: v0.7.0 — Multi-Timeframe + Market Context Intelligence.

## Current phase

Brain-first feature development.

The priority is recommendation quality, stock-specific context and explainability. UI remains functional/provisional until the analysis capability is mature enough for a dedicated commercial design phase.

## Implemented product capabilities

### Market / dashboard
- Persistent watchlist.
- Symbol-specific deterministic mock market behavior.
- Market Status with historical chart.
- Independent 1D / 5D / 1M / 3M / 1Y chart range.
- Chart range does not recalculate recommendation evidence.
- Fixed one-year daily history feed for Stock DNA, separate from visual chart selection.

### Recommendation brain
- Candle Trend evidence.
- Multi-Timeframe Trend evidence using Trader-specific Primary / Confirmation / Regime roles.
- RSI evidence.
- Relative Volume evidence.
- Market & Sector Context evidence using stock-vs-market and stock-vs-sector relative performance.
- Evidence families: Trend, Momentum, Participation and Market Context.
- Family-level Consensus Engine with correlated-evidence protection.
- Direction score separated from confidence.
- Bullish support, bearish support, agreement and conflict.
- Provider coverage and evidence-family coverage.
- Strategy-aware Recommendation Insight with Signal Strength, Confidence and Signal Alignment.
- Technical consensus details behind explainability controls rather than six default jargon-heavy boxes.

### Historical Context / Stock DNA
- Preferred one-year daily historical baseline with short-snapshot fallback.
- Typical normalized daily ATR%.
- Current vs historical realized-volatility percentile.
- 20D and 60D average daily volume.
- Daily-volume variability.
- 20D/60D volume trend ratio.
- 20D/60D trend efficiency.
- Structural Stock Type: Steady / Balanced / Volatile.
- Current Volatility Regime: Calm / Normal / Elevated relative to the stock's own history.
- Stock-DNA-aware weighting for RSI, Candle Trend and Relative Volume.
- User-facing Stock DNA card with plain-English explanation and technical detail on demand.

### Strategy model
- Trader — active.
- Swing — planned / Coming Soon.
- Investor — planned / Coming Soon.
- Strategy Summary is the master context selector for detailed analysis.
- Recommendation, Recommendation Insight, Evidence and Risk are explicitly strategy-labeled.

## Current architecture

Primary market snapshot + fixed historical baseline
→ Stock DNA / current volatility regime
→ Strategy timeframe context (5m / 1H / 1D for Trader)
→ Broad-market and sector relative context
→ Evidence providers
→ Contextual evidence adjustment
→ Evidence report
→ Evidence-family aggregation
→ Consensus Engine
→ Strategy-specific recommendation
→ Explainability / presentation
→ Future AI Analyst / Mentor

## Validation status

v0.4.0 was validated with 122 passing tests.

v0.5.0 was validated with at least 131 passing tests before the Recommendation Insight refinement.

v0.6.0 was validated with 147 passing tests and committed/tagged.

v0.7.0 must be validated on the development Mac with:

```bash
./tools/validate-release-0.7.sh
```

Expected validation sequence:
- dart format
- flutter analyze
- flutter test

## Current limitations

- Market and historical data remain mocked.
- Same-time-of-day historical RVOL is not yet implemented; it requires real prior intraday sessions at matching clock offsets.
- Stock DNA uses one-year daily history, not yet sector/peer percentiles.
- Earnings-gap and general gap-behavior profiling are not yet implemented.
- Swing recommendation engine is not implemented.
- Investor fundamental engine is not implemented.
- Earnings/events and news/sentiment are not yet connected.
- v0.7 market/sector context still uses deterministic mock benchmark data and a mock security-to-sector resolver.
- AI explanation is not yet connected.

## Next planned brain work

1. Validate and checkpoint v0.7.0.
2. v0.8 — richer Trader evidence: MACD, EMA/SMA structure, ADX/trend quality, VWAP and support/resistance with explicit family de-duplication.
3. v0.9 — broader environment: breadth, volatility index/risk regime, earnings/events and news/sentiment.
4. v1.x — Swing and Investor brains plus out-of-sample historical setup validation and AI Analyst/Mentor.

## Permanent rules

- Research major competitor implementations before designing major features.
- Do not turn the brain into a simple indicator majority vote.
- Correlated evidence cannot create artificial confidence.
- Treat steady and volatile stocks differently using stock-specific historical context.
- Separate structural stock behavior from the current volatility regime.
- Do not fake data that the provider does not actually have.
- Direction and confidence remain separate.
- Every detailed analysis output belongs to Trader, Swing or Investor.
- AI explains deterministic analysis; AI does not invent recommendations.
- Keep presentation replaceable without rewriting domain/business logic.
