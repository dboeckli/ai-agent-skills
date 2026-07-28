# AGENTS.md — AI Agent Skills Repository

This is a **SKILL.md package** — a collection of reusable AI-agent skills, not an application. No build, test, lint, or typecheck commands exist.

## Repository Structure

```
.claude/skills/<skill-name>/
  SKILL.md          # required: YAML frontmatter + Markdown instructions
  references/       # optional: supporting docs loaded on demand
  scripts/          # optional: executable Bash/Python helpers
  assets/           # optional: templates, fonts, icons
```

## Skills

| Skill | Trigger |
|---|---|
| `camel-matrix` | "generate camel matrix", "update camel compatibility" — runs `.claude/skills/camel-matrix/scripts/camel-springboot-matrix.sh`, outputs `target/camel-springboot-matrix.adoc` |
| `cc-best-practices` | Questions about effective Claude Code usage, context management, prompting |
| `project-references` | Look up conventions from sibling repos under `~/projects/referenzen/` |
| `skill-best-practices` | Creating, reviewing, or troubleshooting SKILL.md files |

## SKILL.md Frontmatter Rules

- `name`: kebab-case, must match the folder name
- `description`: under 1024 chars, must include both WHAT the skill does and WHEN to trigger it (specific user-facing phrases); no XML angle brackets
- No `README.md` inside skill folders — use `SKILL.md` or `references/` instead

## Adding a New Skill

1. Create folder in kebab-case under `.claude/skills/`
2. Write `SKILL.md` with YAML frontmatter (`name`, `description`)
3. Structure: `## Instructions` (numbered steps) → `## Examples` → optional `## Troubleshooting`
4. Keep `SKILL.md` under 5,000 words; move detail to `references/`
5. Update the skill table in **both** `CLAUDE.md` and `README.md`
6. Verify frontmatter triggers on ~90% of relevant queries, not on unrelated ones

## Formatting

A Stop hook (`bash .claude/hooks/format.sh`) runs Prettier on `CLAUDE.md` and `.claude/**/*.{md,json,yaml,yml}` plus `shfmt` on `.sh` files. Scope is intentionally narrow to avoid conflict with Spotless/Flexmark in Spring Boot projects consuming this package.

## CI

`.github/workflows/validate-skills.yml` runs on push/PR to main/master/development:
- Validates SKILL.md frontmatter via `skill-best-practices/scripts/validate-skills.sh`
- Validates CLAUDE.md via `cc-best-practices/scripts/validate-claude-md.sh`
- Publishes to GitHub Packages on push (npm registry)

## Installation (for end users)

Two methods — see `CLAUDE.md` or `README.md` for details:

```bash
# npm global (installs skills, statusline.sh, formatter hook)
npm install -g --ignore-scripts https://github.com/dboeckli/ai-agent-skills.git#master && \
  bash "$(npm root -g)/@dboeckli/ai-agent-skills/scripts/install-skills.sh"

# skills CLI (lighter, no statusline/hook)
npx skills add -g https://github.com/dboeckli/ai-agent-skills
```

## Config

- `.claude/settings.json` — statusLine + Stop hook for formatter
- `.gitignore` excludes `.claude/settings.local.json`, `target/camel-springboot-matrix.adoc`
- `.npmignore` excludes `.github/`, `CLAUDE.md`, `target/` from npm package
- All text files: LF line endings, UTF-8 encoding (enforced by `.gitattributes`)
