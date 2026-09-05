#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

if [[ -z "${TWELVE_DATA_API_KEY:-}" ]]; then
  echo "ERROR: TWELVE_DATA_API_KEY is not set."
  echo "Use: read -s TWELVE_DATA_API_KEY && export TWELVE_DATA_API_KEY"
  exit 1
fi

# Homebrew Python on managed Macs may not inherit the corporate/root
# certificates trusted by macOS Keychain. Preserve HTTPS verification by
# exporting public trusted certificates to an ephemeral local bundle.
if [[ "$(uname -s)" == "Darwin" && -z "${SSL_CERT_FILE:-}" ]]; then
  CA_BUNDLE="/tmp/tradepilot-macos-ca-bundle.pem"
  "$ROOT/tools/prepare-macos-ca-bundle.sh" "$CA_BUNDLE"
  export SSL_CERT_FILE="$CA_BUNDLE"
  echo "Using macOS Keychain-derived CA bundle for verified HTTPS."
fi

LOG="/tmp/tradepilot_gateway_batch2.log"
SNAP_5M="/tmp/tradepilot_snapshot_5m.json"
HIST_1D="/tmp/tradepilot_history_1d.json"
SNAP_1D="/tmp/tradepilot_snapshot_1d.json"
HIST_1Y="/tmp/tradepilot_history_1y.json"
HEALTH="/tmp/tradepilot_gateway_health.json"

rm -f "$LOG" "$SNAP_5M" "$HIST_1D" "$SNAP_1D" "$HIST_1Y" "$HEALTH"

echo "=== Starting local TradePilot Data Gateway ==="
PYTHONPATH="$ROOT/gateway" \
  python3 gateway/run.py >"$LOG" 2>&1 &
GATEWAY_PID=$!

cleanup() {
  kill "$GATEWAY_PID" >/dev/null 2>&1 || true
  wait "$GATEWAY_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

for _ in {1..30}; do
  if curl -fsS "http://127.0.0.1:8787/health" >/dev/null 2>&1; then
    break
  fi
  sleep 0.2
done

curl -fsS "http://127.0.0.1:8787/health" >/dev/null

echo "=== AAPL Trader slice ==="
curl -fsS \
  "http://127.0.0.1:8787/v1/market/snapshot?symbol=AAPL&timeframe=5m&candleCount=48" \
  >"$SNAP_5M"

curl -fsS \
  "http://127.0.0.1:8787/v1/market/history?symbol=AAPL&range=1D" \
  >"$HIST_1D"

echo "=== AAPL Swing / Stock-DNA slice ==="
curl -fsS \
  "http://127.0.0.1:8787/v1/market/snapshot?symbol=AAPL&timeframe=1d&candleCount=90" \
  >"$SNAP_1D"

curl -fsS \
  "http://127.0.0.1:8787/v1/market/history?symbol=AAPL&range=1Y" \
  >"$HIST_1Y"

curl -fsS "http://127.0.0.1:8787/health" >"$HEALTH"

python3 - "$SNAP_5M" "$HIST_1D" "$SNAP_1D" "$HIST_1Y" "$HEALTH" <<'PY'
import json
import sys

snap_5m, hist_1d, snap_1d, hist_1y, health = [
    json.load(open(path, encoding='utf-8'))
    for path in sys.argv[1:]
]

assert snap_5m['provenance']['state'] in {'LIVE', 'PARTIAL_LIVE'}
assert snap_5m['snapshot']['symbol'] == 'AAPL'
assert snap_5m['snapshot']['timeframe'] == '5m'
assert len(snap_5m['snapshot']['candles']) >= 48

assert hist_1d['provenance']['state'] in {'LIVE', 'PARTIAL_LIVE'}
assert len(hist_1d['candles']) >= 78

assert snap_1d['provenance']['state'] in {'LIVE', 'PARTIAL_LIVE'}
assert snap_1d['snapshot']['timeframe'] == '1d'
assert len(snap_1d['snapshot']['candles']) >= 90

assert hist_1y['provenance']['state'] in {'LIVE', 'PARTIAL_LIVE'}
assert len(hist_1y['candles']) >= 252

used = health['providerBudget']['usedThisMinute']
assert used == 2, (
    f'Expected exactly 2 Twelve Data credits because snapshot/history '
    f'pairs should share cache; observed {used}.'
)

print(
    'PASS AAPL 5m snapshot:',
    len(snap_5m['snapshot']['candles']),
    'candles, current price',
    snap_5m['snapshot']['currentPrice'],
)
print('PASS AAPL 1D chart history:', len(hist_1d['candles']), 'candles')
print('PASS AAPL 1d Swing snapshot:', len(snap_1d['snapshot']['candles']), 'candles')
print('PASS AAPL 1Y Stock DNA history:', len(hist_1y['candles']), 'candles')
print('PASS cache efficiency: 4 TradePilot calls used exactly', used, 'provider credits')
print('Gateway cache stats:', health['cache'])
PY

echo
echo "=== Gateway log ==="
cat "$LOG"

echo
echo "v0.13 Batch 2 LIVE smoke passed."
