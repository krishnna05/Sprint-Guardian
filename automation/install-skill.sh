#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_ROOT="${CODEX_HOME:-$HOME/.codex}/skills"
TARGET_LINK="$TARGET_ROOT/sprint-guardian"

mkdir -p "$TARGET_ROOT"

if [[ -e "$TARGET_LINK" ]]; then
  if [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* ]]; then
    cmd //c rmdir "$(cygpath -w "$TARGET_LINK")" 2>/dev/null || rm -rf "$TARGET_LINK"
  else
    rm -f "$TARGET_LINK"
  fi
fi

if [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* ]]; then
  cmd //c mklink //J "$(cygpath -w "$TARGET_LINK")" "$(cygpath -w "$ROOT_DIR")" >/dev/null
  printf 'Linked %s -> %s\n' "$TARGET_LINK" "$ROOT_DIR"
else
  ln -s "$ROOT_DIR" "$TARGET_LINK"
  printf 'Linked %s -> %s\n' "$TARGET_LINK" "$ROOT_DIR"
fi
