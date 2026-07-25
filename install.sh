#!/usr/bin/env bash
# Install ai-agent-skills: clone or pull the repository, then symlink all skills
# into ~/.claude/skills/ and the statusline script into ~/.claude/statusline.sh.
#
# Usage: bash install.sh [repo-url]
#   repo-url  GitHub URL to clone from. Optional when run from within the repo.
#
# Env overrides:
#   INSTALL_DIR          Clone target  (default: ~/projects/ai-agent-skills)
#   SKILLS_TARGET_DIR    Symlink target (default: ~/.claude/skills)
#
# Exit codes: 0=ok, 1=bad args, 2=local changes present (pull skipped), 3=clone/pull failed

set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-$HOME/projects/ai-agent-skills}"
SKILLS_TARGET_DIR="${SKILLS_TARGET_DIR:-$HOME/.claude/skills}"

# Determine repo URL: prefer argument, then git remote of current repo
REPO_URL="${1:-}"
if [[ -z "$REPO_URL" ]] && git rev-parse --git-dir &>/dev/null 2>&1; then
    REPO_URL="$(git remote get-url origin 2>/dev/null || true)"
fi
if [[ -z "$REPO_URL" ]]; then
    echo "error: repository URL required. Usage: $0 <repo-url>" >&2
    exit 1
fi

# ── Clone or pull ────────────────────────────────────────────────────────────

if [[ -d "$INSTALL_DIR/.git" ]]; then
    STATUS="$(git -C "$INSTALL_DIR" status --porcelain)"
    if [[ -n "$STATUS" ]]; then
        echo "SKIP  $INSTALL_DIR — local changes present, not pulling:"
        git -C "$INSTALL_DIR" status --short | sed 's/^/      /'
        exit 2
    fi
    echo "PULL  $INSTALL_DIR"
    if git -C "$INSTALL_DIR" pull --ff-only 2>&1; then
        echo "      OK"
    else
        echo "      FAILED (not fast-forward or network error)" >&2
        exit 3
    fi
else
    echo "CLONE $REPO_URL → $INSTALL_DIR"
    if git clone "$REPO_URL" "$INSTALL_DIR" --quiet 2>&1; then
        echo "      OK"
    else
        echo "      FAILED" >&2
        exit 3
    fi
fi

# ── Symlink skills ───────────────────────────────────────────────────────────

mkdir -p "$SKILLS_TARGET_DIR"

linked=0
skipped=0

for skill_dir in "$INSTALL_DIR/.claude/skills"/*/; do
    [[ -f "${skill_dir}SKILL.md" ]] || continue

    skill_name="$(basename "${skill_dir%/}")"
    target="$SKILLS_TARGET_DIR/$skill_name"

    if [[ -L "$target" ]]; then
        echo "SKIP  $skill_name — symlink already exists"
        ((skipped++)) || true
    elif [[ -e "$target" ]]; then
        echo "WARN  $skill_name — $target exists and is not a symlink, skipping" >&2
        ((skipped++)) || true
    else
        ln -s "${skill_dir%/}" "$target"
        echo "LINK  $skill_name → $target"
        ((linked++)) || true
    fi
done

# ── Symlink scripts ──────────────────────────────────────────────────────────

symlink_script() {
    local source="$1" target="$2" label="$3"
    if [[ ! -f "$source" ]]; then
        echo "SKIP  $label — source not found in installed repo"
        ((skipped++)) || true
        return
    fi
    if [[ -L "$target" ]]; then
        echo "SKIP  $label — symlink already exists"
        ((skipped++)) || true
    elif [[ -e "$target" ]]; then
        echo "WARN  $label — $target exists and is not a symlink, skipping" >&2
        ((skipped++)) || true
    else
        chmod +x "$source"
        ln -s "$source" "$target"
        echo "LINK  $label → $target"
        ((linked++)) || true
    fi
}

symlink_script \
    "$INSTALL_DIR/scripts/statusline.sh" \
    "$HOME/.claude/statusline.sh" \
    "statusline.sh"

mkdir -p "$HOME/.claude/scripts"
symlink_script \
    "$INSTALL_DIR/scripts/camel-springboot-matrix.sh" \
    "$HOME/.claude/scripts/camel-springboot-matrix.sh" \
    "camel-springboot-matrix.sh"

echo ""
echo "Done. $linked item(s) linked, $skipped skipped."
echo "Skills are available in Claude Code via /skill-name."
