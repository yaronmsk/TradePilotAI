# TradePilot AI Brain Architecture

Version: 0.4 foundation
Status: Living design

## Core rule

A recommendation is not an indicator vote. It is a context-aware conclusion built from evidence whose meaning and weight change according to the stock, market regime, timeframe, data quality, and investment horizon.

## Decision pipeline

Market data
→ Stock behavior profile
→ Evidence providers
→ Contextual evidence weighting
→ Evidence report
→ Consensus/scoring
→ Strategy-specific recommendation
→ Deterministic explanation
→ AI Mentor / Analyst explanation

## Stock-normalized analysis

TradePilot AI should prefer comparisons against a stock's own normal behavior over universal thresholds whenever possible.

Examples:
- Current volume vs recent average volume.
- Intraday volume vs the same time-of-day across previous sessions.
- ATR% vs the stock's historical ATR%.
- Current volatility vs its historical volatility regime.
- Momentum and trend persistence vs the stock's own history.

## Stock behavior profile

The initial implementation classifies price behavior as:
- Steady
- Balanced
- Volatile

It also measures:
- Relative volume
- ATR%
- Recent vs baseline volatility
- Trend efficiency

This is the first implementation of the future Stock DNA capability.

## Context-aware weighting

Evidence weights are not permanent.

Examples implemented in v0.4:
- RSI is discounted when a stock is volatile or strongly directional because extreme RSI values can persist in trends.
- Candle Trend is boosted when a volatile stock is moving with high directional efficiency.
- Candle Trend is discounted when a volatile stock is noisy rather than directional.
- Relative Volume receives more weight when current volume is materially above the stock's recent baseline.

## Evidence roadmap

Short-term / Trader:
1. Candle Trend
2. RSI
3. Relative Volume
4. MACD
5. ATR / volatility context
6. VWAP
7. EMA/SMA structure
8. Support and resistance
9. Breakout quality
10. Gap behavior
11. Relative strength vs market and sector
12. Market breadth and index regime
13. Earnings/event risk
14. News/sentiment
15. Options/implied volatility and flow when reliable data is available

Swing:
- Multi-timeframe trend alignment
- Daily/weekly relative strength
- Moving-average structure
- Support/resistance
- Volume confirmation
- Earnings/event calendar
- Market/sector regime

Investor:
- Revenue and EPS growth
- Free cash flow
- Margins
- Debt and liquidity
- ROIC / capital efficiency
- Valuation vs own history and peers
- Earnings revisions
- Competitive position
- Institutional ownership
- Long-term relative strength

## Future Stock DNA

The profile should ultimately be learned from longer history and include:
- Typical daily and intraday volatility
- Typical volume by time-of-day
- Gap frequency
- Trend persistence
- Mean-reversion tendency
- Breakout success rate
- Earnings-day behavior
- Preferred evidence providers based on historical effectiveness

## Confidence rules

Confidence must reflect:
- Evidence reliability
- Evidence coverage
- Agreement / conflict
- Contextual relevance
- Historical conditional performance
- Data freshness and quality

A high score from one indicator must never create high confidence by itself.

## Explainability rules

Every recommendation should eventually expose:
- Supporting evidence
- Opposing evidence
- Evidence reliability
- Context-adjusted weight
- Stock behavior profile
- What would change the recommendation
- Historical outcome of similar setups

AI explains these deterministic facts; AI does not invent the recommendation.
