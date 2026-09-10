# Strategies (planned)

Pluggable strategies that run against the terminal's data plane. Strategies can
be written in:

- **Python** via the same websocket/protobuf feed the terminal consumes
  (see `terminal/examples/file_feed.py`), OR
- **C++** inside the WASM client for tight chart overlay integration (see
  `src/ui/indicators/` for existing indicator examples).
