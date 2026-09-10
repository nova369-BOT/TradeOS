# TradeOS

> **SEE EVERYTHING. EXECUTE ANYTHING.**

A local-first orderflow trading terminal and workbench that runs entirely in your
browser. C++20 compiled to WebAssembly; Dear ImGui + ImPlot for immediate-mode
rendering; SDL3 + WebGL2 underneath; protobuf over WebSocket for market data. No
Electron, no DOM in the hot path, no garbage collector between you and the tape.

![TradeOS workspace](terminal/assets/screenshot.png)

This repository is TradeOS itself: the full renderer, the chart engine, the DOM
ladder, trade tape, footprint, volume profile, TPO, liquidation heatmap, replay
engine, replay library, paper trading, and workspace docking. It is not a demo
build or a stripped-down "community edition" — every widget ships here.

Run it against a local exchange feed, point it at your own wire-compatible data,
or use deterministic `.edpack` recordings as repeatable fixtures.

## Quick start

The fastest way to see it running is Docker Compose (pulls the prebuilt WASM
image alongside the community Binance Futures gateway):

```bash
docker compose up
```

Then open **http://localhost:8080**. No API key, no account, no signup.

To compile the WebAssembly from source instead of pulling prebuilt images:

```bash
docker compose up --build
```

**Browsers.** The canvas is threaded WebAssembly, so it needs WebGL2,
`SharedArrayBuffer` and a cross-origin-isolated page; the bundled nginx sends the
COOP/COEP headers that buys that. If the canvas never appears, check
`crossOriginIsolated` in the console: `false` means something upstream (a proxy,
an extension) stripped the headers.

## Features

- **Chart engine** — custom ImPlot candlesticks, multi-timeframe (1s to 1D), buy/sell volume + CVD, indicators (RSI, MACD, Volume, OI, funding), drawing tools, layered overlays.
- **DOM ladder** — independent depth with grouping, USD/coin modes, trade columns, or an RT-linked view that shares the chart's price positions.
- **Trade tape** — live time & sales with size highlighting.
- **Orderbook heatmap** — GPU-rendered depth history via a shader-based renderer.
- **Volume profile (VPVR) and footprint** — per-price volume, same-price and diagonal imbalances, consecutive same-side stacks.
- **TPO / Market Profile** — 30-minute candle-range approximation.
- **Liquidation heatmap layers** — dense Field, leverage-tier levels, profile rendering (computed client-side from candles; works on any feed).
- **Market replay** — deterministic replay engine with scrubbing; self-contained `.edpack` files play entirely client-side.
- **Replay Library** — a manifest-driven browser of curated `.edpack` recordings for local replay and regression testing.
- **Paper trading** — simulated positions against live data.
- **Docking layout** — drag, split, and persist panel arrangements (ImGui docking).
- **Watchlist / scanner** — every symbol the feed lists, with 24h stats.
- **Wire format** — zstd-compressed protobuf (`protos/messages.proto`), decoded off the render thread.

## Building from source

To hack the C++ you need:

- **Emscripten SDK** ≥ 4.0.15 (SDL3 port support — 3.x will not build)
- **`protoc`** 21.x
- **CMake** 3.15+ and **Ninja**
- A working C++17 host compiler (for native tests)

All other dependencies are fetched and pinned by CMake; there are no submodules.

```bash
source scripts/dev-env.sh     # puts emcc/cmake/ninja/protoc on PATH, adds aliases
edbuild Release               # emcmake configure + build -> terminal/build-Release/
edserve 8000                  # COOP/COEP static server on http://localhost:8000
```

### Native tests

```bash
edtests
```

## Layout

```
TradeOS/
├── terminal/             # WASM client (C++/ImGui/ImPlot/SDL3/WebGL2)
│   ├── src/core/         # data thread, orderbook, candles, footprint, heatmap, replay...
│   ├── src/rendering/    # app shell, layout, menu, theme, shader renderers
│   ├── src/ui/           # chart, DOM, tape, watchlist, indicators, drawings...
│   ├── src/replayer/     # pack replay engine + history buffer
│   ├── src/education/    # lesson / studio / recorder runtimes
│   ├── protos/           # WebSocket wire format
│   ├── examples/         # Python reference feeds (synthetic, CSV/Parquet)
│   ├── design/           # design tokens, CSS, TradeOS logo/wordmark SVGs
│   ├── replay-library/   # manifest + curated replay catalog
│   └── tests/            # native (host g++) and WASM integration tests
├── gateway/              # TradeOS market-data gateway adapters (planned)
├── strategies/           # Pluggable strategies and backtests (planned)
├── scripts/              # dev helpers (dev-env.sh, rebrand.py)
└── docker-compose.yml    # terminal + community gateway on :8080
```

## Bring your own data

The terminal is a client. It resolves its WebSocket in this order:

1. `?ws=ws://localhost:8080/ws` query parameter
2. `window.__TRADEOS_WS_URL__` set by the host page before the WASM glue loads
3. The hosted backend default (`wss://api.edgedepth.com/ws`)

The schema in [`terminal/protos/messages.proto`](terminal/protos/messages.proto) is
the contract. [`terminal/examples/synthetic_feed.py`](terminal/examples/synthetic_feed.py)
is a working zero-dependency feed that answers historical candle requests and
streams trades plus an order book — enough to drive the chart, the tape and the
DOM.

See [`terminal/docs/DATAFRAME_WORKFLOW.md`](terminal/docs/DATAFRAME_WORKFLOW.md)
for a reproducible CSV/Parquet walkthrough that puts explicit trades on the
chart, tape, footprint and volume profile with no exchange access.

## Design system

The TradeOS visual language:

| Token | Value | Use |
|---|---|---|
| Background | `#0E1116` | App background, chart canvas |
| Surface | `#14181D` | Panels, chrome |
| Accent | `#C9A227` (gold) | Brand, selection, focus, on-state controls |
| Text | `#F2EFE6` | Primary numerals, titles |
| Up / bid | `#2FD6AD` (teal) | Up candles, bid side, positive deltas |
| Down / ask | `#EE5C78` (rose) | Down candles, ask side, negative deltas |

Tokens live in [`terminal/design/tokens.json`](terminal/design/tokens.json); the
CSS mirror is [`terminal/design/tradeos.css`](terminal/design/tradeos.css).
`terminal/src/rendering/theme.{h,cpp}` mirrors them into ImGui/ImPlot styles at
runtime.

Logo and wordmark SVGs:

- [`terminal/design/logo.svg`](terminal/design/logo.svg) — TradeOS emblem
  (open power-ring in charcoal with a gap at the top, one gold candlestick whose
  wick rises through the gap, two charcoal depth bars behind the body).
- [`terminal/design/logo-wordmark.svg`](terminal/design/logo-wordmark.svg) —
  full lockup: emblem + "Trade" (charcoal) + "OS" (gold).

## Contributing

PRs welcome. See [`CONTRIBUTING.md`](CONTRIBUTING.md). The render loop has
strict conventions: no allocation in the frame path, `PriceFormatter` for all
price text, theme tokens for all colors.

## See also

- **[synthetic_feed.py](terminal/examples/synthetic_feed.py)** — drop-in
  zero-dependency Python feed for local development.
- **[edgedepth-gateway](https://github.com/edgedepthhq/edgedepth-gateway)** —
  MIT-licensed Binance public-stream bridge (the default `docker compose` feed).
- **[ARCHITECTURE.md](terminal/ARCHITECTURE.md)** — source-linked build,
  threading, live-data, replay, rendering and browser-deployment design.
- **[EDPACK.md](terminal/docs/EDPACK.md)** — deterministic replay container
  format (magic/version, block index, framing, compression).
- **[REALTIME_DEPTH.md](terminal/docs/REALTIME_DEPTH.md)** — RT observed-depth
  view, retention, replay semantics.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).
