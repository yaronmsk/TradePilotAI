# Applying TradePilot AI v0.9

From the repository root:

```bash
cd /Users/yaron.moshkovitz/develop/TradePilotAI
unzip -o ~/Downloads/TradePilotAI_release_0_9_patch.zip -d .
chmod +x tools/validate-release-0.9.sh
./tools/validate-release-0.9.sh
```

The validation script enters `mobile` and runs:

```bash
dart format lib test
flutter analyze
flutter test
```

Then launch:

```bash
cd mobile
flutter run -d chrome --web-port=7357
```

Manual checks:
- Historical Setup Check appears in Trader Recommendation Insight.
- Similar Cases, Match Quality, Follow-Through vs Control and Confidence Impact are visible.
- Expand Historical details and inspect outcome window and closest analogs.
- The UI clearly states that current historical outcomes are synthetic development data.
- Changing Trader primary interval changes the historical outcome horizon.
- Historical validation may adjust Confidence but must not change Signal Strength/direction by itself.
- Price History range remains independent of recommendation analysis.
