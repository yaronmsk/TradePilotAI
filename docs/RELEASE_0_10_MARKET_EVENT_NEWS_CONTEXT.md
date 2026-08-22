# TradePilot AI v0.10 — Market, Event & News Context

## Objective

Make the Trader brain aware of external conditions that can strengthen, weaken or invalidate an otherwise attractive stock-local setup.

## New brain inputs

### Market Breadth

User-facing purpose: show whether broad participation supports the headline market move.

Brain role:
- Evidence family: Market Context.
- De-duplicated with the existing Market & Sector Context provider.
- Uses broad advancing participation, medium-term participation, sector participation and volatility-regime pressure.

### Event Risk

User-facing purpose: surface scheduled catalysts such as earnings or high-impact macro events.

Brain role:
- Confidence-only modifier.
- Cannot change recommendation direction directly.
- Penalty is capped at 12 confidence points.
- Appears separately in confidence attribution as `Upcoming event risk`.

### News Sentiment

User-facing purpose: summarize the directional tone of recent company-specific news.

Brain role:
- Evidence family: Sentiment.
- Reliability uses article count, independent source count, freshness and materiality.
- Low source diversity makes the evidence unavailable rather than allowing repeated headlines to create artificial conviction.

## UI

Trader Analysis Context now includes:
- Timeframe Alignment
- Market Environment
- Market Breadth
- Relative Strength
- Event Risk
- News Sentiment

The info dialog explains which inputs affect direction and which affect confidence only.

## Development-data warning

v0.10 uses `MockExternalContextProvider`. Breadth, earnings/macro timing and news sentiment are synthetic development values. They validate orchestration, de-duplication, confidence modifiers and UI only.
