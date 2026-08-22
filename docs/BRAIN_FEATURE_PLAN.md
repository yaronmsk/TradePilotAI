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
Horizon: days to weeks.

Primary families:
- Daily/weekly trend alignment.
- Momentum.
- Support/resistance.
- Participation.
- Relative strength.
- Market/sector regime.
- Earnings/event risk.

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

### v1.0 — Swing + Investor Engines
Separate strategy-specific data and logic, all visible in the Strategy Summary.

### v1.x — Historical Calibration + AI Analyst
Replace development historical analogs with real setup/outcome data, add walk-forward/out-of-sample calibration, “what would change this recommendation?”, and AI explanations grounded only in deterministic evidence plus validated history.
