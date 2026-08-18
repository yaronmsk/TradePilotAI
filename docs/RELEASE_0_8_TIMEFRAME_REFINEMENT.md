# TradePilot AI v0.8 — Strategy Analysis Timeframe Refinement

Status: Development / Validation  
Date: 2026-08-18

## Goal

Make the primary recommendation interval explicitly selectable for Trader mode while keeping the broader multi-timeframe hierarchy coherent and keeping Price History independent from recommendation analysis.

## Research takeaways

- TradingView's multi-timeframe analysis guidance treats higher-timeframe data as broader context for a lower-timeframe view rather than as a collection of unrelated votes.
- TrendSpider exposes multi-timeframe analysis and screening, reinforcing that users expect to evaluate the same setup across multiple intervals.
- Fidelity describes swing trading as a days-to-weeks activity, which supports a daily-centered Swing default rather than an intraday default.
- Schwab's chart-timeframe guidance distinguishes shorter intervals for active decisions from longer views for broader context.

## TradePilot enhancement

TradePilot does not let users independently choose every timeframe used by the brain. The user chooses one **Primary Analysis Interval** for the selected strategy; the engine automatically chooses confirmation and broader-backdrop intervals.

This avoids incoherent combinations such as a 1-minute primary signal with an arbitrary monthly confirmation, and it keeps the multi-timeframe evidence inside one Trend family so confidence is not inflated by duplicate observations.

## Current Trader policy

Default: **5m**

Selectable primary intervals:
- 1m
- 5m
- 15m
- 30m
- 1h

Automatic supporting hierarchy:
- 1m primary → 5m confirmation → 1h broader backdrop
- 5m primary → 1h confirmation → 1d broader backdrop
- 15m primary → 1h confirmation → 1d broader backdrop
- 30m primary → 4h confirmation → 1d broader backdrop
- 1h primary → 4h confirmation → 1d broader backdrop

Changing the primary interval recalculates the Trader recommendation and all primary technical evidence.

## Future Swing policy

Default primary: **1d**

Planned selectable primary intervals:
- 4h
- 1d

Hierarchy:
- 4h primary → 1d confirmation → 1w backdrop
- 1d primary → 1w confirmation → 1mo backdrop

Swing is intended for days-to-weeks decisions, so daily/weekly structure matters more than minute-level noise.

## Future Investor policy

Default technical primary: **1w**

Planned selectable technical intervals:
- 1d
- 1w

Hierarchy:
- 1d primary → 1w confirmation → 1mo backdrop
- 1w primary → 1mo confirmation → 3mo backdrop

Investor mode will not be primarily technical. Fundamentals, valuation, growth, quality, revisions and long-term business context remain the dominant inputs. The technical hierarchy is secondary context and entry timing.

## UX rules

- Strategy Summary remains the master strategy selector.
- The selected strategy's Analysis Context card appears directly below Strategy Summary.
- The Primary Analysis Interval selector lives inside Analysis Context.
- Market Status no longer labels its snapshot as the generic "Analysis timeframe".
- Recommendation details use "Primary analysis interval" and "Primary candles analyzed".
- Price History range (1D/5D/1M/3M/1Y) is visual only and does not drive recommendation recalculation.

## Reliability rule

The multi-timeframe Trend evidence remains one evidence family. More timeframes can improve interpretation and reliability, but they cannot create artificial independent-family confidence.
