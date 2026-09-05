from __future__ import annotations

import json
import traceback
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

from .cache import SerializedCapacityCache
from .config import GatewayConfig
from .market_service import MarketGatewayService
from .rate_limit import MinuteCreditBudget, RateLimitExceeded
from .twelve_data_client import TwelveDataClient, TwelveDataError


def create_service(config: GatewayConfig) -> MarketGatewayService:
    budget = MinuteCreditBudget(config.upstream_credits_per_minute)
    client = TwelveDataClient(
        api_key=config.twelve_data_api_key,
        credit_budget=budget,
    )
    return MarketGatewayService(
        twelve_data=client,
        cache=SerializedCapacityCache(),
    )


def create_server(
    config: GatewayConfig,
    *,
    service: MarketGatewayService | None = None,
) -> ThreadingHTTPServer:
    resolved_service = service or create_service(config)

    class Handler(BaseHTTPRequestHandler):
        server_version = 'TradePilotGateway/0.13'

        def do_GET(self) -> None:  # noqa: N802
            try:
                parsed = urlparse(self.path)

                if parsed.path == '/health':
                    self._send_json(200, resolved_service.health())
                    return

                query = parse_qs(parsed.query, keep_blank_values=True)

                if parsed.path == '/v1/market/snapshot':
                    symbol = _one(query, 'symbol')
                    timeframe = _one(query, 'timeframe')
                    candle_count = _positive_int(
                        _one(query, 'candleCount'),
                        'candleCount',
                    )
                    payload = resolved_service.snapshot(
                        symbol=symbol,
                        timeframe=timeframe,
                        candle_count=candle_count,
                    )
                    self._send_json(200, payload)
                    return

                if parsed.path == '/v1/market/history':
                    payload = resolved_service.history(
                        symbol=_one(query, 'symbol'),
                        range_label=_one(query, 'range'),
                    )
                    self._send_json(200, payload)
                    return

                self._send_json(404, {'message': 'Endpoint not found.'})
            except ValueError as error:
                self._send_json(400, {'message': str(error)})
            except RateLimitExceeded as error:
                self._send_json(
                    429,
                    {'message': str(error)},
                    retry_after=error.retry_after_seconds,
                )
            except TwelveDataError as error:
                status = 429 if error.status_code == 429 else 502
                retry_after = error.retry_after_seconds
                if status == 429 and retry_after is None:
                    retry_after = (
                        resolved_service
                        .health()['providerBudget']['retryAfterSeconds']
                    )
                self._send_json(
                    status,
                    {'message': f'Upstream market data error: {error}'},
                    retry_after=retry_after,
                )
            except Exception as error:
                # BaseHTTPRequestHandler.log_error does not support exc_info.
                # Print the original traceback explicitly so unexpected failures
                # never cause a secondary exception / empty HTTP reply.
                self.log_error(
                    'Unhandled gateway request failure: %s',
                    error,
                )
                traceback.print_exc()
                self._send_json(
                    500,
                    {'message': 'TradePilot Data Gateway request failed.'},
                )

        def _send_json(
            self,
            status: int,
            payload: object,
            *,
            retry_after: int | None = None,
        ) -> None:
            body = json.dumps(
                payload,
                separators=(',', ':'),
            ).encode('utf-8')
            self.send_response(status)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Cache-Control', 'no-store')
            if retry_after is not None:
                self.send_header('Retry-After', str(retry_after))
            self.send_header('Content-Length', str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def log_message(self, format: str, *args: object) -> None:
            # Keep provider credentials out of logs; request URLs never contain
            # the Twelve Data key because it is sent upstream via a header.
            super().log_message(format, *args)

    return ThreadingHTTPServer((config.host, config.port), Handler)


def run_server(config: GatewayConfig) -> None:
    server = create_server(config)
    print(
        f'TradePilot Data Gateway listening on '
        f'http://{config.host}:{config.port}'
    )
    print(
        f'Upstream safety budget: '
        f'{config.upstream_credits_per_minute} credits/minute'
    )
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


def _one(query: dict[str, list[str]], key: str) -> str:
    values = query.get(key)
    if values is None or len(values) != 1 or not values[0].strip():
        raise ValueError(f'{key} is required exactly once.')
    return values[0].strip()


def _positive_int(value: str, field: str) -> int:
    try:
        parsed = int(value)
    except ValueError as error:
        raise ValueError(f'{field} must be an integer.') from error
    if parsed < 1:
        raise ValueError(f'{field} must be positive.')
    return parsed
