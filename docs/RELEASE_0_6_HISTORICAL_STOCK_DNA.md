# TradePilot AI v0.6.0 — Historical Context / Stock DNA

Status: Development / validation  
Date: 2026-08-17

## Goal

Make the Trader recommendation brain understand how a stock normally behaves before it interprets today's technical evidence.

v0.4 introduced short-window stock context. v0.6 replaces that as the preferred baseline with up to one trading year of daily price and volume history, while preserving a short-window fallback when history is unavailable.

## Competitor research translated into product requirements

Public competitor documentation shows several useful patterns:

- TradingView Relative Volume compares current activity with historical average activity, and Relative Volume at Time compares activity at matching intraday time offsets.
- TradingView Historical Volatility and ATR expose volatility as a measurable property rather than a directional signal.
- TrendSpider Normalized ATR divides ATR by price so volatility can be interpreted proportionally rather than as an absolute dollar amount.
- TrendSpider Relative Volume compares current bar volume with prior-bar average volume.
- Seeking Alpha compares many metrics relatively and organizes them into higher-level factors rather than relying on a single raw number.

TradePilot AI's enhancement is to make historical behavior an input to the recommendation engine itself. Stock context does not produce Buy/Sell directly; it changes how much trust the brain gives to evidence such as RSI, trend and relative volume.

## New brain pipeline

Market snapshot
+
Fixed 1Y daily stock-history baseline
→ HistoricalStockProfile
→ StockBehaviorProfile / Stock DNA
→ Evidence providers
→ Contextual evidence weighting
→ Evidence-family consensus
→ Strategy-specific recommendation

The fixed Stock DNA history request is independent of the user-selected chart range. Switching the visual chart between 1D/5D/1M/3M/1Y must not recalculate recommendation evidence.

## Historical Stock DNA metrics

The long-term profile calculates:

- Typical normalized ATR% from rolling 14-session daily ATR.
- Current normalized ATR% percentile versus the stock's own daily history.
- Typical and recent annualized 20-session realized volatility.
- Current realized-volatility percentile versus the stock's own history.
- 20-session and 60-session average daily volume.
- 20D / 60D volume trend ratio.
- 60-session volume variability (coefficient of variation).
- 20-session and 60-session trend efficiency.

At least 60 valid daily sessions are required before long-term Stock DNA is treated as available.

## Structural stock type vs current regime

These are deliberately separate concepts:

### Stock Type

Long-term structural behavior:
- Steady
- Balanced
- Volatile

It is derived from the stock's typical daily normalized ATR and typical realized volatility.

### Volatility Now

Current state relative to that same stock's history:
- Calm: at or below the 25th historical volatility percentile.
- Normal: between the 25th and 75th percentiles.
- Elevated: at or above the 75th percentile.

A volatile stock can therefore be in a calm regime relative to itself, and a normally steady stock can temporarily be in an elevated regime.

## Context-aware evidence changes

### RSI

- Slightly more weight in historically steady stocks.
- Less weight in historically volatile stocks.
- Further discounted during highly directional or historically elevated-volatility conditions.

Reason: an oscillator extreme should not be interpreted identically in a steady stock and a stock where large swings are routine.

### Candle Trend

- Stronger weight when an inherently volatile stock has a clean directional path.
- Less weight when the volatile movement is noisy.
- Additional confirmation when historically elevated volatility is accompanied by directional efficiency and meaningful participation.

### Relative Volume

- Current analysis-window volume is still compared with its recent same-timeframe baseline.
- Long-term daily volume variability adds context: a moderate spike is more informative in a stock whose volume is normally stable, and less exceptional in a stock whose volume is naturally erratic.

## User-facing Stock DNA card

The dashboard now presents four simple concepts:

- Stock Type
- Volatility Now
- Typical Daily Range
- Volume Pattern

The default text explains what the behavior means. Technical values remain under `How TradePilot uses this` and an info dialog explains that Stock DNA changes evidence weighting rather than issuing a recommendation by itself.

## Graceful fallback

If one-year daily history cannot be fetched or contains fewer than 60 valid sessions:

- The recommendation engine still operates.
- The existing short-term snapshot profile is used.
- The UI labels the context as a short-term fallback rather than pretending historical Stock DNA is available.

## Intentionally not implemented in v0.6

- Same-time-of-day historical RVOL. Proper implementation requires prior intraday sessions at matching clock offsets; daily candles cannot honestly substitute for it.
- Real market data provider. The app still uses deterministic mock providers.
- Cross-sectional peer/sector volatility percentiles.
- Gap behavior and earnings-gap behavior.
- Historical predictive optimization of weights.
- Swing/Investor Stock DNA rules.

These remain planned rather than being simulated with misleading data.

## Validation

Run:

```bash
./tools/validate-release-0.6.sh
```

Then visually compare at least AAPL, MSFT, NVDA, TSLA and PLTR. The deterministic mock history is designed so steadier and more volatile symbols exercise different Stock DNA paths.
