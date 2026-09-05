from __future__ import annotations

import math
import threading
import time
from dataclasses import dataclass
from typing import Callable


@dataclass(frozen=True)
class RateLimitSnapshot:
    limit: int
    used: int
    remaining: int
    retry_after_seconds: int


class RateLimitExceeded(RuntimeError):
    def __init__(self, retry_after_seconds: int):
        super().__init__('TradePilot upstream credit safety budget exhausted.')
        self.retry_after_seconds = retry_after_seconds


class MinuteCreditBudget:
    def __init__(
        self,
        limit: int,
        *,
        clock: Callable[[], float] = time.time,
    ) -> None:
        if limit < 1:
            raise ValueError('limit must be positive')

        self._limit = limit
        self._clock = clock
        self._lock = threading.Lock()
        self._minute_bucket: int | None = None
        self._used = 0

    def acquire(self, cost: int = 1) -> None:
        if cost < 1:
            raise ValueError('cost must be positive')

        with self._lock:
            now = self._clock()
            self._roll_bucket(now)

            if self._used + cost > self._limit:
                raise RateLimitExceeded(self._retry_after(now))

            self._used += cost

    def snapshot(self) -> RateLimitSnapshot:
        with self._lock:
            now = self._clock()
            self._roll_bucket(now)
            remaining = max(0, self._limit - self._used)
            return RateLimitSnapshot(
                limit=self._limit,
                used=self._used,
                remaining=remaining,
                retry_after_seconds=self._retry_after(now),
            )

    def _roll_bucket(self, now: float) -> None:
        bucket = int(now // 60)
        if self._minute_bucket != bucket:
            self._minute_bucket = bucket
            self._used = 0

    @staticmethod
    def _retry_after(now: float) -> int:
        return max(1, math.ceil(60 - (now % 60)))
