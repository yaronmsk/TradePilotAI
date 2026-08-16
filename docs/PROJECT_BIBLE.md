# TradePilot AI Project Bible

Version: 1.1
Status: Living reference

## Mission

Build an explainable, statistically grounded investment analysis platform that helps users understand evidence, probability and risk rather than pretending to predict the future.

## Permanent principles

- Never claim to predict the market.
- Every recommendation must be traceable to measurable evidence.
- Supporting and opposing evidence are both displayed.
- Confidence is earned from coverage, reliability, agreement and historical validation.
- Dynamic thresholds and stock-specific baselines are preferred to one-size-fits-all thresholds.
- Trader, Swing and Investor are separate strategies with different horizons and logic.
- AI explains, mentors and analyzes; deterministic engines decide.
- Business logic is independent from the visual UI.
- Current UI is provisional and can be completely redesigned later.
- Buy and Sell capabilities receive equal treatment.
- When evidence is inadequate or conflicted, WAIT/HOLD is preferable to false certainty.

## Current architecture

Market data
→ Market snapshot / history
→ Stock behavior profile
→ Evidence providers
→ Contextual evidence adjuster
→ Evidence report
→ Scoring / consensus
→ Recommendation engine
→ Presentation layer
→ Explainability UI
→ Future AI Analyst / Mentor

## Current implemented evidence

- Candle Trend
- RSI
- Relative Volume (v0.4)

## Current stock context

- Average recent volume
- Relative volume
- ATR%
- Recent vs baseline volatility
- Trend efficiency
- Steady / Balanced / Volatile behavior classification

## Strategy model

### Trader
Minutes to days. Technical, volume, volatility, market regime and event-aware.

### Swing
Days to weeks. Multi-timeframe trend, support/resistance, volume confirmation, market/sector regime and event-aware.

### Investor
Months to years. Fundamentals, valuation, growth, quality, revisions, competitive position and long-term technical context.

## Explainability

Every evidence item should answer:
- What is it?
- Why does it matter?
- How is it calculated?
- How reliable is it?
- How did stock context change its weight?

Future AI modes:
- Mentor
- Analyst Pro
- Statistical Explainer

## Feature research rule

Before major features are designed:
1. Compare leading competing products.
2. Identify what they do well.
3. Identify what TradePilot AI can make more adaptive, transparent or useful.
4. Design the architecture before coding.

## Development workflow

- Complete files / coherent implementation packages.
- Keep implementation packages compile-ready.
- Run dart format.
- Run flutter analyze.
- Run flutter test.
- Test the feature visually.
- Commit and push each completed release.
- Tag meaningful milestones.
- Update this Bible for major architectural decisions.

## Immediate brain roadmap

1. Relative Volume and Stock Behavior Profile — v0.4.
2. Consensus Engine v2: conflict-aware confidence and evidence contribution breakdown.
3. MACD + EMA/SMA structure.
4. Market and sector relative strength.
5. Multi-timeframe alignment.
6. Real-data same-time-of-day relative volume.
7. Earnings/event risk.
8. Historical setup similarity and conditional win/loss statistics.
9. Swing engine.
10. Investor fundamental engine.
11. AI Analyst / Mentor grounded in deterministic analysis.

## UI roadmap

Current UI remains functional/provisional. A dedicated commercial look-and-feel redesign will occur after the product intelligence is sufficiently mature.
