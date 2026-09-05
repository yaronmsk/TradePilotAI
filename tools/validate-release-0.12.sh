#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOBILE_DIR="$ROOT_DIR/mobile"

echo "==> v0.12.0 release metadata"
grep -Fxq "version: 0.12.0+1" "$MOBILE_DIR/pubspec.yaml"
grep -Fq "'Version 0.12.0'"   "$MOBILE_DIR/lib/features/dashboard/dashboard_page.dart"
test "$(grep -Fc "find.text('Version 0.12.0')" "$MOBILE_DIR/test/widget_test.dart")" -eq 2

cd "$MOBILE_DIR"

echo "==> Dart format check"
dart format --output=none --set-exit-if-changed lib test

echo "==> Flutter analyze"
flutter analyze

echo "==> Investor suite"
flutter test test/features/recommendation/investor

echo "==> Dashboard strategy orchestration"
flutter test test/features/dashboard/dashboard_strategy_orchestration_test.dart

echo "==> Full dashboard widget acceptance"
flutter test test/widget_test.dart

echo "==> Recommendation subsystem"
flutter test test/features/recommendation

echo "==> Full automated suite"
flutter test

echo "==> Web release build"
flutter build web

cd "$ROOT_DIR"

echo "==> Whitespace validation"
git diff --check

echo "==> Release metadata summary"
grep '^version:' mobile/pubspec.yaml
grep -n "Version 0.12.0"   mobile/lib/features/dashboard/dashboard_page.dart   mobile/test/widget_test.dart

echo "v0.12.0 release gate completed successfully."
