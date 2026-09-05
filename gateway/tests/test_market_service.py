import unittest
from datetime import datetime, timezone

from tradepilot_gateway.cache import SerializedCapacityCache
from tradepilot_gateway.market_service import MarketGatewayService
from tradepilot_gateway.rate_limit import MinuteCreditBudget
from tradepilot_gateway.twelve_data_client import TimeSeriesResult


class FakeTwelveDataClient:
    def __init__(self, rows_by_interval=None):
        self.credit_budget = MinuteCreditBudget(7, clock=lambda: 120.0)
        self.calls = []
        self.rows_by_interval = rows_by_interval or {}

    def fetch_time_series(self, *, symbol, interval, outputsize):
        self.credit_budget.acquire()
        self.calls.append((symbol, interval, outputsize))
        row_count = self.rows_by_interval.get(interval, outputsize)
        candles = tuple(
            {
                'timestamp': f'2026-09-{(index % 28) + 1:02d}T12:00:00Z',
                'open': 100.0 + index,
                'high': 101.0 + index,
                'low': 99.0 + index,
                'close': 100.5 + index,
                'volume': 1000.0 + index,
            }
            for index in range(row_count)
        )
        return TimeSeriesResult(
            symbol=symbol,
            interval=interval,
            exchange='NASDAQ',
            exchange_timezone='America/New_York',
            candles=candles,
            fetched_at=datetime(
                2026,
                9,
                5,
                15,
                40,
                tzinfo=timezone.utc,
            ),
        )


class MarketGatewayServiceTest(unittest.TestCase):
    def test_snapshot_and_chart_history_share_one_5min_upstream_fetch(self):
        client = FakeTwelveDataClient()
        service = MarketGatewayService(
            twelve_data=client,
            cache=SerializedCapacityCache(clock=lambda: 10.0),
        )

        snapshot = service.snapshot(
            symbol='aapl',
            timeframe='5m',
            candle_count=48,
        )
        history = service.history(
            symbol='AAPL',
            range_label='1D',
        )

        self.assertEqual(len(snapshot['snapshot']['candles']), 48)
        self.assertEqual(len(history['candles']), 78)
        self.assertEqual(client.calls, [('AAPL', '5min', 130)])
        self.assertEqual(client.credit_budget.snapshot().used, 1)

    def test_daily_snapshot_and_one_year_history_share_one_fetch(self):
        client = FakeTwelveDataClient()
        service = MarketGatewayService(
            twelve_data=client,
            cache=SerializedCapacityCache(clock=lambda: 10.0),
        )

        service.snapshot(
            symbol='AAPL',
            timeframe='1d',
            candle_count=90,
        )
        history = service.history(
            symbol='AAPL',
            range_label='1Y',
        )

        self.assertEqual(len(history['candles']), 252)
        self.assertEqual(client.calls, [('AAPL', '1day', 260)])

    def test_short_source_history_is_partial_live_not_fabricated(self):
        client = FakeTwelveDataClient(rows_by_interval={'1day': 20})
        service = MarketGatewayService(
            twelve_data=client,
            cache=SerializedCapacityCache(clock=lambda: 10.0),
        )

        payload = service.history(
            symbol='NEWCO',
            range_label='1M',
        )

        self.assertEqual(payload['provenance']['state'], 'PARTIAL_LIVE')
        self.assertEqual(len(payload['candles']), 20)

    def test_three_month_candle_timeframe_is_explicitly_unsupported(self):
        client = FakeTwelveDataClient()
        service = MarketGatewayService(twelve_data=client)

        with self.assertRaisesRegex(ValueError, 'aggregation policy'):
            service.snapshot(
                symbol='AAPL',
                timeframe='3mo',
                candle_count=40,
            )


if __name__ == '__main__':
    unittest.main()
