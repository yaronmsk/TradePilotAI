import unittest

from tradepilot_gateway.rate_limit import MinuteCreditBudget, RateLimitExceeded


class MinuteCreditBudgetTest(unittest.TestCase):
    def test_enforces_safety_budget_and_resets_next_minute(self):
        now = [120.0]
        budget = MinuteCreditBudget(7, clock=lambda: now[0])

        for _ in range(7):
            budget.acquire()

        with self.assertRaises(RateLimitExceeded) as caught:
            budget.acquire()

        self.assertEqual(caught.exception.retry_after_seconds, 60)
        self.assertEqual(budget.snapshot().remaining, 0)

        now[0] = 180.0
        budget.acquire()
        self.assertEqual(budget.snapshot().used, 1)


if __name__ == '__main__':
    unittest.main()
