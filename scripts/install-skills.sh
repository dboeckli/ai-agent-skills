#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_SRC="$PACKAGE_ROOT/.claude/skills"
SKILLS_DEST="${HOME}/.claude/skills"
STATUSLINE_SRC="$PACKAGE_ROOT/scripts/statusline.sh"
STATUSLINE_DEST="${HOME}/.claude/statusline.sh"
FORMAT_SH="$PACKAGE_ROOT/.claude/hooks/format.sh"
SETTINGS="${HOME}/.claude/settings.json"

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

if [ -f "$SETTINGS" ] && [ -f "$FORMAT_SH" ]; then
    python3 - <<PYEOF
import json, sys

settings_path = "$SETTINGS"
format_sh = "$FORMAT_SH"
hook_command = f'bash "{format_sh}"'

with open(settings_path) as f:
    settings = json.load(f)

hooks = settings.setdefault("hooks", {})
stop_hooks = hooks.setdefault("Stop", [])

already = any(
    h.get("command") == hook_command
    for entry in stop_hooks
    for h in entry.get("hooks", [])
)

if not already:
    stop_hooks.append({"hooks": [{"type": "command", "command": hook_command, "statusMessage": "Formatting files..."}]})
    with open(settings_path, "w") as f:
        json.dump(settings, f, indent=2)
    print("  Installed: Stop hook (format.sh)")
else:
    print("  Stop hook already present")
PYEOF
fi

echo "Done."
