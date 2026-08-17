# TradePilot AI v0.7.0 — Multi-Timeframe + Market Context Intelligence

Status: Development / validation
Date: 2026-08-17

## Goal

Make the Trader brain understand two things that a single 5-minute chart cannot answer:

1. Does the active short-term signal agree with the broader 1-hour and daily trend?
2. Is the stock showing stock-specific strength/weakness relative to its sector and the broad market?

The implementation is strategy-aware and deliberately avoids turning extra timeframes into extra independent votes.

## Competitor research translated into requirements

### TradingView

TradingView's Multi-Timeframe Analysis allows a ticker or indicator from a higher timeframe to be viewed in the context of a lower-timeframe chart. Its Compare tool explicitly supports benchmark comparison and comparison of companies within the same sector.

Useful pattern:
- Broader timeframe context matters.
- Benchmark comparison helps distinguish absolute movement from relative performance.

TradePilot enhancement:
- Assign each timeframe a role instead of simply displaying several charts.
- Trader mode uses 5m as Primary, 1h as Confirmation and 1D as Regime.
- Higher-timeframe trend evidence remains in the Trend evidence family, so three related trend observations cannot masquerade as three independent confirmations.
- Relative stock/sector/market behavior enters as a separate Market Context family.

Sources:
- https://www.tradingview.com/support/solutions/43000591555-leveraging-multi-timeframe-analysis/
- https://www.tradingview.com/support/solutions/43000543053-how-to-use-the-compare-tool/

### TrendSpider

TrendSpider's Market Scanner supports multiple timeframes in the same scan and describes this as a way to find opportunities that are attractive across short-, intermediate- and long-term views.

Useful pattern:
- Conditions across several timeframes can be checked together.
- Up to three timeframe layers provide a practical hierarchy for active trading.

TradePilot enhancement:
- The user does not need to manually build a multi-timeframe scan for every stock.
- The brain loads the strategy's timeframe hierarchy automatically and converts it into explainable context.
- An opposing higher timeframe reduces confirmation rather than automatically vetoing the primary signal.

Sources:
- https://help.trendspider.com/kb/scanner/multiple-timeframes-and-the-current-candle
- https://trendspider.com/learning-center/real-time-scanning/

### StockCharts

StockCharts Price Relative/Relative Strength is explicitly designed to compare a stock with a benchmark index and to evaluate a stock relative to its sector/industry. Relative Rotation Graphs extend the idea by comparing relative-strength trends across a common benchmark.

Useful pattern:
- Relative performance can identify leadership/lagging behavior that raw price direction cannot.
- Sector and broad-market comparisons provide different context layers.

TradePilot enhancement:
- Relative strength is not displayed only as a chart ratio; it becomes deterministic recommendation evidence.
- Stock-vs-market and stock-vs-sector receive the majority of the context weight.
- Sector-vs-market and broad-market direction contribute smaller environmental weights.
- Context is an independent evidence family, preserving separation from the stock's own trend/momentum indicators.

Sources:
- https://chartschool.stockcharts.com/table-of-contents/technical-indicators-and-overlays/technical-indicators/price-relative-relative-strength
- https://chartschool.stockcharts.com/table-of-contents/chart-analysis/chart-types/relative-rotation-graphs-rrg-charts

## Trader timeframe hierarchy

v0.7 defines:

- Primary: 5m — the active short-term signal.
- Confirmation: 1h — checks whether the short-term move has broader support.
- Regime: 1D — describes the larger trend environment.

Role weights:

- Primary: 45%
- Confirmation: 35%
- Regime: 20%

These weights apply inside Multi-Timeframe Trend context only. The resulting evidence stays in the Trend family and therefore remains protected by the v0.5 family de-duplication engine.

## Adaptive timeframe trend classification

A timeframe is not classified by a fixed percentage threshold alone.

For each timeframe TradePilot calculates:

- start-to-end price change,
- average candle range as a percentage of price,
- trend efficiency,
- direction and normalized strength.

A move must exceed a threshold derived from that timeframe's own average candle range before it becomes directional. This avoids treating the same raw percentage move identically in quiet and noisy conditions.

## Market / sector context

The development provider uses SPY as the broad-market proxy and deterministic sector proxies for the built-in symbols.

Current mock mappings:

- Technology: XLK — AAPL, MSFT, NVDA, AMD, PLTR
- Communication Services: XLC — GOOG
- Consumer Discretionary: XLY — TSLA

This mapping is infrastructure for deterministic testing only. A real data integration must supply authoritative security metadata instead of relying on this mock resolver.

Market Context combines:

- stock vs broad market — 45%
- stock vs sector — 35%
- sector vs market — 10%
- broad-market direction — 10%

Confirmation and regime windows are combined with 55% / 45% weighting.

The relative comparisons are normalized by the observed candle-range scale of the compared instruments rather than using one universal percentage threshold.

## New evidence

### Multi-Timeframe Trend

Family: Trend

Purpose:
- strengthen a trend family when the primary, confirmation and regime timeframes agree;
- expose mixed or opposed timeframes;
- avoid adding false independent confidence because it remains inside the existing Trend family.

### Market & Sector Context

Family: Market Context

Purpose:
- identify whether a stock is outperforming or underperforming its benchmarks;
- classify the Market Environment as Supportive, Neutral or Challenging;
- add independent environmental evidence to the Consensus Engine.

## User-facing Analysis Context

The strategy-aware card sits directly beneath Strategy Summary so the user first chooses Trader/Swing/Investor and then sees the context for that selected strategy. It intentionally uses three plain-language rows rather than a technical metric grid:

- Timeframe Alignment
- Market Environment
- Relative Strength

Trader timeframe labels distinguish role from interval:

- Short-term trend (5-minute candles)
- Near-term trend (1-hour candles)
- Daily backdrop (1-day candles)

The wording deliberately avoids implying that `5m`, `1h` or `1d` is the user's holding period. The info dialog explains that these are candle intervals and that context can strengthen or weaken confidence but does not override the complete evidence set by itself.

## Important design rule

Multi-timeframe analysis is hierarchical, not democratic.

TradePilot must never treat 5m, 1h and 1D versions of the same trend observation as three independent votes. Timeframes have strategy-specific roles, and correlated information remains in the same evidence family.

## Graceful fallback

If higher-timeframe or benchmark data cannot be loaded:

- the primary recommendation pipeline can still run;
- unavailable context evidence is reported honestly;
- confidence/coverage can reflect missing independent context rather than fabricating a value.

## Not implemented in v0.7

- Real market/sector metadata provider.
- Real benchmark data.
- Sector breadth and advance/decline participation.
- Macro regime / rates / VIX / economic calendar.
- Earnings and news events.
- Swing/Investor timeframe plans.
- Cross-sectional peer ranking.
- MACD/EMA/SMA/VWAP/support-resistance.

These remain future brain layers and should be added only after competitor research and explicit de-duplication rules.
