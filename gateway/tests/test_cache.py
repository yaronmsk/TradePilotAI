import unittest

from tradepilot_gateway.cache import SerializedCapacityCache


class SerializedCapacityCacheTest(unittest.TestCase):
    def test_reuses_superset_capacity_until_expiry(self):
        now = [10.0]
        cache = SerializedCapacityCache(clock=lambda: now[0])
        loads = []

        def loader():
            loads.append('load')
            return {'rows': 130}, 130

        first, first_hit = cache.get_or_load(
            ('AAPL', '5min'),
            required_capacity=48,
            ttl_seconds=30,
            loader=loader,
        )
        second, second_hit = cache.get_or_load(
            ('AAPL', '5min'),
            required_capacity=78,
            ttl_seconds=30,
            loader=loader,
        )

        self.assertFalse(first_hit)
        self.assertTrue(second_hit)
        self.assertEqual(first, second)
        self.assertEqual(loads, ['load'])

        now[0] = 41.0
        cache.get_or_load(
            ('AAPL', '5min'),
            required_capacity=78,
            ttl_seconds=30,
            loader=loader,
        )
        self.assertEqual(loads, ['load', 'load'])


if __name__ == '__main__':
    unittest.main()
