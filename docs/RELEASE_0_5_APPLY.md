# Apply TradePilot AI Release 0.5

Apply the patch from the repository root so paths land under `mobile/`, `docs/` and `tools/` correctly.

```bash
cd /Users/yaron.moshkovitz/develop/TradePilotAI
unzip -o ~/Downloads/TradePilotAI_release_0_5_patch.zip -d .
chmod +x tools/validate-release-0.5.sh
./tools/validate-release-0.5.sh
```

Then run:

```bash
cd mobile
flutter run -d chrome --web-port=7357
```
