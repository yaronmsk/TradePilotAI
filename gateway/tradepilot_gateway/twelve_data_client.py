from __future__ import annotations

import json
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Callable, Mapping
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from .rate_limit import MinuteCreditBudget


@dataclass(frozen=True)
class HttpJsonResponse:
    status: int
    headers: Mapping[str, str]
    payload: object


@dataclass(frozen=True)
class TimeSeriesResult:
    symbol: str
    interval: str
    exchange: str | None
    exchange_timezone: str | None
    candles: tuple[dict[str, object], ...]
    fetched_at: datetime


class TwelveDataError(RuntimeError):
    def __init__(
        self,
        message: str,
        *,
        status_code: int | None = None,
        retry_after_seconds: int | None = None,
    ) -> None:
        super().__init__(message)
        self.status_code = status_code
        self.retry_after_seconds = retry_after_seconds


def _default_transport(
    url: str,
    headers: Mapping[str, str],
    timeout_seconds: float,
) -> HttpJsonResponse:
    request = urllib.request.Request(url, headers=dict(headers))

    try:
        with urllib.request.urlopen(
            request,
            timeout=timeout_seconds,
        ) as response:
            raw = response.read().decode('utf-8')
            return HttpJsonResponse(
                status=response.status,
                headers=dict(response.headers.items()),
                payload=json.loads(raw),
            )
    except urllib.error.HTTPError as error:
        raw = error.read().decode('utf-8', errors='replace')
        try:
            payload: object = json.loads(raw)
        except json.JSONDecodeError:
            payload = {'message': raw[:500]}

        return HttpJsonResponse(
            status=error.code,
            headers=dict(error.headers.items()),
            payload=payload,
        )
    except urllib.error.URLError as error:
        raise TwelveDataError(
            f'Unable to establish a verified HTTPS connection to Twelve Data: '
            f'{error.reason}'
        ) from error


class TwelveDataClient:
    BASE_URL = 'https://api.twelvedata.com'
    SUPPORTED_INTERVALS = frozenset({
        '1min',
        '5min',
        '15min',
        '30min',
        '45min',
        '1h',
        '2h',
        '4h',
        '8h',
        '1day',
        '1week',
        '1month',
    })
    INTRADAY_INTERVALS = frozenset({
        '1min',
        '5min',
        '15min',
        '30min',
        '45min',
        '1h',
        '2h',
        '4h',
        '8h',
    })

    def __init__(
        self,
        *,
        api_key: str,
        credit_budget: MinuteCreditBudget,
        transport: Callable[
            [str, Mapping[str, str], float],
            HttpJsonResponse,
        ] = _default_transport,
        timeout_seconds: float = 20.0,
        now: Callable[[], datetime] = lambda: datetime.now(timezone.utc),
    ) -> None:
        if not api_key.strip():
            raise ValueError('api_key is required')

        self._api_key = api_key.strip()
        self.credit_budget = credit_budget
        self._transport = transport
        self._timeout_seconds = timeout_seconds
        self._now = now

    def fetch_time_series(
        self,
        *,
        symbol: str,
        interval: str,
        outputsize: int,
    ) -> TimeSeriesResult:
        normalized_symbol = symbol.strip().upper()
        if not normalized_symbol:
            raise ValueError('symbol is required')
        if interval not in self.SUPPORTED_INTERVALS:
            raise ValueError(f'Unsupported Twelve Data interval: {interval}')
        if outputsize < 1 or outputsize > 5000:
            raise ValueError('outputsize must be between 1 and 5000')

        params = {
            'symbol': normalized_symbol,
            'interval': interval,
            'outputsize': str(outputsize),
            'order': 'desc',
        }
        if interval in self.INTRADAY_INTERVALS:
            params['timezone'] = 'UTC'

        url = f'{self.BASE_URL}/time_series?{urllib.parse.urlencode(params)}'
        headers = {
            'Accept': 'application/json',
            'Authorization': f'apikey {self._api_key}',
            'User-Agent': 'TradePilotAI-Gateway/0.13',
        }

        # Twelve Data /time_series costs one credit for one symbol.
        self.credit_budget.acquire(1)
        response = self._transport(url, headers, self._timeout_seconds)

        payload = response.payload
        if response.status < 200 or response.status >= 300:
            raise self._error_from_response(response)

        if not isinstance(payload, dict):
            raise TwelveDataError(
                'Twelve Data returned a non-object response.',
                status_code=response.status,
            )

        if payload.get('status') == 'error':
            code = payload.get('code')
            status_code = code if isinstance(code, int) else response.status
            message = payload.get('message')
            raise TwelveDataError(
                str(message or 'Twelve Data returned an error.'),
                status_code=status_code,
            )

        meta = payload.get('meta')
        values = payload.get('values')
        if not isinstance(meta, dict) or not isinstance(values, list):
            raise TwelveDataError(
                'Twelve Data time_series response is missing meta/values.',
                status_code=response.status,
            )
        if not values:
            raise TwelveDataError(
                f'Twelve Data returned no candles for {normalized_symbol}.',
                status_code=response.status,
            )

        exchange_timezone = _optional_string(meta.get('exchange_timezone'))
        normalized_candles = [
            self._normalize_candle(
                raw,
                interval=interval,
                exchange_timezone=exchange_timezone,
            )
            for raw in values
        ]
        normalized_candles.sort(key=lambda candle: str(candle['timestamp']))

        return TimeSeriesResult(
            symbol=_optional_string(meta.get('symbol')) or normalized_symbol,
            interval=_optional_string(meta.get('interval')) or interval,
            exchange=_optional_string(meta.get('exchange')),
            exchange_timezone=exchange_timezone,
            candles=tuple(normalized_candles),
            fetched_at=self._now().astimezone(timezone.utc),
        )

    def _normalize_candle(
        self,
        raw: object,
        *,
        interval: str,
        exchange_timezone: str | None,
    ) -> dict[str, object]:
        if not isinstance(raw, dict):
            raise TwelveDataError(
                'Twelve Data returned a malformed candle.'
            )

        timestamp = _normalize_timestamp(
            raw.get('datetime'),
            interval=interval,
            exchange_timezone=exchange_timezone,
        )

        return {
            'timestamp': timestamp,
            'open': _required_float(raw.get('open'), 'open'),
            'high': _required_float(raw.get('high'), 'high'),
            'low': _required_float(raw.get('low'), 'low'),
            'close': _required_float(raw.get('close'), 'close'),
            'volume': _required_float(raw.get('volume'), 'volume'),
        }

    @staticmethod
    def _error_from_response(response: HttpJsonResponse) -> TwelveDataError:
        message = f'Twelve Data returned HTTP {response.status}.'
        if isinstance(response.payload, dict):
            raw_message = response.payload.get('message')
            if isinstance(raw_message, str) and raw_message.strip():
                message = raw_message.strip()

        retry_after = _parse_retry_after(response.headers.get('Retry-After'))
        return TwelveDataError(
            message,
            status_code=response.status,
            retry_after_seconds=retry_after,
        )


def _normalize_timestamp(
    value: object,
    *,
    interval: str,
    exchange_timezone: str | None,
) -> str:
    if not isinstance(value, str) or not value.strip():
        raise TwelveDataError('Candle datetime is missing.')

    raw = value.strip()

    if interval in TwelveDataClient.INTRADAY_INTERVALS:
        try:
            parsed = datetime.strptime(raw, '%Y-%m-%d %H:%M:%S')
        except ValueError as error:
            raise TwelveDataError(
                f'Invalid intraday candle datetime: {raw}'
            ) from error
        return _iso_z(parsed.replace(tzinfo=timezone.utc))

    try:
        parsed_date = datetime.strptime(raw, '%Y-%m-%d')
    except ValueError as error:
        raise TwelveDataError(
            f'Invalid daily candle date: {raw}'
        ) from error

    zone = timezone.utc
    if exchange_timezone:
        try:
            zone = ZoneInfo(exchange_timezone)
        except ZoneInfoNotFoundError:
            zone = timezone.utc

    return _iso_z(parsed_date.replace(tzinfo=zone).astimezone(timezone.utc))


def _iso_z(value: datetime) -> str:
    return value.astimezone(timezone.utc).isoformat().replace('+00:00', 'Z')


def _optional_string(value: object) -> str | None:
    if isinstance(value, str) and value.strip():
        return value.strip()
    return None


def _required_float(value: object, field: str) -> float:
    if isinstance(value, (int, float)):
        return float(value)
    if isinstance(value, str):
        try:
            return float(value)
        except ValueError:
            pass
    raise TwelveDataError(f'Candle {field} is not numeric.')


def _parse_retry_after(value: str | None) -> int | None:
    if value is None:
        return None
    try:
        parsed = int(value.strip())
    except ValueError:
        return None
    return parsed if parsed >= 0 else None
