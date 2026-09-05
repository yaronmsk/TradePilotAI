from __future__ import annotations

import threading
import time
from dataclasses import dataclass
from typing import Callable, Generic, Hashable, TypeVar

T = TypeVar('T')


@dataclass
class _Entry(Generic[T]):
    value: T
    capacity: int
    expires_at: float


class SerializedCapacityCache(Generic[T]):
    # Small in-memory cache that also coalesces concurrent upstream loads.
    # A single lock intentionally covers the upstream loader. The Personal Beta
    # gateway favors deterministic credit protection over maximum concurrency.

    def __init__(self, *, clock: Callable[[], float] = time.monotonic) -> None:
        self._clock = clock
        self._lock = threading.Lock()
        self._entries: dict[Hashable, _Entry[T]] = {}
        self._hits = 0
        self._misses = 0

    def get_or_load(
        self,
        key: Hashable,
        *,
        required_capacity: int,
        ttl_seconds: float,
        loader: Callable[[], tuple[T, int]],
    ) -> tuple[T, bool]:
        if required_capacity < 1:
            raise ValueError('required_capacity must be positive')

        with self._lock:
            now = self._clock()
            entry = self._entries.get(key)
            if (
                entry is not None
                and entry.expires_at > now
                and entry.capacity >= required_capacity
            ):
                self._hits += 1
                return entry.value, True

            self._misses += 1
            value, loaded_capacity = loader()
            self._entries[key] = _Entry(
                value=value,
                capacity=loaded_capacity,
                expires_at=now + ttl_seconds,
            )
            return value, False

    def stats(self) -> dict[str, int]:
        with self._lock:
            now = self._clock()
            active_entries = sum(
                1 for entry in self._entries.values()
                if entry.expires_at > now
            )
            return {
                'entries': active_entries,
                'hits': self._hits,
                'misses': self._misses,
            }
