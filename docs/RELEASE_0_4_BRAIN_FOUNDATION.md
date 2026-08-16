# Release 0.4 — Context-Aware Brain Foundation

## Implemented

- Stock Behavior Profile
  - Steady / Balanced / Volatile classification
  - Relative volume
  - ATR%
  - Recent-vs-baseline volatility regime
  - Trend efficiency
- Relative Volume evidence provider
- Context-aware evidence weighting
  - RSI dynamically discounted in volatile / strongly directional conditions
  - Candle Trend dynamically boosted or discounted based on directional efficiency
  - Relative Volume dynamically weighted according to abnormal activity
- Stock Behavior dashboard card
- EvidenceKind identifiers for scalable context logic
- Recommendation state now exposes stock behavior context
- Robust widget test scrolling for the taller dashboard
- Brain architecture and competitor-research documentation

## Important limitation of v0.4

The current profile is calculated from the market snapshot currently available to the Trader strategy. It is intentionally a foundation.

When real market history is connected, the profile should use:
- Daily history for long-horizon volatility and stock personality
- Same-time-of-day historical volume for intraday RVOL
- Sector and index comparison
- Event/earnings context

## Validation

From the repository root:

```bash
chmod +x tools/validate-release-0.4.sh
./tools/validate-release-0.4.sh
```

Then run the app:

```bash
cd mobile
flutter run -d chrome --web-port=7357
```

Check several different symbols and verify:
- Stock Behavior changes between symbols.
- Relative Volume appears as a third evidence card.
- Evidence Weight can differ according to stock context.
- RSI is not treated with identical importance in every stock condition.
