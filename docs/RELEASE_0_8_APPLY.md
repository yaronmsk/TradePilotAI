# TradePilot AI v0.8.0 — Apply and Validate

This is the **cumulative final v0.8 patch**. It includes:
- Advanced Trader Evidence,
- selectable Trader Primary Analysis Interval,
- strategy-specific timeframe policy,
- Recommendation direction/confidence attribution.

It can be applied directly on the clean v0.7.0 baseline. If an earlier v0.8 patch was already applied, using `unzip -o` safely replaces the same v0.8 files with the final versions.

From the repository root:

```bash
cd /Users/yaron.moshkovitz/develop/TradePilotAI
unzip -o ~/Downloads/TradePilotAI_release_0_8_final_patch.zip -d .
chmod +x tools/validate-release-0.8.sh
./tools/validate-release-0.8.sh
```

Manual commands from `mobile`:

```bash
cd /Users/yaron.moshkovitz/develop/TradePilotAI/mobile
dart format lib test
flutter analyze
flutter test
flutter run -d chrome --web-port=7357
```

Manual UI check:
- Compare AAPL, NVDA, TSLA and PLTR.
- Confirm Trader Evidence is grouped into expandable evidence groups.
- Confirm EMA Structure, MACD Momentum, Volume Confirmation, VWAP Position, Support & Resistance and Price Extension appear.
- Change Primary Analysis Interval through 1m, 5m, 15m, 30m and 1h and confirm the Trader analysis recalculates.
- Confirm Price History 1D/5D/1M/3M/1Y remains independent from recommendation analysis.
- Confirm Recommendation Insight shows **Evidence Contribution**.
- Confirm family-level percentages distinguish supporting versus opposing evidence.
- Expand a family and confirm each provider shows exact direction points and confidence contribution.
- Expand **Confidence calculation** and confirm coverage/alignment/reliability adjustments are visible.
