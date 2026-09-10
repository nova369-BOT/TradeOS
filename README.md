# TradeOS

A local orderflow trading workbench. This repo vendors the **EdgeDepth Terminal**
(C++20/WebAssembly, Dear ImGui + ImPlot, SDL3 + WebGL2) under [`terminal/`](terminal/)
and layers TradeOS-specific tools, feed adapters, strategies and automation on top.

## Layout

```
TradeOS/
├── terminal/          # EdgeDepth Terminal (vendored from edgedepthhq/edgedepth-terminal)
│   ├── src/           # C++/WASM client: chart, DOM, tape, heatmaps, replay, paper trading
│   ├── protos/        # WebSocket wire format (protobuf)
│   ├── examples/      # Reference Python feeds (synthetic, CSV/Parquet, dataframe)
│   ├── tests/         # Native (non-WASM) tests
│   ├── Dockerfile     # WASM build + nginx runtime image
│   └── docs/          # Architecture, wire format, replay pack format, RT guide
├── gateway/           # (planned) TradeOS market-data gateway — custom adapters
├── strategies/        # (planned) Python/C++ strategies, backtests, alerts
├── scripts/           # Top-level dev/build/run helpers
├── docker-compose.yml # Wires terminal (+gateway when added) together
└── README.md          # ← you are here
```

The `terminal/` subtree tracks the upstream EdgeDepth Terminal source. Patches that
belong upstream go in via PRs there; TradeOS-only extensions live in top-level
folders or as a small patch layer inside `terminal/`.

## Quick start

The fastest way to see it running is Docker Compose (pulls prebuilt WASM image
and the community Binance Futures gateway):

```bash
docker compose up
```

Then open **http://localhost:8080**.

This runs the exact same terminal you'd get from `edgedepthhq/edgedepth-terminal`
— chart, DOM ladder, trade tape, heatmaps, replay library, paper trading — against
the public Binance feed bridged by `edgedepth-gateway`. No account, no API key.

## Building from source

To hack the C++ you need Emscripten ≥ 4.0.15 (SDL3 port), `protoc` 21.x, CMake
and Ninja. See [`terminal/README.md`](terminal/README.md) for full platform
instructions (Linux, WSL2, Windows, macOS).

Quick Linux/WSL2 path once emsdk is active:

```bash
source scripts/dev-env.sh          # sets PATH for cmake/ninja/protoc/emcc
edbuild Release                    # emcmake configure + build into build-Release/
edserve 8000                       # COOP/COEP static server on :8000
```

Open http://localhost:8000.

## Pointing the terminal at your own data

The terminal is just a client. It resolves its WebSocket in this order:

1. `?ws=ws://host:port/ws` on the query string
2. `window.__EDGEDEPTH_WS_URL__` set by the host page before the glue loads
3. `wss://api.edgedepth.com/ws` (hosted backend, default)

Wire format is documented in [`terminal/protos/messages.proto`](terminal/protos/messages.proto).
Starter feeds live in [`terminal/examples/`](terminal/examples/) — see
`synthetic_feed.py` for a zero-dependency random walk, and
[`terminal/docs/DATAFRAME_WORKFLOW.md`](terminal/docs/DATAFRAME_WORKFLOW.md) for
the CSV/Parquet walkthrough.

## Roadmap (TradeOS layer, on top of EdgeDepth)

- **Custom feed adapters** — Bybit, Hyperliquid, Coinbase L3, OANDA, IBKR
- **Strategy runner** — pluggable Python strategies with a chart overlay API
- **Backtester** — drive strategies off recorded `.edpack` packs for repeatable tests
- **Alerting + webhooks** — condition-triggered notifications to Discord/Telegram
- **Multi-account paper trading** — isolated position books per strategy
- **Research notebook** — Jupyter integration against the same protobuf wire format

Contributions and PRs welcome. See [`terminal/CONTRIBUTING.md`](terminal/CONTRIBUTING.md)
for the renderer conventions (no allocs in the frame path, `PriceFormatter` for
all price text, theme tokens for colors).

## License

The vendored terminal retains its original [AGPL-3.0](terminal/LICENSE).
TradeOS glue code (everything outside `terminal/`) is MIT unless noted.
