# TradePilot AI Brain Feature Plan

Research checkpoint: August 2026

## Product objective

The brain must answer a harder question than “what do the indicators say?”

It must answer:

> Given this strategy horizon, this stock's normal behavior, the current market regime, the quality and independence of the evidence, and known event/fundamental context, what conclusion is justified and how certain should we be?

## Data layers

### 1. Stock-specific historical context

Purpose: distinguish a structurally solid/steady stock from a structurally volatile stock, and distinguish both from a temporary volatility regime.

Planned inputs:
- 20/60/252-day ATR% distributions.
- Realized volatility percentiles.
- Daily volume distributions.
- Same-time-of-day intraday volume baselines.
- Gap frequency and gap size.
- Trend persistence / directional efficiency history.
- Drawdown behavior.
- Earnings-day volatility.

Output: long-horizon Stock DNA + current regime.

### 2. Price/trend structure

Trader/Swing inputs:
- Candle trend.
- EMA/SMA structure.
- MACD.
- ADX/trend quality.
- VWAP/anchored VWAP where appropriate.
- Support/resistance and breakout structure.

All related indicators map into evidence families so several price-derived signals cannot create artificial confidence.

### 3. Participation / volume

- Relative Volume.
- Same-time Relative Volume for intraday analysis.
- Price/volume confirmation.
- Accumulation/distribution-style behavior where data quality supports it.
- Future order-flow/volume-delta data only if the data source is reliable and licensing permits it.

### 4. Volatility / risk

Volatility is primarily context and risk, not directional evidence by itself.

- ATR% and normalized volatility.
- Volatility regime vs own history.
- Gap risk.
- Earnings/event risk.
- Future implied volatility when reliable options data is available.

Volatility changes thresholds, evidence weights, stop/risk interpretation and confidence.

### 5. Market and sector context

- Index trend/regime.
- Market breadth.
- Sector trend.
- Stock relative strength vs market and sector.
- Risk-on/risk-off context where measurable.

A bullish stock signal should not be interpreted identically in a strong market and a broad risk-off regime.

### 6. Events / information context

- Earnings date proximity.
- Earnings surprise and revisions.
- Material company events.
- News sentiment with source quality and freshness.
- Analyst revisions as context, not unquestioned truth.

### 7. Fundamentals for Investor

Investor evidence is intentionally different from Trader evidence:
- Revenue/EPS growth.
- Free cash flow.
- Margins.
- Debt/liquidity.
- ROIC/capital efficiency.
- Valuation vs own history and peers.
- EPS/revenue revisions.
- Quality and competitive durability proxies.
- Long-term relative strength as supporting context, not the core thesis.

## Strategy-specific logic

### Trader
Horizon: minutes to days.

Primary families:
- Trend.
- Momentum.
- Participation.
- Volatility context.
- Market/sector context.
- Event risk.

### Swing

Horizon:

**Days to weeks.**

Current release:

**v0.11.0 — Swing Strategy Brain**

Status:

**Active development / Batches 1-4 implemented and validated.**

Swing remains Coming Soon in the UI until a real strategy-specific Swing recommendation has been implemented and validated.

Detailed evidence, capability and acceptance contract:

`docs/SWING_STRATEGY_BRAIN_V0_11.md`

Swing is not Trader logic running on slower candles.

### Approved Swing timeframe hierarchy

Default:

- 1D primary.
- 1W confirmation.
- 1M regime.

Alternate:

- 4H primary.
- 1D confirmation.
- 1W regime.

### Primary Swing analytical areas

- Multi-timeframe trend alignment.
- Trend structure.
- Momentum.
- Support/resistance.
- Breakout/breakdown structure.
- Participation and volume confirmation.
- Relative strength.
- Market and sector regime.
- Market breadth.
- Volatility.
- Entry-quality / price-stretch context.
- Reliable/material news context.
- Scheduled event risk.
- Strategy-specific Historical Setup Validation.

### Evidence applicability rule

No Trader evidence provider is automatically enabled for Swing.

Every existing evidence provider and capability requires an explicit decision covering:

- Whether Swing should use it.
- Why it matters.
- Correct timeframe/lookback.
- Calculation/threshold changes.
- Direction impact.
- Confidence impact.
- Risk or entry-quality impact.
- Evidence-family relationship.
- BUY/SELL behavior.
- Human-readable presentation.
- Individual info/explainability path.
- Attribution behavior.
- Limitations.

### Current approved evidence decisions

- Candle Trend — reuse with Swing calibration.
- EMA Structure — reuse with Swing calibration.
- Multi-Timeframe Trend — core Swing evidence.
- RSI — reuse with trend/regime-aware Swing interpretation.
- MACD Momentum — reuse with Swing calibration.
- Relative Volume — conditional reuse; 4H must not fabricate same-time-of-day normalization.
- Volume Confirmation — reuse with Swing calibration.
- Current analysis-window VWAP Position — excluded from initial Swing scoring.
- Support & Resistance — core Swing evidence with confirmation-aware semantics.
- Price Extension — primarily entry-quality/confidence/risk context; must not automatically claim reversal.
- Market & Sector Context / Relative Strength — core Swing evidence.
- Market Breadth — reused within Market Context.
- News Sentiment — reuse with Swing-specific freshness/materiality.
- Event Risk — confidence/risk-only; maximum 12-point penalty and no positive bonus.
- Stock DNA — core contextual input and must become strategy-aware.
- Historical Setup Validation — confidence-only, strategy/timeframe-specific and bounded to ±8 points.

### Current v0.11 implementation checkpoint

Completed through Batch 4:

- Strategy-aware evidence policy and execution gates.
- Swing 1D -> 1W -> 1M and 4H -> 1D -> 1W timeframe orchestration.
- Trend family:
  - Candle Trend.
  - EMA Structure.
  - Multi-Timeframe Trend.
- Momentum family:
  - RSI.
  - MACD Momentum.
- Participation family:
  - Relative Volume.
  - Volume Confirmation.
- Price Structure family:
  - Support & Resistance.
- Volatility / Entry Quality:
  - Price Extension — zero Swing directional influence.
- Current analysis-window VWAP remains excluded from Swing.
- Family de-duplication boundaries remain intact.
- Trader regression behavior remains protected.
- Swing recommendation activation remains intentionally blocked.

Batch 4 functional validation baseline:

- Flutter analyzer clean.
- 113 provider tests passing.
- 404 total automated tests passing.

Next implementation batch:

**Batch 5 — Market Context, Sentiment, Stock DNA and Event Risk.**

### Swing UI / explainability rules

Every Swing card, evidence item, metric, decision helper and recommendation input must be understandable in plain human language.

Every individual analytical input/value requires its own visible info/explainability path.

The normal UI should show the human meaning first and technical details second.

Direction attribution must reconcile to **100%** of active effective directional influence after evidence-family de-duplication and caps.

Provider attribution must reconcile to the capped family contribution.

Confidence attribution remains separate from direction attribution.

Confidence-only modifiers such as Event Risk and Historical Setup Validation remain explicit bounded point adjustments rather than fake percentages.

Decision helpers may summarize already-counted evidence but must not create another independent vote.

### Investor
Horizon: months to years.

Primary families:
- Growth.
- Profitability/quality.
- Financial strength.
- Valuation.
- Revisions.
- Competitive/industry context.
- Long-term market/technical context.

## Solid vs volatile stock logic

A universal RSI/ATR/volume threshold is not enough.

The planned Stock DNA model separates:

Structural profile:
- What is normal for this stock over months/years?

Current regime:
- What is unusual right now relative to that normal profile?

Example:
- A 3% daily move may be exceptional for a historically steady stock but ordinary for a high-volatility small cap.
- RSI 75 may be a meaningful stretch in a mean-reverting stock but can persist during a strong momentum regime.
- 1.8x volume may be highly unusual for one stock and routine around recurring events for another.

The brain therefore uses percentiles/relative baselines and changes evidence weights according to structural profile + current regime.

## Validation before self-improving weights

TradePilot AI must not “learn” by repeatedly fitting the same history.

Before historical performance can modify live weights:
- Define the signal before evaluation.
- Use separate training and validation windows.
- Use walk-forward testing.
- Track out-of-sample performance.
- Penalize small samples.
- Track regime dependence.
- Avoid promoting correlated signals as independent discoveries.
- Preserve deterministic audit trails for every weight change.

## Release sequence

### v0.5 — Strategy-Aware Consensus Engine
Family de-duplication, conflict/agreement, direction vs confidence, explicit strategy context.

### v0.6 — Historical Context / Stock DNA
Long-term baselines, structural volatility, same-time volume foundation, current-vs-normal regime.

### v0.7 — Multi-Timeframe + Market Context Intelligence
Trader timeframe hierarchy, higher-timeframe alignment, stock-vs-market and stock-vs-sector relative strength, and Market Context evidence.

### v0.8 — Advanced Trader Evidence
EMA Structure, MACD Momentum, Volume Confirmation, analysis-window VWAP, ATR-normalized support/resistance and Price Extension with explicit family de-duplication and grouped evidence presentation.

ADX/Bollinger-style additions remain deferred until historical validation demonstrates incremental value beyond existing trend-efficiency and volatility context.

### v0.9 — Historical Setup Validation
Current setup fingerprint, similarity-weighted historical analogs, matched outcomes versus a control baseline, effective sample size, excursion statistics and a bounded confidence-only overlay. Development starts with a synthetic provider behind a replaceable interface; real performance claims are forbidden until real historical data is connected and validated out of sample.

### v0.10 — Market / Sector / Event Context
Market breadth participation, scheduled earnings/macro event risk and reliability-weighted news sentiment. Market Breadth remains inside the Market Context family; Event Risk is a confidence-only overlay; News Sentiment is a capped Sentiment family. Development uses a synthetic provider until licensed live data is connected.

### v0.10.1 — Explainability & Bidirectional Audit
Reusable explainability contracts, explicit semantic roles, individual Analysis Context explainability, supportive/opposing interpretation rules, confidence-only modifier boundaries and automated architecture invariants.

Completed safeguards include:
- Complete explainability metadata for every production evidence kind.
- Individual explainability for all seven Trader Analysis Context metrics.
- Directional/evaluative, confidence/risk-only and context/configuration semantic roles.
- Event Risk confidence-only behavior with a hard maximum 12-point penalty and no positive bonus.
- Historical Setup Validation confidence-only behavior with a hard ±8-point adjustment boundary.
- Evidence-family de-duplication and direction/confidence separation preserved.
- BUY/SELL provider regression coverage preserved.

### v0.11.0 — Swing Strategy Brain

Activate Swing as TradePilot AI's second real strategy.

Includes:

- Strategy-aware analysis/evidence policy.
- Swing-specific provider applicability.
- Swing-specific provider calibration.
- Swing timeframe/context orchestration.
- Strategy-aware Stock DNA adjustment.
- Swing-specific Event Risk relevance.
- Swing-specific Historical Setup Validation horizon.
- Swing recommendation policy.
- Reconciled direction attribution.
- Separate confidence attribution.
- Human-readable Swing cards and decision helpers.
- Individual info paths for every user-facing analytical input.
- BUY/SELL parity and regression protection.

### v0.12.0 — Investor Strategy Brain

Introduce the dedicated long-horizon Investor engine.

Planned analytical families include:

- Growth.
- Profitability / Quality.
- Financial Strength.
- Valuation.
- Revisions.
- Competitive / industry context.
- Long-term market and technical context.

Investor must use strategy-specific fundamental logic rather than reusing Swing or Trader semantics.

### v1.0.0 — Validated Multi-Strategy Milestone

TradePilot AI reaches the v1.0.0 strategy milestone when:

- Trader is implemented and validated.
- Swing is implemented and validated.
- Investor is implemented and validated.
- Each strategy has independent horizon-appropriate evidence and recommendation logic.
- Strategy Summary cleanly switches between real strategy recommendations.
- Explainability, attribution, BUY/SELL parity and data-honesty rules remain consistent across strategies.

### v1.x — Historical Calibration + AI Analyst
Replace development historical analogs with real setup/outcome data, add walk-forward/out-of-sample calibration, “what would change this recommendation?”, and AI explanations grounded only in deterministic evidence plus validated history.
