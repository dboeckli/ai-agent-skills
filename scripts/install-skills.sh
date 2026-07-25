#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_SRC="$PACKAGE_ROOT/.claude/skills"
SKILLS_DEST="${HOME}/.claude/skills"
STATUSLINE_SRC="$PACKAGE_ROOT/scripts/statusline.sh"
STATUSLINE_DEST="${HOME}/.claude/statusline.sh"

mkdir -p "$SKILLS_DEST"

for skill_dir in "$SKILLS_SRC"/*/; do
    skill_name="$(basename "$skill_dir")"
    dest="$SKILLS_DEST/$skill_name"
    rm -rf "$dest"
    ln -s "$skill_dir" "$dest"
    echo "  Linked skill: $skill_name"
done

if [ -f "$STATUSLINE_SRC" ]; then
    cp -f "$STATUSLINE_SRC" "$STATUSLINE_DEST"
    chmod +x "$STATUSLINE_DEST"
    echo "  Installed: statusline.sh"
fi

echo "Done."
