#!/usr/bin/env python3
"""Validate SKILL.md YAML frontmatter.

Read-only helper for validate-skills.sh. Reads frontmatter from stdin, checks the
required fields and prints "OK"/"WARN" lines or an error message. It never
modifies files and performs no network access.
"""

import sys

try:
    import yaml
except ImportError:
    print("PyYAML is required (pip install pyyaml)")
    sys.exit(1)


def main() -> int:
    content = sys.stdin.read()
    try:
        data = yaml.safe_load(content) or {}
    except yaml.YAMLError as exc:
        print(str(exc).replace("\n", " "))
        return 1

    if not isinstance(data, dict):
        print("frontmatter is not a mapping")
        return 1

    name = data.get("name", "")
    desc = str(data.get("description", ""))
    if not name:
        print("missing required field: name")
        return 1
    if not desc:
        print("missing required field: description")
        return 1
    if len(desc) > 1024:
        print(f"WARN description is {len(desc)} chars (limit: 1024)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
