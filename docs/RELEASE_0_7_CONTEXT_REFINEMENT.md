# TradePilot AI v0.7 — Analysis Context UX Refinement

This refinement keeps the v0.7 brain logic unchanged and improves the presentation hierarchy and terminology.

## Changes

1. Strategy Summary is shown before Analysis Context.
   - The user first selects Trader, Swing or Investor.
   - All detailed context below belongs explicitly to that selected strategy.

2. `Market Backdrop` is renamed to `Market Environment` in the user interface.
   - The meaning is unchanged: it describes whether the broad market and relevant sector are supportive, neutral or challenging.
   - Relative Strength remains separate and describes how the stock performs versus those benchmarks.

3. Trader timeframe wording is clarified.
   - `Short-term trend (5-minute candles)`
   - `Near-term trend (1-hour candles)`
   - `Daily backdrop (1-day candles)`

The interval wording is intentional. The engine analyzes multiple candles in each timeframe, so labels such as `Last 5m` would incorrectly imply that only the previous five minutes are being analyzed.

## Permanent UX rule

Strategy selection establishes the context for every detailed recommendation, analysis-context, evidence, risk and AI explanation section that follows.
