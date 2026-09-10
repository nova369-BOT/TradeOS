#!/usr/bin/env python3
"""Rebrand TradeOS -> TradeOS across all vendored files (one shot, idempotent)."""
import os, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

TEXT_EXTS = {
    '.cpp','.h','.hpp','.c',
    '.js','.html','.css',
    '.md','.txt','.rst',
    '.yml','.yaml','.json',
    '.py','.sh','.bash','.ps1','.fish','.csh',
    '.proto','.cmake','.cfg','.conf',
    '.toml','.ini',
}
SPECIAL_NAMES = {'Dockerfile','CMakeLists.txt','Makefile','LICENSE','.dockerignore','.gitignore','.emscripten'}
SKIP_DIRS = {'.git','node_modules','.cache','.venv','__pycache__','.pytest_cache','.mypy_cache','.next','dist','build','build-Release','build-Debug','build-wsl','build-windows','build-native-tests','out','target'}
BINARY_EXTS = {'.png','.jpg','.jpeg','.gif','.mp4','.ttf','.otf','.woff','.woff2','.ico','.webp','.pdf','.zip','.tar','.gz','.bz2','.xz','.edpack','.wasm','.data','.mem','.map'}

# Longest / most specific first. These are plain string replacements.
REPLACEMENTS = [
    # Display / wordmark
    ("TradeOS Terminal", "TradeOS Terminal"),
    ("TradeOS", "TradeOS"),
    ("TradeOS Terminal", "TradeOS Terminal"),
    ("TradeOS", "TradeOS"),
    # Case variants
    ("TRADEOS", "TRADEOS"),
    ("TRADEOS", "TRADEOS"),
    ("trade-os", "trade-os"),
    ("trade_os", "trade_os"),
    ("tradeOS", "tradeOS"),
    ("tradeos", "tradeos"),
]

# Second-pass: specific module-private identifiers / CSS classes / config files.
SECOND_PASS = [
    # Module-private JS slots (do these after the main brand pass because
    # __TRADEOS_* globals are already renamed to __TRADEOS_* by then)
    ("__tostz",                   "__tostz"),
    ("__toslogo",                 "__toslogo"),
    ("__tosclip",                 "__tosclip"),
    ("__tosdraw_flush_registered","__tosdraw_flush_registered"),
    ("__tosdraw",                 "__tosdraw"),
    # localStorage key
    ("tos_replay_day",           "tos_replay_day"),
    # Dockerfile config script name
    ("tradeos-config.js",      "tradeos-config.js"),
    # CSS / HTML classes
    ("tradeos_score",          "tos_score"),
    ('"tradeos"',              '"tos"'),
    ("'tradeos'",              "'tos'"),
    ("class=\"tradeos\"",       "class=\"tos\""),
    # Custom DOM event name — after the brand pass this is already tradeos:usage,
    # but make sure any quoted 'tradeos:usage' in JS strings is caught.
    ("'tradeos:usage'",        "'tradeos:usage'"),
    ("\"tradeos:usage\"",      "\"tradeos:usage\""),
]

def is_text(p: Path) -> bool:
    if p.suffix.lower() in BINARY_EXTS: return False
    if p.name in SPECIAL_NAMES: return True
    return p.suffix.lower() in TEXT_EXTS

def skip(p: Path) -> bool:
    for part in p.relative_to(ROOT).parts:
        if part in SKIP_DIRS: return True
    return False

def transform(text: str) -> str:
    for a,b in REPLACEMENTS:
        text = text.replace(a,b)
    for a,b in SECOND_PASS:
        text = text.replace(a,b)
    return text

def main():
    n = 0
    for p in ROOT.rglob('*'):
        if not p.is_file() or skip(p) or not is_text(p): continue
        try:
            original = p.read_text(encoding='utf-8')
        except (UnicodeDecodeError, OSError):
            continue
        new = transform(original)
        if new != original:
            p.write_text(new, encoding='utf-8')
            n += 1
    print(f"Rebranded {n} files")

if __name__ == '__main__':
    main()
