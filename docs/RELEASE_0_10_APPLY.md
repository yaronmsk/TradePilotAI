# Apply TradePilot AI v0.10

From the repository root:

```bash
unzip -o ~/Downloads/TradePilotAI_release_0_10_patch.zip -d .
chmod +x tools/validate-release-0.10.sh
./tools/validate-release-0.10.sh
```

Manual validation:

```bash
cd mobile
dart format lib test
flutter analyze
flutter test
flutter run -d chrome --web-port=7357
```

Visual checks:
- Trader Analysis Context includes Market Breadth, Event Risk and News Sentiment.
- Event Risk appears as a confidence modifier, not a directional evidence family.
- Trader Evidence contains Market Breadth inside Market Context and News Sentiment inside Sentiment.
- Development simulation warning is visible.
- Switching Trader analysis intervals reloads context.
- Price History range remains independent from recommendation analysis.
