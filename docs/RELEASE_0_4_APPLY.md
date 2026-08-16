# Release 0.4 — Apply and Validate

This release is an overlay for the TradePilotAI repository snapshot used to build it.

## Apply

Extract the release patch ZIP directly into the TradePilotAI repository root and allow existing files to be replaced.

## Validate

From the repository root:

```bash
chmod +x tools/validate-release-0.4.sh
./tools/validate-release-0.4.sh
```

Then run the web app:

```bash
cd mobile
flutter run -d chrome --web-port=7357
```

## Visual checks

Check at least AAPL, NVDA, TSLA and PLTR.

Verify:
- Market History remains available.
- Stock Behavior appears below Market Status.
- Relative Volume appears as a third evidence provider.
- Stock Behavior values change according to the selected symbol.
- RSI and Candle Trend evidence weights can change according to context.
- The Recommendation section can be reached normally when scrolling.

## Git checkpoint after validation

```bash
git status
git add .
git commit -m "feat: add context-aware stock behavior and relative volume"
git push origin develop
```
