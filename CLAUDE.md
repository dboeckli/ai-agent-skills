# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

A collection of reusable AI agent skills in the open SKILL.md format. Skills are designed to be AI-agnostic — they rely only on standard tools (`git`, `gh`, shell commands) and contain no Claude-specific dependencies.

## Skill Structure

Each skill lives in `.claude/skills/<skill-name>/` and follows this layout:

```
<skill-name>/          # kebab-case folder name, must match SKILL.md `name:` field
  SKILL.md             # required; YAML frontmatter + Markdown instructions
  references/          # optional; supporting docs loaded on demand
  scripts/             # optional; executable Bash/Python helpers
  assets/              # optional; templates, fonts, icons
```

### SKILL.md Frontmatter Rules

- `name`: kebab-case, no spaces or capitals, must match the folder name
- `description`: under 1024 characters, must include both WHAT the skill does and WHEN to trigger it (specific user-facing phrases); no XML angle brackets
- No `README.md` inside skill folders — use `SKILL.md` or `references/` instead

### Installing Skills for Claude Code

**Via npm (recommended):**
Installs skills, `statusline.sh`, and the formatter Stop hook. Enable git URL installs once:

```bash
npm config set allow-git all
```

Install:

```bash
npm install -g --ignore-scripts https://github.com/dboeckli/ai-agent-skills.git#master && \
  bash "$(npm root -g)/@dboeckli/ai-agent-skills/scripts/install-skills.sh"
```

**Via skills CLI — alternative:**
Does not install `statusline.sh` or the formatter hook.

```bash
npx skills add -g https://github.com/dboeckli/ai-agent-skills
```

> **Installation method:** Choose **Copy to all agents** when prompted.
>
> **WSL note:** Press **Space** to select, then **Enter** to confirm.
>
> **Statusline:** Run once after install:
>
> ```bash
> curl -fsSL https://raw.githubusercontent.com/dboeckli/ai-agent-skills/master/scripts/statusline.sh \
>   -o ~/.claude/statusline.sh && chmod +x ~/.claude/statusline.sh
> ```

## Included Skills

| Skill                  | Trigger                                                                               |
| ---------------------- | ------------------------------------------------------------------------------------- |
| `cc-best-practices`    | Questions about effective Claude Code usage, context management, prompting, plan mode |
| `skill-best-practices` | Creating, reviewing, or troubleshooting SKILL.md files                                |
| `project-references`   | Looking up conventions from sibling GitHub repos under `~/projects/referenzen/`       |
| `camel-matrix`         | Generate or update the Apache Camel Spring Boot compatibility matrix                  |

## Conventions When Adding a New Skill

1. Create the folder in kebab-case under `.claude/skills/`
2. Write YAML frontmatter with `name` and `description`; keep `description` under 1024 chars with clear trigger phrases
3. Structure the body as: `## Instructions` (numbered steps) → `## Examples` → optional `## Troubleshooting`
4. Keep `SKILL.md` under 5,000 words; move detailed docs to `references/`
5. Update the skill table in `README.md`
6. Test that the skill triggers on ~90% of relevant queries and not on unrelated ones
