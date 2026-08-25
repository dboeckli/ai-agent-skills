# AI Agent Skills

Sammlung wiederverwendbarer Skills für AI Agenten im offenen SKILL.md Format.

---

## Über das SKILL.md Format

Das SKILL.md Format besteht aus Markdown-Dateien mit strukturierten Metadaten im sogenannten Frontmatter-Bereich (YAML zwischen `---`). Diese Dateien stellen einem AI Agenten Anweisungen, Kontext und verfügbare Werkzeuge für eine bestimmte Aufgabe bereit.

Das Format wurde ursprünglich von Anthropic für Claude entwickelt, ist jedoch bewusst offen und textbasiert gehalten. Jedes AI System, das strukturierte Textdateien einlesen und Befehle ausführen kann, kann dieses Format grundsätzlich nutzen.

---

## KI-Agnostische Nutzbarkeit

Die Skills in diesem Repository sind bewusst so gestaltet, dass sie **keine Claude-spezifischen Abhängigkeiten** enthalten. Stattdessen greifen sie ausschliesslich auf Standardwerkzeuge zurück:

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
| `cc-best-practices`    | Anleitung zur effektiven Nutzung von Claude Code: Kontextmanagement, Explore-Plan-Implement-Workflow, Prompting-Techniken und häufige Fehlermuster.         |
| `skill-best-practices` | Leitfaden zum Erstellen, Strukturieren und Verbessern von SKILL.md Dateien: Frontmatter, Trigger-Beschreibungen, Testen und Troubleshooting.                |
| `project-references`   | Konventionen und Implementierungsmuster aus eigenen GitHub-Repositories nachschlagen, die lokal unter `~/projects/referenzen/` ausgecheckt sind.            |
| `camel-matrix`         | Erzeugt eine AsciiDoc-Kompatibilitätsmatrix für Apache Camel Spring Boot, Spring Boot und Apache CXF. Unterstützt optional einen Versionsbereich (min max). |

---

## Installation für Claude Code

### Option 1: npm global — Empfohlen

Installiert Skills, `statusline.sh` und den Formatter-Hook automatisch. Skills werden als Symlinks (Linux/macOS/WSL) bzw. Directory-Junctions (Windows) eingebunden — Reinstall genügt für Updates.

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
tree ~/.claude/skills && ls ~/.claude/statusline.sh ~/.claude/settings.json
```

Erwartete Ausgabe:

```
~/.claude/skills
├── camel-matrix -> ~/.nvm/.../node_modules/@dboeckli/ai-agent-skills/.claude/skills/camel-matrix/
├── cc-best-practices -> ~/.nvm/.../node_modules/@dboeckli/ai-agent-skills/.claude/skills/cc-best-practices/
├── project-references -> ~/.nvm/.../node_modules/@dboeckli/ai-agent-skills/.claude/skills/project-references/
└── skill-best-practices -> ~/.nvm/.../node_modules/@dboeckli/ai-agent-skills/.claude/skills/skill-best-practices/

~/.claude/statusline.sh
~/.claude/settings.json
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

Skills werden als Directory-Junctions eingebunden (kein Admin-Recht nötig). Ausserdem wird in `%USERPROFILE%\.claude\settings.json` ein Stop-Hook eingetragen, der nach jeder Session Dateien formatiert.

Installation prüfen:

```powershell
Get-ChildItem "$HOME\.claude\skills"
Test-Path "$HOME\.claude\statusline.sh", "$HOME\.claude\settings.json"
```

Aktualisieren (gleicher Befehl):

```powershell
npm install -g --ignore-scripts https://github.com/dboeckli/ai-agent-skills.git#master
& "$(npm root -g)/@dboeckli/ai-agent-skills/scripts/install-skills.ps1"
```

### Option 2: skills CLI — Alternative

Nützlich um Skills aus mehreren Repos zu kombinieren. Installiert **nicht** `statusline.sh` und den Formatter-Hook.

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
sbx settings set kit.allowedSources --% "[\"docker.io/\",\"github.com/dboeckli/\"]"
```

Neue Sandbox starten:

```powershell
sbx run opencode --name ai-agent-skills --kit "git+https://github.com/dboeckli/opencode-sandbox-kit.git#dir=opencode-agent" "C:\development\projects\ai-agent-skills"
```

Kit auf eine bestehende Sandbox anwenden (startet die Sandbox neu, VM-Zustand bleibt erhalten):

```powershell
sbx kit add ai-agent-skills "git+https://github.com/dboeckli/opencode-sandbox-kit.git#dir=opencode-agent"
```

---

## Konfiguration

Nach der Installation die Datei `~/.claude/settings.json` (Linux/WSL) bzw. `%USERPROFILE%\.claude\settings.json` (Windows) manuell öffnen und folgende Einstellungen ergänzen oder anpassen.

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

> **Hinweis:** Der Stop-Hook für `format.sh` wird automatisch durch `install-skills.ps1` (Windows) bzw. `install-skills.sh` (Linux/WSL) eingetragen — dieser muss nicht manuell gesetzt werden.

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
