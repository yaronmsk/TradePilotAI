#!/usr/bin/env python3
from tradepilot_gateway.config import GatewayConfig
from tradepilot_gateway.server import run_server

if __name__ == '__main__':
    run_server(GatewayConfig.from_environment())
