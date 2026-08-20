# TradePilot AI v0.9.0 — Historical Setup Validation

Status: Development / validation
Date: 2026-08-20

## Goal

Add a transparent historical-validation layer that asks whether setups resembling the current deterministic TradePilot recommendation historically followed through, while avoiding indicator double-counting and excessive confidence from weak backtests.

## Core architecture

Current evidence
→ evidence-family de-duplication
→ Consensus Engine
→ direction + evidence-derived confidence
→ current setup fingerprint
→ historical analog matching
→ outcome/control analysis
→ bounded historical confidence adjustment
→ final confidence

Historical validation is **not an evidence family**. It is derived from existing evidence and therefore must not receive another independent vote.

## Setup fingerprint

The fingerprint uses information available at setup time only:
- Strategy.
- Primary analysis interval.
- Independent evidence-family direction scores.
- Independent evidence-family strength scores.
- Family importance weights.
- Stock Type / Stock DNA behavior.
- Current volatility regime.
- Market Environment.
- Relative Strength state.

Provider-level duplicates are intentionally not part of the fingerprint as independent dimensions. For example, Candle Trend + EMA Structure + Multi-Timeframe Trend remain one Trend dimension.

## Similarity

The matcher emphasizes current evidence-family state while retaining stock/market regime context:
- Evidence-family direction + strength: 70%.
- Stock behavior type: 12%.
- Volatility regime: 8%.
- Market Environment: 5%.
- Relative Strength: 5%.

Current family importance weights are respected.

Same-symbol observations receive a modest statistical-weight boost because stock-specific behavior can matter, but same-symbol membership does not artificially increase similarity itself.

## Outcome measurement

Matched historical cases expose:
- Similar-case count.
- Kish effective sample size after similarity weighting.
- Average match quality.
- Same-direction follow-through rate.
- Control follow-through rate.
- Edge versus control in percentage points.
- Median raw forward move.
- Median move relative to the current signal direction.
- Median favorable excursion.
- Median adverse excursion.
- Closest historical analogs.

## Strategy-aware outcome windows

Trader:
- 1m primary → next 30 bars (~30 minutes).
- 5m primary → next 24 bars (~2 hours).
- 15m primary → next 16 bars (~4 hours).
- 30m primary → next 12 bars (~6 hours).
- 1h primary → next 8 bars (~8 hours).

Future Swing and Investor horizons are already represented by the service architecture but are not active recommendation engines yet.

## Confidence rules

Historical setup validation:
- Never changes direction score in v0.9.
- Can change final confidence by at most ±8 points.
- Cannot earn positive confidence credit unless matched same-direction follow-through exceeds 50% **and** beats the context-matched same-stock baseline.
- Reliability is reduced for weak similarity or low effective sample size.

The recommendation model now separates:
- **Evidence-derived confidence**: confidence created by the current deterministic evidence engine.
- **Final confidence**: evidence-derived confidence after bounded external validation.

Provider/family contribution percentages reconcile to evidence-derived confidence. Historical validation is displayed separately so no indicator is falsely credited for the historical adjustment.

## User experience

Trader Recommendation Insight now includes **Historical Setup Check** when validation data is available.

Default view:
- Verdict: Supports / Mixed / Opposes / Limited Data.
- Similar Cases.
- Match Quality.
- Same-Direction Follow-Through vs Control.
- Confidence Impact.

Expandable details:
- Outcome window.
- Matched vs control edge.
- Median forward/directional move.
- Median favorable/adverse excursion.
- Closest analogs.
- Data-source warning when appropriate.

## Look-ahead protection

Fingerprint attributes represent only the historical state at the setup timestamp. Forward returns/excursions are evaluated only after the fingerprint has been created. Future data must never leak into similarity inputs.

## Current data limitation

The v0.9 development provider uses deterministic **synthetic historical setup data** because the application does not yet have a licensed/authoritative long-range intraday setup-outcome database.

The UI explicitly labels this as `Development simulation` and states that the results validate architecture and UX, **not real-world strategy performance**.

The provider interface is intentionally separate so a real historical dataset can replace the mock provider without modifying the Consensus Engine or UI contract.

## Future production validation

Before historical statistics are allowed to self-adjust evidence weights:
- Use real historical market/benchmark data.
- Record exact historical setup-time inputs.
- Use time-separated/walk-forward validation.
- Track out-of-sample performance.
- Detect regime dependence.
- Penalize multiple-comparison/backtest-overfitting risk.
- Preserve a deterministic audit trail for every learned calibration.

## Final weighted historical scoring refinement

Historical outcome measurements are deliberately not equal-weighted. The final v0.9 policy uses:

- Edge versus control: 40%
- Same-direction follow-through: 20%
- Stock-behavior-normalized outcome magnitude: 20%
- Favorable-versus-adverse excursion quality: 20%

Effective sample depth and average match quality are not additional outcome votes. They are applied after the weighted outcome score as a weakest-link reliability gate. Historical validation still cannot increase confidence unless matched cases beat both the 50/50 directional baseline and the context-matched same-stock baseline, and the total historical impact remains capped at ±8 confidence points.
