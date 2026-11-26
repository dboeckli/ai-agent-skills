#!/usr/bin/env bash
set -uo pipefail

# Manual formatter for this repository (no hook).
# Scope intentionally limited to AGENTS.md, .agents/ and docs/ files.
# Spring Boot projects configure Spotless (with Flexmark for Markdown) in their
# pom.xml — running Prettier across all project files would conflict with that
# formatter and produce incompatible output.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

if command -v npx &>/dev/null; then
	npx --yes prettier --write --log-level warn --no-error-on-unmatched-pattern \
		"AGENTS.md" ".agents/**/*.md" ".agents/**/*.json" ".agents/**/*.yaml" ".agents/**/*.yml" "docs/**/*.md"
fi

if command -v shfmt &>/dev/null; then
	find .agents scripts -name "*.sh" -exec shfmt -w {} +
fi

exit 0
