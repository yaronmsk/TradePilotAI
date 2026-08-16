#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR/mobile"

echo "==> Formatting Dart files"
dart format lib test

echo "==> Flutter analyze"
flutter analyze

echo "==> Flutter tests"
flutter test

echo "==> Release 0.5 validation passed"
