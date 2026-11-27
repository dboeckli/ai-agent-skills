#!/usr/bin/env bash
# Validate SKILL.md frontmatter for skills CLI compatibility.
#
# Read-only: this script only reads skill files and never modifies them.
# It never downloads or executes packages from the network.
#
# Usage:
#   bash validate-skills.sh           # local YAML check only
#   bash validate-skills.sh --remote  # local check + installed skills CLI listing
#
# Exit codes: 0 = all ok, 1 = errors found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SKILLS_DIR="$REPO_ROOT/.agents/skills"
PYTHON_BIN="${PYTHON:-python3}"
SKILLS_CLI_VERSION="${SKILLS_CLI_VERSION:-1.9.0}"
REMOTE=false
errors=0

[[ "${1:-}" == "--remote" ]] && REMOTE=true

frontmatter() { awk '/^---$/{n++; if(n==2)exit; next} n==1{print}' "$1"; }

for skill_md in "$SKILLS_DIR"/*/SKILL.md; do
	[[ -f "$skill_md" ]] || continue
	skill="$(basename "$(dirname "$skill_md")")"
	fm="$(frontmatter "$skill_md")"
	fail=false

	output="$("$PYTHON_BIN" "$SCRIPT_DIR/validate_frontmatter.py" <<<"$fm" 2>&1)" || {
		echo "FAIL  $skill — $output"
		fail=true
		errors=$((errors + 1))
	}

	if ! $fail; then
		while IFS= read -r line; do
			[[ "$line" == WARN* ]] && echo "WARN  $skill — ${line#WARN }"
		done <<<"$output"
		echo "OK    $skill"
	fi
done

echo ""
[[ $errors -eq 0 ]] && echo "Local: all skills valid" || echo "Local: $errors error(s) found"

if $REMOTE; then
	REPO_URL="$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || true)"
	[[ -z "$REPO_URL" ]] && {
		echo "error: no git remote 'origin' found" >&2
		exit 1
	}
	echo ""
	if command -v skills >/dev/null 2>&1; then
		echo "Remote: skills add --list $REPO_URL"
		echo ""
		skills add --list "$REPO_URL" 2>&1 |
			sed 's/\x1b\[[0-9;]*[mGJhls?]//g; s/\r//g' |
			grep -E "(Skipped|Found [0-9]|Available Skills|  [a-z])" || true
	else
		echo "Remote check skipped: 'skills' CLI not installed."
		echo "Install a pinned version with:"
		echo "  npm install -g skills@${SKILLS_CLI_VERSION}"
		echo "Then run:"
		echo "  skills add --list $REPO_URL"
	fi
fi

exit $((errors > 0))
