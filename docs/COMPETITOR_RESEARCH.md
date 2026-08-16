# TradePilot AI Competitor Research

Research checkpoint: August 2026

## TradingView

Strengths:
- Extremely strong charting and indicator ecosystem.
- Volume Profile, VWAP, ATR, historical volatility and Relative Volume at Time.
- Relative Volume at Time compares a bar with comparable historical time points, which is especially important because intraday volume is seasonal.

TradePilot AI opportunity:
- Do not merely display these indicators. Normalize them to the stock and combine them into an explainable recommendation.

## TrendSpider

Strengths:
- Automated technical analysis.
- Multi-timeframe analysis.
- Strategy-based scanning and backtesting.
- Relative Volume and normalized volatility indicators.

TradePilot AI opportunity:
- Make the weighting transparent and stock-specific rather than leaving the user to interpret many automated overlays.

## Seeking Alpha

Strengths:
- Quant approach combines many metrics into Value, Growth, Profitability, Momentum and EPS Revisions factors.
- Factor grades compare securities against relevant peers rather than only using absolute values.

TradePilot AI opportunity:
- Use a similar relative philosophy for both technical and fundamental evidence while preserving separate Trader, Swing and Investor strategy logic.

## MarketSurge / IBD

Strengths:
- Combines technical and fundamental information.
- Relative Strength ratings and lines.
- Price/volume behavior and Accumulation/Distribution.
- Market direction and pattern recognition.

TradePilot AI opportunity:
- Explicitly explain why relative strength, market direction and volume confirmation altered the recommendation and how much they contributed.

## Trade Ideas

Strengths:
- AI-oriented real-time trade ideas and entry/exit signals.
- Strategy performance validation.

TradePilot AI opportunity:
- Avoid an opaque "AI says buy" model. Keep the recommendation deterministic and auditable, while AI acts as Analyst, Mentor and Statistical Explainer.

## TradePilot AI differentiation

1. Context before signal.
2. Stock-normalized evidence instead of universal thresholds alone.
3. Dynamic evidence weights.
4. Separate Trader, Swing and Investor conclusions visible together.
5. Conflict-aware recommendations.
6. Deterministic explainability plus conversational AI explanation.
7. Historical conditional validation: how similar setups performed for this stock and comparable stocks.
8. "What would change this recommendation?" counterfactual explanations.
9. Stock DNA: learn which evidence historically works best for each security.
10. Uncertainty gating: WAIT/HOLD when data or agreement is insufficient.

## Research implications adopted in v0.4

- Relative Volume becomes a first-class evidence provider.
- ATR% is used as a normalized volatility measure in the stock behavior profile.
- RSI weight is reduced in highly volatile or strongly directional conditions.
- Trend evidence is treated differently when volatility is directional versus noisy.
- The architecture is ready for same-time-of-day relative volume when real historical intraday data is connected.
