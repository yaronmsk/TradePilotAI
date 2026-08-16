# TradePilot AI Project State

Document ID: TP-012
Version: 1.1
Status: Active
Last Updated: 2026-08-16
Primary Branch: develop

## Current release baseline

Committed baseline before this package: v0.4.0 — Context-Aware Brain Foundation.

Release currently being prepared: v0.5.0 — Strategy-Aware Consensus Engine.

## Current phase

Brain-first feature development.

The product priority is the quality, adaptability and explainability of the recommendation engine. UI remains functional/provisional until the analysis capability is mature enough for a dedicated commercial design phase.

## Implemented product capabilities

### Market / dashboard
- Persistent watchlist.
- Symbol-specific deterministic mock market behavior.
- Market Status with historical chart.
- Independent 1D / 5D / 1M / 3M / 1Y chart range.
- Chart range does not recalculate recommendation evidence.

### Recommendation brain
- Candle Trend evidence.
- RSI evidence.
- Relative Volume evidence.
- Stock Behavior context with volume, ATR%, volatility regime and trend efficiency.
- Contextual evidence weight adjustment.
- Evidence definitions and explainability dialogs.
- Evidence families: Trend, Momentum and Participation.
- Family-level Consensus Engine.
- Direction score separated from confidence.
- Bullish support, bearish support, agreement and conflict.
- Provider coverage and evidence-family coverage.
- User-facing Recommendation Insight simplifies consensus into Signal Strength, Confidence and Signal Alignment.
- Detailed agreement, conflict, coverage, reliability and evidence-group metrics remain available through explainability controls.
- Duplicate/correlated evidence protection through family influence caps.

### Strategy model
- Trader — active.
- Swing — planned / Coming Soon.
- Investor — planned / Coming Soon.
- Strategy Summary is the master context selector for detailed analysis.
- Recommendation, Recommendation Insight, Evidence and Risk are explicitly strategy-labeled.

## Current architecture

Market data
→ Stock behavior profile
→ Evidence providers
→ Contextual evidence adjustment
→ Evidence report
→ Evidence-family aggregation
→ Consensus Engine
→ Strategy-specific recommendation
→ Explainability / presentation
→ Future AI Analyst / Mentor

## Validation status

v0.4.0 was validated with 122 passing tests before commit and push.

v0.5.0 must be validated on the development Mac with:

```bash
./tools/validate-release-0.5.sh
```

Expected validation sequence:
- dart format
- flutter analyze
- flutter test

## Current limitations

- Market data remains mocked.
- Stock Behavior currently uses the short Trader snapshot, not a true long-horizon historical Stock DNA baseline.
- Swing recommendation engine is not implemented.
- Investor fundamental engine is not implemented.
- Market/sector context, earnings/events and news/sentiment are not yet connected.
- AI explanation is not yet connected.

## Next planned brain work

1. Complete and validate v0.5.0.
2. v0.6 — Historical Context / Stock DNA foundation:
   - 20/60/252-day volatility baselines.
   - same-time-of-day volume baseline.
   - structural stock volatility vs temporary volatility regime.
   - trend persistence and gap behavior.
3. v0.7 — richer Trader evidence and multi-timeframe analysis.
4. v0.8 — market/sector/event/news context.
5. v0.9 — Swing and Investor brains.

## Permanent rules

- Research major competitor implementations before designing major features.
- Do not turn the brain into a simple indicator majority vote.
- Correlated evidence cannot create artificial confidence.
- Treat solid and volatile stocks differently using stock-specific historical context.
- Direction and confidence remain separate.
- Every detailed analysis output belongs to Trader, Swing or Investor.
- AI explains deterministic analysis; AI does not invent recommendations.
- Keep presentation replaceable without rewriting domain/business logic.
