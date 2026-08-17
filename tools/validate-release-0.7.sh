#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR/mobile"

echo "==> Formatting Dart files"
dart format lib test

echo "==> Running flutter analyze"
flutter analyze

echo "==> Running flutter test"
flutter test

echo "==> TradePilot AI v0.7 validation complete"
