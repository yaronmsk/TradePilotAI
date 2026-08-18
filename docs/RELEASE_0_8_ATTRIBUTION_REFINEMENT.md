# TradePilot AI v0.8 — Recommendation Attribution Refinement

Status: Development / Validation  
Date: 2026-08-19

## Goal

Expose how much each independent evidence group and each underlying evidence provider contributed to the recommendation direction and to confidence, without bypassing the evidence-family de-duplication rules introduced in v0.5.

## Product principle

A recommendation should answer two different questions:

1. **Why did the brain lean Buy/Hold/Sell?**
2. **Why is confidence at this level?**

These are not the same calculation and are therefore shown separately.

## Competitive takeaway

Leading platforms make composite scores easy to consume but generally expose factor or indicator groups rather than a mathematically reconciled explanation of how each input changed the final score.

TradePilot enhancement:
- preserve a simple top-level recommendation,
- show family-level percentage attribution by default,
- keep exact provider-level attribution expandable,
- reconcile attribution to the same deterministic math used by the Consensus Engine,
- prevent correlated providers from receiving independent full votes.

Research references:
- TradingView Technical Ratings: https://www.tradingview.com/support/solutions/43000614331-technical-ratings/
- TradingView Screener Ratings: https://www.tradingview.com/support/solutions/43000475547-what-do-the-ratings-in-the-screener-mean/
- Seeking Alpha Quant Ratings and Factor Grades: https://help.seekingalpha.com/premium/quant-ratings-and-factor-grades-faq
- TipRanks Smart Score: https://www.tipranks.com/glossary/s/smart-score

## Direction attribution

At family level, the final direction score is decomposed into signed direction-impact points. Family contributions sum exactly to the final direction score.

The UI shows each family as a percentage of total absolute family-level directional influence:
- **Supports** — pushes in the same direction as the final directional lead.
- **Opposes** — pushes against the lead.
- **Bullish/Bearish** — used when the total result is close to balanced.

Example:

```text
Trend             Supports 42%
Momentum          Supports 27%
Volume Activity   Opposes 11%
Price Structure   Supports 14%
Market Context    Supports 6%
```

## Provider attribution inside a family

Providers remain family-capped. Example:

```text
Trend group: +31.0 direction pts

Candle Trend          +13.2 pts · 43% of Trend calculation
EMA Structure          +8.5 pts · 27% of Trend calculation
Multi-Timeframe Trend  +9.3 pts · 30% of Trend calculation
```

The provider impacts reconcile exactly to the family impact. Adding another correlated trend provider does not increase the Trend family's independent cap.

## Confidence attribution

The evidence-strength baseline is mathematically distributed across families/providers and then subjected to the same global confidence factors already used by the Consensus Engine.

Family/provider confidence-contribution points sum exactly to final confidence.

The UI additionally exposes the exact confidence build-up:

```text
Evidence-strength baseline      84.2%
Provider coverage               -1.7 pts
Evidence-group coverage         -2.0 pts
Signal alignment                -5.4 pts
Data reliability                -1.9 pts
Final confidence                73.2%
```

Confidence remains an internal evidence-confidence measure and is explicitly not presented as a guaranteed probability of profit.

## UI placement

Recommendation Insight keeps the three simple top-level concepts:
- Signal Strength
- Confidence
- Signal Alignment

Below the plain-English explanation it now adds **Evidence Contribution**. Family-level percentages are visible immediately. Exact provider-level direction/confidence points are available by expanding each evidence group.

## Validation rules

Tests must prove:
- family direction impacts sum to the final direction score,
- provider direction impacts sum to their family and to the final direction score,
- family confidence contributions sum to final confidence,
- provider confidence contributions sum to final confidence,
- family direction shares sum to 100% when directional evidence exists,
- confidence shares sum to 100% when confidence exists,
- duplicate same-family providers do not inflate the family contribution,
- confidence modifiers reconcile evidence-strength baseline to final confidence.
