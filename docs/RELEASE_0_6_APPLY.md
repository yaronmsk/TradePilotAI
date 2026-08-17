# TradePilot AI v0.6.0 — Apply and Validate

From the TradePilotAI repository root:

```bash
unzip -o ~/Downloads/TradePilotAI_release_0_6_patch.zip -d .
chmod +x tools/validate-release-0.6.sh
./tools/validate-release-0.6.sh
```

Manual validation:

```bash
cd mobile
flutter run -d chrome --web-port=7357
```

Check:

- Stock DNA appears for the selected stock.
- AAPL/MSFT look materially steadier than NVDA/TSLA/PLTR in the deterministic mock data.
- Stock Type, Volatility Now, Typical Daily Range and Volume Pattern are understandable.
- `About Stock DNA` explains that the profile changes evidence weighting and is not a Buy/Sell signal by itself.
- `How TradePilot uses this` exposes the deeper baseline without cluttering the default card.
- RSI/Trend/Relative Volume contextual explanations change when Stock DNA changes.
- Switching 1D/5D/1M/3M/1Y chart range changes only the chart, not the recommendation analysis.
