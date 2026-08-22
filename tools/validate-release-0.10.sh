#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR/mobile"

echo "==> Formatting Dart sources"
dart format lib test

echo "==> Flutter analyze"
flutter analyze

echo "==> Flutter test"
flutter test
