#!/usr/bin/env bash
# Source this file to set up the TradeOS / TradeOS dev environment.
#
# Usage:  source scripts/dev-env.sh
#
# Puts cmake, ninja, protoc (from $HOME/.venv) and emcc/emcmake (from emsdk)
# on PATH and exports $TRADEOS_ROOT / $TOS_TERMINAL_DIR.

TRADEOS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export TRADEOS_ROOT
TOS_TERMINAL_DIR="$TRADEOS_ROOT/terminal"
export TOS_TERMINAL_DIR

VENV="$HOME/.venv"
EMSDK="$HOME/.local/tools/emsdk"

# Python venv (cmake, ninja, protoc)
if [ -d "$VENV" ]; then
  # shellcheck disable=SC1091
  source "$VENV/bin/activate"
fi

# Emscripten SDK (emcc, em++, emcmake)
if [ -f "$EMSDK/emsdk_env.sh" ]; then
  # shellcheck disable=SC1091
  source "$EMSDK/emsdk_env.sh" >/dev/null 2>&1 || true
fi

_tosbuild() {
  local btype="${1:-Release}"
  local jobs="${2:-$(nproc)}"
  local builddir="$TOS_TERMINAL_DIR/build-$btype"
  mkdir -p "$builddir"
  if [ ! -f "$builddir/build.ninja" ]; then
    echo "==> Configuring ($btype) in $builddir"
    (cd "$builddir" && emcmake cmake -G Ninja -DCMAKE_BUILD_TYPE="$btype" "$TOS_TERMINAL_DIR")
  fi
  echo "==> Building terminal ($btype) with $jobs jobs"
  cmake --build "$builddir" --target c_based_trader_client --parallel "$jobs"
}

_tosserve() {
  local port="${1:-8000}"
  local dir="${2:-$TOS_TERMINAL_DIR/build-Release}"
  echo "==> Serving $dir on http://0.0.0.0:$port (COOP/COEP enabled for SharedArrayBuffer)"
  python3 "$TOS_TERMINAL_DIR/serve_threaded.py" "$port" "$dir"
}

_tostests() {
  local bdir="$TOS_TERMINAL_DIR/build-native-tests"
  mkdir -p "$bdir"
  if [ ! -f "$bdir/build.ninja" ]; then
    echo "==> Configuring native tests"
    (cd "$bdir" && cmake -G Ninja -DCMAKE_BUILD_TYPE=Release "$TOS_TERMINAL_DIR/tests/native")
  fi
  cmake --build "$bdir" --parallel "$(nproc)"
  (cd "$bdir" && ctest -C Release --output-on-failure "$@")
}

alias edbuild='_tosbuild'
alias edserve='_tosserve'
alias edtests='_tostests'

cat <<EOF
TradeOS dev env ready.
  TRADEOS_ROOT=$TRADEOS_ROOT
  TOS_TERMINAL_DIR    =$TOS_TERMINAL_DIR
  emcc       =$(command -v emcc    2>/dev/null || echo "(emsdk not installed — see terminal/README.md)")
  cmake      =$(command -v cmake   2>/dev/null || echo MISSING)
  ninja      =$(command -v ninja   2>/dev/null || echo MISSING)
  protoc     =$(command -v protoc  2>/dev/null || echo MISSING)

Commands:
  edbuild [Release|Debug] [jobs]   configure (if needed) + build WASM
  edserve [port] [dir]             COOP/COEP static server (default :8000, build-Release)
  edtests                          build + run native tests
  docker compose up                run prebuilt terminal + gateway on :8080

  tosbuild/tosserve/tostests      TradeOS-prefixed aliases for the above
EOF

# TradeOS-prefixed aliases (same as edbuild/edserve/edtests)
alias tradeos-build='_tosbuild'
alias tradeos-serve='_tosserve'
alias tradeos-tests='_tostests'
alias tosbuild='_tosbuild'
alias tosserve='_tosserve'
alias tostests='_tostests'
