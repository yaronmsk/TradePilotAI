# Release 0.5 — Strategy-Aware Consensus Engine

## Goal

Make the TradePilot AI brain safer to expand before adding many more indicators, while removing ambiguity between Trader, Swing and Investor recommendations.

## Implemented

### Strategy context
- Strategy Summary is now the master analysis context selector.
- Detailed recommendation title becomes `Trader Recommendation`, `Swing Recommendation` or `Investor Recommendation`.
- Recommendation Insight, Evidence and Risk use the same selected strategy context.
- Only implemented strategies are selectable.
- Trader is active in v0.5; Swing and Investor remain Coming Soon.

### Consensus Engine
- Adds EvidenceFamily.
- Candle Trend → Trend.
- RSI → Momentum.
- Relative Volume → Participation.
- Evidence is aggregated inside each family before the final consensus.
- A family's influence is capped by its strongest effective signal weight, preventing correlated indicators from linearly multiplying confidence.

### Consensus metrics
The engine still calculates the full technical consensus internally:
- Direction Score (-100 to +100).
- Confidence (0 to 100).
- Bullish and bearish evidence support.
- Agreement and conflict.
- Evidence-family coverage.
- Independent evidence-group count.
- Per-group direction, reliability and signal count.

The main UI intentionally exposes only three user-facing concepts:
- Signal Strength.
- Confidence.
- Signal Alignment.

Technical metrics remain available under `How was this calculated?`, with info buttons explaining the three primary concepts.

### Recommendation logic
- Direction and confidence are separate.
- Strong Buy / Buy / Sell / Strong Sell require both sufficient direction and confidence.
- High conflict can result in HOLD even when the underlying signals are individually strong.
- Low coverage still gates the system to WAIT.

### UI
- New strategy-aware Recommendation Card.
- New `<Strategy> Recommendation Insight` card with plain-English confidence explanation and expandable technical details.
- Strategy-specific Evidence heading.
- Strategy-specific Risk heading.
- Selected strategy is visually marked in Strategy Summary.

## Why this precedes MACD/EMA/SMA

Adding many indicators before de-duplication would create a structural bias: several indicators derived from the same price trend could overwhelm an independent volume, volatility or fundamental signal simply because there are more of them.

Release 0.5 creates the family layer first so future evidence can be added without turning the recommendation into a majority vote of correlated indicators.

## Important limitation

The current Trader engine still uses the v0.4 short market snapshot for Stock Behavior. This is not yet a true long-horizon Stock DNA model. Release 0.6 should connect a separate historical context baseline so a structurally volatile stock is distinguished from a normally stable stock experiencing a temporary volatility spike.

## Validation

From repository root:

```bash
chmod +x tools/validate-release-0.5.sh
./tools/validate-release-0.5.sh
```

Then:

```bash
cd mobile
flutter run -d chrome --web-port=7357
```

Manual checks:
- Strategy Summary shows Trader selected.
- Swing and Investor show Coming Soon and cannot replace the current detail context.
- Detailed card says Trader Recommendation, not generic Recommendation.
- Trader Recommendation Insight is visible.
- Trader Evidence and Trader Risk are explicit.
- Different symbols produce different direction/confidence/conflict values.
- 1D/5D/1M/3M/1Y chart selection still does not recalculate Trader evidence.
