# Contributing to TradeOS

Thanks for hacking on TradeOS. A few conventions keep the renderer fast and
the codebase consistent.

## Ground rules

- **No allocations in the frame path.** The render thread runs inside a single
  `ImGui::NewFrame`/`Render` cycle that targets 60–180 fps on commodity hardware.
  If you are adding code that runs per-frame, pre-allocate in `init()` or in a
  manager constructor, and recycle buffers. `std::string` concatenations,
  `std::vector::push_back` without `reserve()`, and `ImGui::Text("...")` with
  `std::string::c_str()` where a static literal would do are the usual traps.
- **All price text goes through `PriceFormatter`.** Never `snprintf("%.2f", p)`
  or call ImGui's default float formatting directly — that path ignores the
  symbol's tick size and will render sub-penny prices on BTC and wrong decimals
  on JPY pairs.
- **All colors come from theme tokens.** Don't hardcode `ImVec4(0.2f, ...)` or
  hex constants in widget code. Use `Tokens::BRAND`, `Tokens::UP`,
  `Tokens::TX1`, etc. and extend `theme.h` if a new semantic color is needed.
- **Wire-format changes are version-gated.** `protos/messages.proto` is the
  contract with any gateway feed. Existing fields must not change tag numbers;
  new fields are optional and the client must degrade gracefully when they're
  absent.

## Build & test

```bash
source scripts/dev-env.sh
edbuild Release          # configure + build WASM
edserve 8000             # serve on http://localhost:8000 with COOP/COEP
edtests                  # native tests
```

The WASM build targets Emscripten ≥ 4.0.15 (SDL3 port); older emsdk releases
fail on `<SDL3/SDL.h>`. `protoc` must be 21.x — the protobuf-lite runtime the
client builds against is v21.12, and newer protoc generates code that does not
compile against it.

Native tests compile with the host g++ under `terminal/tests/native/` and cover
the pure helpers (TPO, URL routing, workspace docs, research snap, renko,
reference context). They are a good smoke test before sending a PR: they do
not require Emscripten and finish in seconds.

## Pull requests

Keep PRs focused. A PR should do one of:

- Add / fix one widget or indicator
- Add one feed adapter
- Fix one bug
- Tighten one piece of the render loop

Mixing a theme change with a new indicator and a refactor of the message
parser makes review slower and regressions harder to bisect.

## Running the whole stack

```bash
docker compose up          # pulls prebuilt terminal + Binance gateway on :8080
docker compose up --build  # compile WASM from source inside the build container
```

## File layout

- `terminal/src/core/` — data thread, managers, message parsing, protobuf glue.
  No ImGui calls here; this is where the non-rendering state lives.
- `terminal/src/rendering/` — app shell, layout, menu, theme, shader renderers,
  the render loop entry point.
- `terminal/src/ui/` — ImGui widgets (chart, DOM, tape, watchlist, drawings,
  indicators, replay library, paper-trading panel).
- `terminal/src/replayer/` — pack replay engine.
- `terminal/src/education/` — lesson/studio/recorder runtime (hosted product
  chrome; the local build degrades gracefully).
- `terminal/src/types/` — generic containers (flat_map, stack_arena, frame
  profiler, types helpers).
- `gateway/` — TradeOS-layer feed adapters (planned; currently uses the
  upstream edgedepth-gateway image).
- `strategies/` — pluggable strategies and backtests (planned).

## Questions

Open an issue on GitHub. TradeOS is a fork of EdgeDepth Terminal, so renderer
bugs and wire-format questions that aren't TradeOS-specific may also be
relevant upstream.
