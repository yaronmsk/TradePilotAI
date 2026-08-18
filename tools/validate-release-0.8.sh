#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOBILE_DIR="$ROOT_DIR/mobile"

cd "$MOBILE_DIR"

echo "==> Formatting Dart sources"
dart format lib test

echo "==> Flutter analyze"
flutter analyze

echo "==> Flutter tests"
flutter test

echo "==> TradePilot AI v0.8 validation complete"
