#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT/mobile"

echo "==> Formatting Dart files"
dart format lib test

echo "==> Running Flutter analyzer"
flutter analyze

echo "==> Running Flutter tests"
flutter test

echo "==> Release 0.4 validation passed"
