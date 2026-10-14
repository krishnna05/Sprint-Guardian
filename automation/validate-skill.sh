#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="${ROOT_DIR}/../.venv-jira-tools"
VENV_PYTHON="${VENV_DIR}/bin/python"
if [[ ! -f "$VENV_PYTHON" && -f "${VENV_DIR}/Scripts/python.exe" ]]; then
  VENV_PYTHON="${VENV_DIR}/Scripts/python.exe"
fi

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
VALIDATOR="${CODEX_SKILL_VALIDATOR:-${CODEX_HOME}/skills/.system/skill-creator/scripts/quick_validate.py}"
TARGET="${1:-$ROOT_DIR}"

if [[ ! -f "$VENV_PYTHON" ]]; then
  printf 'Missing venv python at %s\n' "$VENV_PYTHON" >&2
  exit 1
fi

if [[ ! -f "$VALIDATOR" ]]; then
  printf 'Codex skill validator not found at %s\n' "$VALIDATOR" >&2
  printf 'Install skill-creator or set CODEX_SKILL_VALIDATOR to quick_validate.py.\n' >&2
  exit 1
fi

exec "$VENV_PYTHON" "$VALIDATOR" "$TARGET"
