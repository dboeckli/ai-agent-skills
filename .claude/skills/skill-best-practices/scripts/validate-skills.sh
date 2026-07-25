#!/usr/bin/env bash
# Validate SKILL.md frontmatter for npx skills CLI compatibility.
# Run from anywhere within the repository.
#
# Usage:
#   bash scripts/validate-skills.sh           # local YAML check only
#   bash scripts/validate-skills.sh --remote  # local check + npx skills add --list (requires pushed changes)
#
# Exit codes: 0 = all ok, 1 = errors found

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SKILLS_DIR="$REPO_ROOT/.claude/skills"
REMOTE=false
errors=0

[[ "${1:-}" == "--remote" ]] && REMOTE=true

# Extract YAML frontmatter between the first pair of --- delimiters
frontmatter() { awk '/^---$/{n++; if(n==2)exit; next} n==1{print}' "$1"; }

for skill_md in "$SKILLS_DIR"/*/SKILL.md; do
    [[ -f "$skill_md" ]] || continue
    skill="$(basename "$(dirname "$skill_md")")"
    fm="$(frontmatter "$skill_md")"
    fail=false

    # 1. Block scalar in description (> or |) — skills CLI YAML parser rejects these
    if echo "$fm" | grep -qE '^description:[[:space:]]*[>|][[:space:]]*$'; then
        echo "FAIL  $skill — description uses block scalar (> or |); replace with a quoted single-line string"
        fail=true
    fi

    # 2. Unindented sub-keys under a parent mapping key
    #    e.g.  metadata:\nauthor: foo  must be  metadata:\n  author: foo
    if echo "$fm" | awk '
        /^[a-zA-Z_-]+:[[:space:]]*$/ { parent=1; next }
        parent && /^[a-zA-Z_-]+:/ { print "unindented"; exit }
        { parent=0 }
    ' | grep -q unindented; then
        echo "FAIL  $skill — sub-key not indented under parent mapping (causes YAML parse error)"
        fail=true
    fi

    # 3. Description length
    desc="$(echo "$fm" | awk '/^description:/{sub(/^description:[[:space:]]*/,""); gsub(/^"|"$/,""); print; exit}')"
    if [[ ${#desc} -gt 1024 ]]; then
        echo "WARN  $skill — description is ${#desc} chars (limit: 1024)"
    fi

    if ! $fail; then
        echo "OK    $skill"
    else
        ((errors++)) || true
    fi
done

echo ""
[[ $errors -eq 0 ]] && echo "Local: all skills valid" || echo "Local: $errors error(s) found"

if $REMOTE; then
    REPO_URL="$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || true)"
    [[ -z "$REPO_URL" ]] && { echo "error: no git remote 'origin' found" >&2; exit 1; }
    echo ""
    echo "Remote: npx skills add --list $REPO_URL"
    echo ""
    _tmp="$(mktemp -d)"
    trap 'rm -rf "$_tmp"' EXIT
    TMPDIR="$_tmp" npm_config_cache="$_tmp/cache" \
        npx --yes --package=skills skills add --list "$REPO_URL" 2>&1 \
        | sed 's/\x1b\[[0-9;]*[mGJhls?]//g; s/\r//g' \
        | grep -E "(Skipped|Found [0-9]|Available Skills|  [a-z])" || true
fi

exit $((errors > 0))
