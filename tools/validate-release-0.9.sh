#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MOBILE_DIR="$REPO_ROOT/mobile"

cd "$MOBILE_DIR"

echo "==> Formatting Dart sources"
dart format lib test

echo "==> Flutter analyze"
flutter analyze

echo "==> Flutter test"
flutter test

echo "==> TradePilot AI v0.9 validation complete"
