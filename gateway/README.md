# TradeOS Gateway (planned)

Custom market-data feed adapters for the terminal. Start from
[`terminal/examples/synthetic_feed.py`](../terminal/examples/synthetic_feed.py)
(the wire-format reference) or fork
[edgedepth-gateway](https://github.com/edgedepthhq/edgedepth-gateway) to add:

- Bybit USDT perpetuals
- Hyperliquid
- Coinbase L3
- OANDA FX
- IBKR

See [`terminal/protos/messages.proto`](../terminal/protos/messages.proto) for the
protobuf contract the terminal speaks.
