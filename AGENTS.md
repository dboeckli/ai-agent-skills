# AGENTS.md — AI Agent Skills Repository

This is a **SKILL.md package** — a collection of reusable AI-agent skills, not an application. Skills follow the open SKILL.md format and are agent-agnostic; a few are intentionally Claude Code-specific. No application build exists, but skills and docs are **validated and formatted** — see below.

## Repository Purpose

A collection of reusable AI agent skills in the open SKILL.md format. Skills rely only on standard tools (`git`, `gh`, shell commands) and contain no Claude-specific dependencies, except where a skill is explicitly marked Claude-specific (for example `cc-best-practices`). The skills can be consumed by Claude Code, opencode, and any other agent that can read structured Markdown and run shell commands.

## Build & verify commands

- Validate SKILL.md frontmatter: `bash .agents/skills/skill-best-practices/scripts/validate-skills.sh`
- Validate AGENTS.md (required sections + skill table sync): `bash .agents/skills/skill-best-practices/scripts/validate-agents-md.sh`
- Format (Prettier + shfmt, manual): `bash scripts/format.sh`
- CI: `.github/workflows/validate-skills.yml` runs the validators on push/PR and publishes the npm package to GitHub Packages.

After changing a skill or doc, always verify: run the relevant command above and report its output (evidence, not just "done").

## Sandbox (opencode-sandbox-kit)

Run this repo inside an opencode-sandbox-kit sandbox — canonical, multiline, **no `--name`**,
workspace mount `.`, `--skills=off`, `--static-mcp idea`, pinned template:

```powershell
sbx run opencode `
    --kit "git+https://codeberg.org/dboeckli/opencode-sandbox-kit.git#dir=opencode-agent" `
    --template docker.cloudsmith.io/dboeckli/sbx/sbx-opencode-tooling:latest `
    --skills=off `
    --static-mcp idea `
    .
```

Claude Code / Mammouth Code variants and the `sbx kit add` command are documented in `README.md`.

## Sandbox quirk (background)

The sandbox mounts the repo via filesystem passthrough, which blocks symlinks — `npm` installs would fail with `EPERM` unless bin links are skipped. The sandbox kit sets `npm_config_bin_links=false` globally, so no manual export is needed here.

## Skill Structure

Each skill lives in `.agents/skills/<skill-name>/` and follows this layout:

```
.agents/skills/<skill-name>/
  SKILL.md          # required: YAML frontmatter + Markdown instructions
  references/       # optional: supporting docs loaded on demand
  scripts/          # optional: executable Bash/Python helpers
  assets/           # optional: templates, fonts, icons
```

The `.claude-plugin/` directory packages the same skills for Claude Code and contains no skill logic itself.

## Included Skills

| Skill                   | Trigger                                                                                                                                                                                    |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `camel-matrix`          | "generate camel matrix", "update camel compatibility" — runs `.agents/skills/camel-matrix/scripts/camel-springboot-matrix.sh`, outputs `target/camel-springboot-matrix.md`                 |
| `cc-best-practices`     | Claude Code-specific: effective Claude Code usage, context management, prompting                                                                                                           |
| `cron-schedule-planner` | "when do my cron actions run", "do my scheduled builds collide" — runs `.agents/skills/cron-schedule-planner/scripts/cron-schedule-planner.sh`, outputs `target/cron-schedule-overview.md` |
| `project-references`    | Look up conventions from sibling repos under `~/projects/referenzen/`                                                                                                                      |
| `skill-best-practices`  | Creating, reviewing, or troubleshooting SKILL.md files                                                                                                                                     |

## SKILL.md Frontmatter Rules

- `name`: kebab-case, must match the folder name
- `description`: under 1024 chars, must include both WHAT the skill does and WHEN to trigger it (specific user-facing phrases); no XML angle brackets
- No `README.md` inside skill folders — use `SKILL.md` or `references/` instead

## Conventions When Adding a New Skill

1. Create the folder in kebab-case under `.agents/skills/`
2. Write `SKILL.md` with YAML frontmatter (`name`, `description`)
3. Structure: `## Instructions` (numbered steps) → `## Examples` → optional `## Troubleshooting`
4. Keep `SKILL.md` under 5,000 words; move detail to `references/`
5. Update the skill table in **both** `AGENTS.md` and `README.md`
6. Verify frontmatter triggers on ~90% of relevant queries, not on unrelated ones

## Formatting

`bash scripts/format.sh` runs Prettier on `AGENTS.md`, `.agents/**/*.{md,json,yaml,yml}` and `docs/**/*.md`, plus `shfmt` on shell scripts. No hook is used. Scope is intentionally narrow to avoid conflict with Spotless/Flexmark in Spring Boot projects consuming this package.

## CI

`.github/workflows/validate-skills.yml` runs on push/PR to main/master/development:

- Validates SKILL.md frontmatter via `.agents/skills/skill-best-practices/scripts/validate-skills.sh`
- Validates AGENTS.md via `.agents/skills/skill-best-practices/scripts/validate-agents-md.sh`
- Publishes to GitHub Packages on push (npm registry)

## Installation (for end users)

Two methods — see `README.md` for details:

```bash
# npm global (installs skills into ~/.agents/skills; statusline optional for Claude Code)
npm install -g --ignore-scripts https://github.com/dboeckli/ai-agent-skills.git#master && \
  bash "$(npm root -g)/@dboeckli/ai-agent-skills/scripts/install-skills.sh"

# skills CLI (no statusline)
npx skills add -g https://github.com/dboeckli/ai-agent-skills
```

## Config

- `.claude/settings.json` — Claude Code statusLine only (no hooks)
- `.claude-plugin/` — Claude Code plugin; its skills path points to `.agents/skills/`
- `.gitignore` excludes `.claude/settings.local.json`, `.agents/settings.local.json`, `/target/`
- `.npmignore` excludes `.github/`, `AGENTS.md`, `target/` from npm package
- All text files: LF line endings, UTF-8 encoding (enforced by `.gitattributes`)
