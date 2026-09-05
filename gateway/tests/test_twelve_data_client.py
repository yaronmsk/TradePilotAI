import unittest
from datetime import datetime, timezone
from urllib.parse import parse_qs, urlparse

from tradepilot_gateway.rate_limit import MinuteCreditBudget
from tradepilot_gateway.twelve_data_client import (
    HttpJsonResponse,
    TwelveDataClient,
    TwelveDataError,
)


class TwelveDataClientTest(unittest.TestCase):
    def test_normalizes_intraday_ohlcv_without_api_key_in_url(self):
        captured = {}

        def transport(url, headers, timeout):
            captured['url'] = url
            captured['headers'] = dict(headers)
            captured['timeout'] = timeout
            return HttpJsonResponse(
                status=200,
                headers={},
                payload={
                    'meta': {
                        'symbol': 'AAPL',
                        'interval': '5min',
                        'exchange': 'NASDAQ',
                        'exchange_timezone': 'America/New_York',
                    },
                    'values': [
                        {
                            'datetime': '2026-09-04 19:55:00',
                            'open': '319.0',
                            'high': '320.0',
                            'low': '318.8',
                            'close': '319.8',
                            'volume': '100000',
                        },
                        {
                            'datetime': '2026-09-04 19:50:00',
                            'open': '318.5',
                            'high': '319.2',
                            'low': '318.2',
                            'close': '319.0',
                            'volume': '90000',
                        },
                    ],
                    'status': 'ok',
                },
            )

        budget = MinuteCreditBudget(7, clock=lambda: 120.0)
        client = TwelveDataClient(
            api_key='secret-test-key',
            credit_budget=budget,
            transport=transport,
            now=lambda: datetime(2026, 9, 5, 15, 40, tzinfo=timezone.utc),
        )

        result = client.fetch_time_series(
            symbol='aapl',
            interval='5min',
            outputsize=130,
        )

        parsed = urlparse(captured['url'])
        query = parse_qs(parsed.query)
        self.assertNotIn('apikey', query)
        self.assertEqual(query['timezone'], ['UTC'])
        self.assertEqual(query['outputsize'], ['130'])
        self.assertEqual(
            captured['headers']['Authorization'],
            'apikey secret-test-key',
        )
        self.assertEqual(result.candles[0]['timestamp'], '2026-09-04T19:50:00Z')
        self.assertEqual(result.candles[-1]['close'], 319.8)
        self.assertEqual(budget.snapshot().used, 1)

    def test_normalizes_daily_date_using_exchange_timezone(self):
        def transport(url, headers, timeout):
            return HttpJsonResponse(
                status=200,
                headers={},
                payload={
                    'meta': {
                        'symbol': 'AAPL',
                        'interval': '1day',
                        'exchange': 'NASDAQ',
                        'exchange_timezone': 'America/New_York',
                    },
                    'values': [{
                        'datetime': '2026-09-04',
                        'open': '318',
                        'high': '321',
                        'low': '317',
                        'close': '320',
                        'volume': '1000',
                    }],
                    'status': 'ok',
                },
            )

        client = TwelveDataClient(
            api_key='secret-test-key',
            credit_budget=MinuteCreditBudget(7, clock=lambda: 120.0),
            transport=transport,
        )
        result = client.fetch_time_series(
            symbol='AAPL',
            interval='1day',
            outputsize=1,
        )

        # Midnight New York in September is 04:00 UTC. This keeps the market
        # date stable without pretending the daily label is an exact close tick.
        self.assertEqual(
            result.candles[0]['timestamp'],
            '2026-09-04T04:00:00Z',
        )

    def test_propagates_upstream_429(self):
        def transport(url, headers, timeout):
            return HttpJsonResponse(
                status=429,
                headers={'Retry-After': '44'},
                payload={'message': 'Rate limit reached.'},
            )

        client = TwelveDataClient(
            api_key='secret-test-key',
            credit_budget=MinuteCreditBudget(7, clock=lambda: 120.0),
            transport=transport,
        )

        with self.assertRaises(TwelveDataError) as caught:
            client.fetch_time_series(
                symbol='AAPL',
                interval='5min',
                outputsize=48,
            )

        self.assertEqual(caught.exception.status_code, 429)
        self.assertEqual(caught.exception.retry_after_seconds, 44)


if __name__ == '__main__':
    unittest.main()
