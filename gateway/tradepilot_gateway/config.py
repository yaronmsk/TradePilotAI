from __future__ import annotations

import os
from dataclasses import dataclass


@dataclass(frozen=True)
class GatewayConfig:
    twelve_data_api_key: str
    host: str = '127.0.0.1'
    port: int = 8787
    upstream_credits_per_minute: int = 7

    @classmethod
    def from_environment(cls) -> 'GatewayConfig':
        api_key = os.environ.get('TWELVE_DATA_API_KEY', '').strip()
        if not api_key:
            raise RuntimeError(
                'TWELVE_DATA_API_KEY is required. '
                'Keep provider credentials outside the repository.'
            )

        host = os.environ.get(
            'TRADEPILOT_GATEWAY_HOST',
            '127.0.0.1',
        ).strip() or '127.0.0.1'

        port_text = os.environ.get('TRADEPILOT_GATEWAY_PORT', '8787').strip()
        try:
            port = int(port_text)
        except ValueError as error:
            raise RuntimeError(
                'TRADEPILOT_GATEWAY_PORT must be an integer.'
            ) from error

        if port < 1 or port > 65535:
            raise RuntimeError(
                'TRADEPILOT_GATEWAY_PORT must be between 1 and 65535.'
            )

        budget_text = os.environ.get(
            'TRADEPILOT_UPSTREAM_CREDITS_PER_MINUTE',
            '7',
        ).strip()
        try:
            budget = int(budget_text)
        except ValueError as error:
            raise RuntimeError(
                'TRADEPILOT_UPSTREAM_CREDITS_PER_MINUTE must be an integer.'
            ) from error

        if budget < 1:
            raise RuntimeError(
                'TRADEPILOT_UPSTREAM_CREDITS_PER_MINUTE must be positive.'
            )

        return cls(
            twelve_data_api_key=api_key,
            host=host,
            port=port,
            upstream_credits_per_minute=budget,
        )
