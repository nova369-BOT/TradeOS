# TradeOS Gateway (planned)

Custom market-data feed adapters for TradeOS. The wire-format contract is
[`terminal/protos/messages.proto`](../terminal/protos/messages.proto).

Right now the default `docker compose up` stack pulls
[edgedepth-gateway](https://github.com/edgedepthhq/edgedepth-gateway), a
Binance-futures community bridge under `ghcr.io/edgedepthhq/edgedepth-gateway`.
That image is a fine starting point for local development: it streams trades,
L2, candles, ticker, funding, stats and OI over the schema the terminal expects,
with no API key.

Planned adapters in this directory:

- Bybit USDT perpetuals
- Hyperliquid
- Coinbase L3
- OANDA FX
- IBKR

See [`terminal/examples/synthetic_feed.py`](../terminal/examples/synthetic_feed.py)
for a zero-dependency reference feed (no exchange access required) and
[`terminal/docs/DATAFRAME_WORKFLOW.md`](../terminal/docs/DATAFRAME_WORKFLOW.md)
for a reproducible CSV/Parquet replay walkthrough.
