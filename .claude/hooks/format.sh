#!/usr/bin/env bash
set -uo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

if command -v npx &>/dev/null; then
    npx --yes prettier --write --log-level warn \
        "CLAUDE.md" ".claude/**/*.md" ".claude/**/*.json" ".claude/**/*.yaml" ".claude/**/*.yml"
fi

if command -v shfmt &>/dev/null; then
    find .claude -name "*.sh" -exec shfmt -w {} +
fi

exit 0
