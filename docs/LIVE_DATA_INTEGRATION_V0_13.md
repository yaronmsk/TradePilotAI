# TradePilot AI — v0.13 Live Data Integration

**Status:** Active  
**Baseline:** v0.12.0 released; v0.13.0 Personal Android Beta in progress  
**Provider feasibility completed:** 2026-09-05

## Provider decision

Batch 0 validated the first production-oriented data-source split:

- **Twelve Data** for Trader/Swing market OHLCV.
- **SEC EDGAR / data.sec.gov** for the first Investor reported-fundamentals
  slice.
- Keep both behind TradePilot-owned vendor-neutral interfaces.

Observed AAPL feasibility result:

- Twelve Data quote: PASS.
- Twelve Data 1min / 5min / 1h / 1day / 1week OHLCV: PASS.
- SEC Company Facts: PASS.
- SEC required first-slice fundamental concept groups: 12/12 found.

No paid Twelve Data upgrade is required for the first development slice.

## Twelve Data budget discovered in Batch 0

The development Basic account exposed an 8-credit/minute limit.

TradePilot therefore uses a local safety budget of 7 credits/minute and a
shared symbol+interval cache.

The gateway uses Twelve Data `/time_series` for snapshots rather than combining
`/quote` + `/time_series`. The latest normalized candle supplies current price
and volume, saving one provider request per snapshot.

## Gateway contract

The Flutter app depends only on normalized TradePilot endpoints:

- `/v1/market/snapshot`
- `/v1/market/history`

Vendor API keys never enter Flutter source or release APKs.

`LIVE` and `PARTIAL_LIVE` data may cross the live provider boundary.
`STALE`, `DATA_ERROR` and `SYNTHETIC` remain blocked by the Flutter live
providers created in Batch 1.

## Batch 2 cache strategy

TradePilot's existing recommendation context is intentionally preserved.

For default Trader/AAPL analysis, unique provider series are:

1. AAPL 5m
2. AAPL 1h
3. AAPL 1d
4. SPY 1h
5. SPY 1d
6. XLK 1h
7. XLK 1d

The chart's AAPL 5m history reuses the primary series. Stock DNA AAPL 1Y
history reuses the daily series.

This keeps the existing multi-timeframe and market/sector context intact while
fitting the current 7-credit TradePilot safety budget.

## Timestamp rule

Intraday Twelve Data requests explicitly ask for UTC.

Daily/weekly/monthly provider values are date labels returned in exchange-local
time. The gateway attaches the provider's exchange timezone to local midnight
and converts that label to UTC for deterministic ordering. This does not claim
that midnight is the market close tick.

## Intentionally deferred

- 3-month candle aggregation: not implemented until a tested aggregation policy
  is defined.
- market-calendar-aware stale detection: later v0.13 safety batch.
- production gateway authentication/hosting: before physical Android live use.
- SEC Investor parser: later v0.13 batch.
- monitoring and notifications: v0.14.0.
