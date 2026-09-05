# TradePilot Data Gateway — v0.13 Personal Beta

This gateway is the first live-data boundary between the Flutter app and
external data vendors.

## Current Batch 2 scope

- Twelve Data `/time_series` market data only.
- TradePilot-normalized market snapshot and price-history endpoints.
- Provider API key remains server-side / outside Flutter.
- In-memory cache deliberately fetches superset windows so multiple TradePilot
  consumers reuse one provider series.
- Local safety budget defaults to 7 provider credits/minute, leaving one credit
  of headroom below the observed Twelve Data Basic limit of 8/minute.
- No full SaaS backend, account system or billing.

Investor SEC EDGAR integration follows in a later v0.13 batch.

## Endpoints

### `GET /health`

No provider request.

### `GET /v1/market/snapshot`

Query:

- `symbol`
- `timeframe`
- `candleCount`

Supported TradePilot timeframes in this batch:

`1m`, `5m`, `15m`, `30m`, `1h`, `4h`, `1d`, `1w`, `1mo`

`3mo` is intentionally rejected because Twelve Data does not expose a direct
3-month interval. TradePilot will not invent aggregation semantics without a
separately tested policy.

### `GET /v1/market/history`

Query:

- `symbol`
- `range`

Supported ranges:

`1D`, `5D`, `1M`, `3M`, `1Y`

## Running locally

From repository root:

```bash
read -s TWELVE_DATA_API_KEY
export TWELVE_DATA_API_KEY
python3 gateway/run.py
```

Default address:

`http://127.0.0.1:8787`

The server binds to localhost by default. Binding to `0.0.0.0` for a physical
Android device is a later explicit step and should only be done on a trusted
network.

## Secrets

Never commit a Twelve Data API key.

The gateway uses:

`TWELVE_DATA_API_KEY`

from process environment only.

No `.env` file is required and gateway `.gitignore` excludes local `.env`
files if one is created manually.

## Credit efficiency

TradePilot's initial Trader flow uses primary market data, chart history, Stock
DNA history, higher-timeframe confirmation, broad-market context and sector
context.

Without caching this can exceed the free Twelve Data minute budget.

The gateway therefore:

- keys cache by symbol + upstream interval;
- fetches a deliberate superset window;
- serializes upstream cache misses to coalesce concurrent duplicate requests;
- reuses AAPL 5-minute data between the Trader snapshot and 1D chart;
- reuses AAPL daily data between context and 1Y Stock DNA history;
- limits itself to 7 credits/minute.

The current AAPL Trader flow can therefore fit into 7 unique provider credits
rather than 9 independent calls.


## Managed macOS / corporate TLS

Homebrew Python can use a different CA trust source from Safari, Chrome, or
system `curl`. On a managed Mac, an HTTPS inspection/root certificate may
therefore be trusted by macOS Keychain but rejected by Python.

Do not disable TLS verification.

For local development, `tools/smoke-v0.13-batch2-live.sh` exports public
certificates from the macOS System, System Root, and login keychains into:

`/tmp/tradepilot-macos-ca-bundle.pem`

and sets `SSL_CERT_FILE` only for the smoke-test process.

The export contains public certificates only, not private keys, and is not
stored in the repository. A deployed/cloud TradePilot gateway must use the
platform's normal production CA trust configuration.
