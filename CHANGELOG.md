# Changelog

## Unreleased

- **Rebranded from EdgeDepth to TradeOS.** Full rename across code, identifiers,
  JS globals, CSS classes, Docker configs, CI workflows, and docs:
  - Display name / window title / wordmark: **TradeOS**
  - `__EDGEDEPTH_*` JS globals → `__TRADEOS_*`
  - Module-private slots: `__edtz`→`__tostz`, `__edlogo`→`__toslogo`,
    `__edclip`→`__tosclip`, `__eddraw`→`__tosdraw`
  - CSS classes `.edgedepth`→`.tos`, `.edgedepth_score`→`.tos_score`
  - Custom DOM event `edgedepth:usage` → `tradeos:usage`
  - Config script: `edgedepth-config.js` → `tradeos-config.js`
  - Design CSS: `design/edgedepth.css` → `design/tradeos.css`
  - Docker containers renamed `tradeos-gateway` / `tradeos-terminal`
- **New brand identity.**
  - TradeOS emblem: open charcoal power-ring with a gap at the top, one gold
    candlestick with wick rising through the gap, two short charcoal depth bars
    behind the body. Rendered in `src/rendering/app_shell.cpp` and exported as
    `design/logo.svg`.
  - Wordmark: "Trade" in charcoal, "OS" in gold (`design/logo-wordmark.svg`).
  - Tagline: **SEE EVERYTHING. EXECUTE ANYTHING.** (replaces the Early Access pill).
- **Brand palette applied as the default theme.**
  - Background `#0E1116`, surface `#14181D`, accent gold `#C9A227`,
    primary text off-white `#F2EFE6`.
  - Market-semantic colors preserved (teal up `#2FD6AD`, rose down `#EE5C78`).
  - Default accent switched from Teal to Gold.
- **Top-level project scaffolding.** `docker-compose.yml`, `scripts/dev-env.sh`
  (`edbuild` / `edserve` / `edtests` aliases), `gateway/` and `strategies/`
  placeholders for TradeOS-layer extensions, `.env.example`, `.gitignore`.
- Removed top-level LICENSE file per repository owner request. The vendored
  third-party notices and font licenses remain under `terminal/THIRD_PARTY_NOTICES.md`.

## Upstream

For changes prior to the rebrand (renderer features, RT view, footprints,
replay, workspace docking, etc.), see the EdgeDepth Terminal git history at
tag `234ce8e` ("Gate replay on synchronized depth and preserve RT visibility"),
from which this repo is vendored.
