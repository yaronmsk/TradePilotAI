from __future__ import annotations

import re
from typing import Final

from .cache import SerializedCapacityCache
from .twelve_data_client import TimeSeriesResult, TwelveDataClient

_SYMBOL_PATTERN: Final = re.compile(r'^[A-Z0-9][A-Z0-9.\-/:^]{0,31}$')

TRADEPILOT_TO_TWELVE_INTERVAL: Final = {
    '1m': '1min',
    '5m': '5min',
    '15m': '15min',
    '30m': '30min',
    '1h': '1h',
    '4h': '4h',
    '1d': '1day',
    '1w': '1week',
    '1mo': '1month',
}

HISTORY_PLAN: Final = {
    '1D': ('5min', 78),
    '5D': ('30min', 130),
    '1M': ('1day', 30),
    '3M': ('1day', 90),
    '1Y': ('1day', 252),
}

# Fetch deliberate supersets so chart/history/context requests can reuse one
# upstream series and remain within the Twelve Data Basic minute budget.
STANDARD_FETCH_SIZE: Final = {
    '1min': 120,
    '5min': 130,
    '15min': 120,
    '30min': 130,
    '45min': 120,
    '1h': 120,
    '2h': 120,
    '4h': 120,
    '8h': 120,
    '1day': 260,
    '1week': 120,
    '1month': 80,
}

INTRADAY_TTL_SECONDS: Final = 30.0
DAILY_TTL_SECONDS: Final = 300.0


class MarketGatewayService:
    def __init__(
        self,
        *,
        twelve_data: TwelveDataClient,
        cache: SerializedCapacityCache[TimeSeriesResult] | None = None,
    ) -> None:
        self._twelve_data = twelve_data
        self._cache = cache or SerializedCapacityCache()

    def snapshot(
        self,
        *,
        symbol: str,
        timeframe: str,
        candle_count: int,
    ) -> dict[str, object]:
        normalized_symbol = _validate_symbol(symbol)
        if timeframe == '3mo':
            raise ValueError(
                '3mo is not exposed by Twelve Data directly and is intentionally '
                'unsupported until TradePilot adds a tested aggregation policy.'
            )

        interval = TRADEPILOT_TO_TWELVE_INTERVAL.get(timeframe)
        if interval is None:
            raise ValueError(f'Unsupported TradePilot timeframe: {timeframe}')
        if candle_count < 1 or candle_count > 5000:
            raise ValueError('candleCount must be between 1 and 5000')

        result, cache_hit = self._series(
            symbol=normalized_symbol,
            interval=interval,
            required_count=candle_count,
        )
        selected = result.candles[-candle_count:]
        if not selected:
            raise RuntimeError('No normalized candles are available.')

        latest = selected[-1]
        provenance = self._provenance(
            result,
            required_count=candle_count,
            returned_count=len(selected),
            cache_hit=cache_hit,
        )

        return {
            'provenance': provenance,
            'snapshot': {
                'symbol': normalized_symbol,
                'timeframe': timeframe,
                'timestamp': latest['timestamp'],
                'currentPrice': latest['close'],
                'currentVolume': latest['volume'],
                'candles': list(selected),
            },
        }

    def history(
        self,
        *,
        symbol: str,
        range_label: str,
    ) -> dict[str, object]:
        normalized_symbol = _validate_symbol(symbol)
        plan = HISTORY_PLAN.get(range_label)
        if plan is None:
            raise ValueError(f'Unsupported TradePilot history range: {range_label}')

        interval, point_count = plan
        result, cache_hit = self._series(
            symbol=normalized_symbol,
            interval=interval,
            required_count=point_count,
        )
        selected = result.candles[-point_count:]

        return {
            'provenance': self._provenance(
                result,
                required_count=point_count,
                returned_count=len(selected),
                cache_hit=cache_hit,
            ),
            'candles': list(selected),
        }

    def health(self) -> dict[str, object]:
        budget = self._twelve_data.credit_budget.snapshot()
        return {
            'status': 'ok',
            'service': 'TradePilot Data Gateway',
            'version': '0.13.0-batch2',
            'provider': 'Twelve Data',
            'cache': self._cache.stats(),
            'providerBudget': {
                'limitPerMinute': budget.limit,
                'usedThisMinute': budget.used,
                'remainingThisMinute': budget.remaining,
                'retryAfterSeconds': budget.retry_after_seconds,
            },
        }

    def _series(
        self,
        *,
        symbol: str,
        interval: str,
        required_count: int,
    ) -> tuple[TimeSeriesResult, bool]:
        fetch_size = max(
            required_count,
            STANDARD_FETCH_SIZE.get(interval, required_count),
        )
        ttl = (
            INTRADAY_TTL_SECONDS
            if interval in TwelveDataClient.INTRADAY_INTERVALS
            else DAILY_TTL_SECONDS
        )

        return self._cache.get_or_load(
            (symbol, interval),
            required_capacity=required_count,
            ttl_seconds=ttl,
            loader=lambda: (
                self._twelve_data.fetch_time_series(
                    symbol=symbol,
                    interval=interval,
                    outputsize=fetch_size,
                ),
                fetch_size,
            ),
        )

    @staticmethod
    def _provenance(
        result: TimeSeriesResult,
        *,
        required_count: int,
        returned_count: int,
        cache_hit: bool,
    ) -> dict[str, object]:
        state = 'LIVE' if returned_count >= required_count else 'PARTIAL_LIVE'
        newest = result.candles[-1] if result.candles else None
        observed_at = newest['timestamp'] if newest else None
        detail = (
            f'providerInterval={result.interval}; '
            f'cache={"hit" if cache_hit else "miss"}; '
            f'returned={returned_count}/{required_count}'
        )

        return {
            'state': state,
            'source': 'Twelve Data via TradePilot Data Gateway',
            'observedAt': observed_at,
            'fetchedAt': (
                result.fetched_at.isoformat().replace('+00:00', 'Z')
            ),
            'detail': detail,
        }


def _validate_symbol(symbol: str) -> str:
    normalized = symbol.strip().upper()
    if not _SYMBOL_PATTERN.fullmatch(normalized):
        raise ValueError('Invalid market symbol.')
    return normalized
