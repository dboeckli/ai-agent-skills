# AI Agent Skills

Sammlung wiederverwendbarer Skills für AI Agenten im offenen SKILL.md Format.

---

## Über das SKILL.md Format

Das SKILL.md Format besteht aus Markdown-Dateien mit strukturierten Metadaten im sogenannten Frontmatter-Bereich (YAML zwischen `---`). Diese Dateien stellen einem AI Agenten Anweisungen, Kontext und verfügbare Werkzeuge für eine bestimmte Aufgabe bereit.

Das Format wurde ursprünglich von Anthropic für Claude entwickelt, ist jedoch bewusst offen und textbasiert gehalten. Jedes AI System, das strukturierte Textdateien einlesen und Befehle ausführen kann, kann dieses Format grundsätzlich nutzen.

---

## KI-Agnostische Nutzbarkeit

Die Skills in diesem Repository sind bewusst so gestaltet, dass sie **keine Claude-spezifischen Abhängigkeiten** enthalten — ausser bei Skills, die explizit als Claude-Code-spezifisch gekennzeichnet sind (z. B. `cc-best-practices`). Stattdessen greifen sie ausschliesslich auf Standardwerkzeuge zurück:

- **git** – Versionskontrolle und Repository-Operationen
- **gh** – GitHub CLI für Issues, PRs und Repository-Management
- **Shell-Befehle** – Universelle Unix/Linux-Kommandos

Jedes AI System, das:

- Markdown-basierte Kontextdateien einlesen kann
- Shell-Befehle ausführen und deren Ausgabe verarbeiten kann
- Dateien erstellen, lesen und modifizieren kann

kann diese Skills grundsätzlich nutzen. Dazu gehören unter anderem:

- Claude (Anthropic)
- GPT-basierte Agenten mit Tool-Nutzung (OpenAI)
- Gemini (Google)
- Open-Source-Agentenframeworks (z.B. LangChain, AutoGPT, MetaGPT)

Die SKILL.md Dateien können direkt als Kontextdatei in einen Chat hochgeladen, als Systemprompt-Ergänzung eingefügt oder per Dateiverweis in eigene Agenten-Frameworks eingebunden werden.

---

## Enthaltene Skills

| Skill                  | Beschreibung                                                                                                                                                |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `cc-best-practices`    | Claude Code-spezifisch: Anleitung zur effektiven Nutzung von Claude Code: Kontextmanagement, Explore-Plan-Implement-Workflow, Prompting-Techniken und häufige Fehlermuster. |
| `skill-best-practices` | Leitfaden zum Erstellen, Strukturieren und Verbessern von SKILL.md Dateien: Frontmatter, Trigger-Beschreibungen, Testen und Troubleshooting.                |
| `project-references`   | Konventionen und Implementierungsmuster aus eigenen GitHub-Repositories nachschlagen, die lokal unter `~/projects/referenzen/` ausgecheckt sind; ausserdem eine Übersicht der GitHub-Actions-Trigger (push, PR, schedule/cron) über alle Repos als Markdown-Report erzeugen. |
| `cron-schedule-planner` | Erstellt eine Übersicht der GitHub-Actions-Cron-Zeitpläne über mehrere Repos (via `gh` oder lokale Checkouts), klassifiziert die Job-Intensität und schlägt eine Entzerrung in wenig belegte Zeitfenster vor (Markdown-Report mit Stunden-Histogramm). |
| `camel-matrix`         | Erzeugt eine Markdown-Kompatibilitätsmatrix für Apache Camel Spring Boot, Spring Boot und Apache CXF. Unterstützt optional einen Versionsbereich (min max). |

---

## Installation

### Option 1: npm global — Empfohlen

Installiert die Skills nach `~/.agents/skills` (generisch für alle Agenten). Skills werden als Symlinks (Linux/macOS/WSL) bzw. Directory-Junctions (Windows) eingebunden — Reinstall genügt für Updates. Die Claude-Code-Statusline wird nur zusätzlich kopiert, wenn `~/.claude` bereits existiert.

Für Claude Code stehen zusätzlich das mitgelieferte Plugin (`.claude-plugin/`) oder `npx skills add` zur Verfügung.

Einmalig npm für Git-URL-Installs freischalten:

```bash
npm config set allow-git all
```

#### Linux / macOS / WSL

Installieren und Setup-Script ausführen:

```bash
npm install -g --ignore-scripts https://github.com/dboeckli/ai-agent-skills.git#master && \
  bash "$(npm root -g)/@dboeckli/ai-agent-skills/scripts/install-skills.sh"
```

Installation prüfen:

```bash
tree ~/.agents/skills
```

Erwartete Ausgabe:

```
~/.agents/skills
├── camel-matrix -> ~/.nvm/.../node_modules/@dboeckli/ai-agent-skills/.agents/skills/camel-matrix/
├── cc-best-practices -> ~/.nvm/.../node_modules/@dboeckli/ai-agent-skills/.agents/skills/cc-best-practices/
├── cron-schedule-planner -> ~/.nvm/.../node_modules/@dboeckli/ai-agent-skills/.agents/skills/cron-schedule-planner/
├── project-references -> ~/.nvm/.../node_modules/@dboeckli/ai-agent-skills/.agents/skills/project-references/
└── skill-best-practices -> ~/.nvm/.../node_modules/@dboeckli/ai-agent-skills/.agents/skills/skill-best-practices/

~/.claude/statusline.sh   # optional, nur wenn ~/.claude existiert
```

Aktualisieren (gleicher Befehl):

```bash
npm install -g --ignore-scripts https://github.com/dboeckli/ai-agent-skills.git#master && \
  bash "$(npm root -g)/@dboeckli/ai-agent-skills/scripts/install-skills.sh"
```

#### Windows (PowerShell)

Installieren und Setup-Script ausführen:

```powershell
npm install -g --ignore-scripts https://github.com/dboeckli/ai-agent-skills.git#master
& "$(npm root -g)/@dboeckli/ai-agent-skills/scripts/install-skills.ps1"
```

Skills werden als Directory-Junctions nach `%USERPROFILE%\.agents\skills` eingebunden (kein Admin-Recht nötig). Die Claude-Code-Statusline wird nur kopiert, wenn `%USERPROFILE%\.claude` bereits existiert.

Installation prüfen:

```powershell
Get-ChildItem "$HOME\.agents\skills"
Test-Path "$HOME\.claude\statusline.sh"   # optional, nur bei vorhandenem ~/.claude
```

Aktualisieren (gleicher Befehl):

```powershell
npm install -g --ignore-scripts https://github.com/dboeckli/ai-agent-skills.git#master
& "$(npm root -g)/@dboeckli/ai-agent-skills/scripts/install-skills.ps1"
```

### Option 2: skills CLI — Alternative

Nützlich um Skills aus mehreren Repos zu kombinieren. Installiert keine Claude-Code-Statusline.

```bash
# Global installieren
npx skills add -g https://github.com/dboeckli/ai-agent-skills

# Aktualisieren
npx skills update ai-agent-skills
```

> **Installationsmethode:** Bei der Abfrage _Installation method_ **Copy to all agents** wählen.
>
> **WSL-Hinweis:** **Space** zum Auswählen, dann **Enter** zum Bestätigen.
>
> **Statusline manuell installieren:**
>
> ```bash
> curl -fsSL https://raw.githubusercontent.com/dboeckli/ai-agent-skills/master/scripts/statusline.sh \
>   -o ~/.claude/statusline.sh && chmod +x ~/.claude/statusline.sh
> ```

---

## Installation für Opencode

Skills installieren:

```bash
npx skills add -g https://github.com/dboeckli/ai-agent-skills.git
```

Context7 für aktuelle API-Dokumentation einrichten:

```bash
npx ctx7 setup --opencode
```

---

## Sandbox (lokale Dev-Umgebung)

Die Sandbox wird durch das opencode-sandbox-kit provisioniert und läuft als Docker-Container. Sie mounted dieses Repo, startet opencode und verbindet den IntelliJ-MCP-Server.

### Sandbox starten (opencode-sandbox-kit)

Kit-Quelle freischalten (GitHub ohne Klonen):

```powershell
sbx settings set kit.allowedSources --% "[\"docker.io/\",\"codeberg.org/dboeckli/\"]"
```

Neue Sandbox starten (OpenCode):

```powershell
sbx run opencode `
    --kit "git+https://codeberg.org/dboeckli/opencode-sandbox-kit.git#dir=opencode-agent" `
    --template docker.cloudsmith.io/dboeckli/sbx/sbx-opencode-tooling:latest `
    --skills=off `
    --static-mcp idea `
    .
```

Mit Kubernetes-Support (optional):

```powershell
sbx run opencode `
    --kit "git+https://codeberg.org/dboeckli/opencode-sandbox-kit.git#dir=opencode-agent" `
    --template docker.cloudsmith.io/dboeckli/sbx/sbx-opencode-tooling:latest `
    --skills=off `
    --static-mcp idea `
    . `
    "$env:USERPROFILE\.kube:ro"
```

Claude Code (Home) und Mammouth Code:

```powershell
sbx run claude `
    --kit "git+https://codeberg.org/dboeckli/opencode-sandbox-kit.git#dir=opencode-agent" `
    --template docker.cloudsmith.io/dboeckli/sbx/sbx-claude-tooling:latest `
    --skills=off `
    --static-mcp idea `
    .
```

```powershell
sbx run "git+https://codeberg.org/dboeckli/opencode-sandbox-kit.git#dir=mammouth-agent" `
    --kit-arg imageTag=latest `
    --skills=off `
    --static-mcp idea `
    .
```

Apply the kit to an existing sandbox (restarts the sandbox, VM state is kept):

```powershell
sbx kit add opencode-ai-agent-skills "git+https://codeberg.org/dboeckli/opencode-sandbox-kit.git#dir=opencode-agent"
```

Voraussetzungen: GitHub-Secret registrieren (`sbx secret set github`); Details in der `INSTALL.md` des opencode-sandbox-kit.

---

## Konfiguration (Claude Code)

Dieser Abschnitt gilt nur für Claude Code. Nach der Installation die Datei `~/.claude/settings.json` (Linux/WSL) bzw. `%USERPROFILE%\.claude\settings.json` (Windows) manuell öffnen und folgende Einstellungen ergänzen oder anpassen.

### Linux / WSL (`~/.claude/settings.json`)

```json
{
  "model": "claude-sonnet-4-6",
  "theme": "light",
  "permissions": {
    "allow": ["Bash(npx ctx7@latest *)", "Bash(ctx7 *)"]
  },
  "skillOverrides": {
    "skill-creator": "off"
  },
  "statusLine": {
    "type": "command",
    "command": "/home/<username>/.claude/statusline.sh"
  },
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": false
  }
}
```

`<username>` durch den eigenen Linux-Benutzernamen ersetzen (oder `~` verwenden, falls Claude Code das auflöst).

### Windows (`%USERPROFILE%\.claude\settings.json`)

```json
{
  "model": "claude-sonnet-4-6",
  "theme": "light",
  "permissions": {
    "allow": ["Bash(npx ctx7@latest *)", "Bash(ctx7 *)"]
  },
  "skillOverrides": {
    "skill-creator": "off"
  },
  "statusLine": {
    "type": "command",
    "command": "bash \"C:/Users/<username>/.claude/statusline.sh\""
  },
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": false
  }
}
```

`<username>` durch den Windows-Benutzernamen ersetzen. Die `statusLine` ruft `bash` auf (Git Bash oder WSL), damit das `.sh`-Script ausgeführt werden kann.

> **Hinweis:** Es wird kein Formatter-Hook mehr installiert. `scripts/format.sh` kann bei Bedarf manuell ausgeführt werden.

---

## Nutzung mit anderen AI Systemen

### Als Kontextdatei hochladen

Lade die gewünschte SKILL.md Datei direkt in den Chat hoch. Das AI System kann den Inhalt als Kontext für die Aufgabenbearbeitung nutzen.

### In Systemprompt einfügen

Kopiere den Inhalt einer SKILL.md Datei (oder ausgewählte Abschnitte) in den Systemprompt deines AI Systems, um die definierten Anweisungen und Werkzeuge zu aktivieren.

### Einbindung in Custom-GPTs oder Agenten-Frameworks

Verweise in deiner Konfiguration auf die SKILL.md Datei(en) aus diesem Repository. Die strukturierten Metadaten und Anweisungen können von den meisten modernen Agenten-Frameworks direkt interpretiert werden.

---

## Lizenz

Dieses Repository ist unter der **MIT-Lizenz** veröffentlicht.

Du darfst die Skills in diesem Repository nutzen, modifizieren und weiterverwenden – sowohl für private als auch für kommerzielle Projekte. Eine Namensnennung ist nicht erforderlich, wird aber geschätzt.

Die Nutzung, Modifikation und Weiterverwendung durch Dritte ist **unabhängig vom eingesetzten AI System** ausdrücklich erlaubt. Die Skills stehen allen zur Verfügung, die ein AI System betreiben, das das SKILL.md Format verarbeiten kann.
