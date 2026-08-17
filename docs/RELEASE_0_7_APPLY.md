# TradePilot AI v0.7.0 — Apply and Validate

From the TradePilotAI repository root:

```bash
unzip -o ~/Downloads/TradePilotAI_release_0_7_patch.zip -d .
chmod +x tools/validate-release-0.7.sh
./tools/validate-release-0.7.sh
```

Manual validation:

```bash
cd mobile
flutter run -d chrome --web-port=7357
```

Check:

- `Strategy Summary` appears before `Trader Analysis Context`; the user chooses the strategy first and then sees context for that strategy.
- The Analysis Context card shows Timeframe Alignment, Market Environment and Relative Strength.
- Trader timeframe wording is explicit: Short-term trend (5-minute candles), Near-term trend (1-hour candles), and Daily backdrop (1-day candles). These are candle intervals, not holding-period labels.
- NVDA should show aligned bullish higher-timeframe behavior and relative leadership in the deterministic mock data.
- PLTR should show a bearish short-term trend while the 1-hour and daily backdrop views are bullish, exercising higher-timeframe opposition.
- TSLA and GOOG should exercise mixed/challenging context paths.
- Trader Evidence includes `Multi-Timeframe Trend` and `Market & Sector Context`.
- `Multi-Timeframe Trend` belongs to the Trend evidence group; it must not become another independent family.
- Market Context appears as its own independent evidence group in Recommendation Insight technical details.
- Switching 1D/5D/1M/3M/1Y visual chart range does not recalculate the recommendation context.
