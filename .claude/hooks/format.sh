#!/usr/bin/env bash
set -uo pipefail

# Scope intentionally limited to CLAUDE.md and .claude/ files.
# Spring Boot projects configure Spotless (with Flexmark for Markdown) in their
# pom.xml — running Prettier across all project files would conflict with that
# formatter and produce incompatible output.

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
