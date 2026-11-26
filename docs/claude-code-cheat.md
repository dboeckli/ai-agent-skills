# Claude Code — Cheat Sheet

## Skills (`/skillname`)

| Skill                       | Wann benutzen                                                               |
| --------------------------- | --------------------------------------------------------------------------- |
| `/dataviz`                  | Charts, Graphen, Dashboards designen (Farben, Layout, Accessibility)        |
| `/update-config`            | settings.json anpassen: hooks, permissions, env vars                        |
| `/keybindings-help`         | Keyboard Shortcuts anpassen (`~/.claude/keybindings.json`)                  |
| `/simplify`                 | Geänderten Code auf Vereinfachung, Effizienz, Altitude reviewen + fixen     |
| `/fewer-permission-prompts` | Häufige read-only Bash-Calls in Allowlist aufnehmen → weniger Prompts       |
| `/loop [interval] /cmd`     | Wiederkehrenden Task auf Intervall starten (z.B. `/loop 5m /babysit-prs`)   |
| `/claude-api`               | Referenz für Claude API / Anthropic SDK (Modelle, Preise, Streaming, Tools) |
| `/run`                      | App starten, im Browser testen, Änderung live verifizieren                  |
| `/init`                     | Neue CLAUDE.md mit Codebase-Dokumentation initialisieren                    |
| `/review`                   | GitHub Pull Request reviewen                                                |
| `/security-review`          | Security Review der aktuellen Branch-Änderungen                             |

## Nützliche Slash-Commands (built-in)

| Command        | Bedeutung                                                                             |
| -------------- | ------------------------------------------------------------------------------------- |
| `/help`        | Hilfe anzeigen                                                                        |
| `/clear`       | Konversation zurücksetzen                                                             |
| `/config`      | Einstellungen (Modell, Theme, …) interaktiv ändern                                    |
| `/fast`        | Fast Mode umschalten (Opus mit schnellerem Output)                                    |
| `/sandbox`     | Sandbox-Modus für laufende Session verwalten (Dateisystem- & Netzwerk-Beschränkungen) |
| `/memory`      | Persistente Erinnerungen anzeigen / verwalten                                         |
| `/workflows`   | Laufende Workflow-Agenten beobachten                                                  |
| `/code-review` | Working Diff reviewen (nicht GitHub PR)                                               |

## Agent-Typen (für komplexe Tasks)

| Agent               | Wofür                                                         |
| ------------------- | ------------------------------------------------------------- |
| `claude`            | Catch-all, voller Tool-Zugriff                                |
| `claude-code-guide` | Fragen zu Claude Code CLI, SDK, API, Hooks, MCP               |
| `Explore`           | Schnelle read-only Code-Suche (Dateien, Symbole, Referenzen)  |
| `general-purpose`   | Komplexe Recherche, Multi-Step Tasks                          |
| `Plan`              | Implementierungsplan entwerfen, Architektur-Tradeoffs abwägen |
| `statusline-setup`  | Claude Code Statusleiste konfigurieren                        |

## Context7 — Aktuelle Dokumentation abrufen

Context7 (`ctx7`) liefert Claude aktuelle Doku für Libraries, Frameworks und SDKs — direkt aus offiziellen Quellen, nicht aus dem Trainingsdaten-Stand.

**Claude nutzt es automatisch** via `/find-docs` Skill oder wenn in `~/.claude/rules/context7.md` konfiguriert (bei jeder Library-Frage).

### Ablauf (2 Schritte)

```bash
# 1. Library-ID ermitteln (gibt Liste möglicher Matches zurück)
npx ctx7@latest library "Spring Boot" "how to configure datasource"

# 2. Dokumentation abrufen (mit der ID aus Schritt 1)
npx ctx7@latest docs /spring-projects/spring-boot "how to configure datasource"
```

### Tipps

| Was                       | Wie                                                                                   |
| ------------------------- | ------------------------------------------------------------------------------------- |
| Korrekte Namen verwenden  | `"Next.js"` nicht `"nextjs"`, `"Three.js"` nicht `"threejs"`                          |
| Versions-spezifische Doku | ID-Format: `/org/project/v14.3.0` (aus `library`-Output)                              |
| Quota erschöpft           | `npx ctx7@latest login` oder `CONTEXT7_API_KEY` setzen                                |
| Mehrere Themen            | Separate `docs`-Aufrufe pro Konzept — kombinierte Queries liefern flachere Ergebnisse |

---

## Prompt-Tricks

| Trick                               | Effekt                                                                 |
| ----------------------------------- | ---------------------------------------------------------------------- |
| `! <command>`                       | Shell-Befehl direkt im Prompt ausführen (Output landet im Chat)        |
| `+500k`                             | Token-Budget für Workflow setzen                                       |
| `ultracode`                         | Multi-Agent Workflow session-weit aktivieren (internes Opt-in-Keyword) |
| `"use a workflow"`                  | Workflow-Tool für diesen Task aktivieren (internes Opt-in-Keyword)     |
| `"run a workflow"`                  | Wie oben — Claude spawnt dann einen deterministischen JS-Orchestrator  |
| `"fan out agents"`                  | Wie oben — explizite Formulierung für parallele Agent-Ausführung       |
| `"orchestrate this with subagents"` | Wie oben                                                               |

### Wie funktioniert das Workflow-Tool technisch?

Das Workflow-Tool ist ein deterministischer JavaScript-Orchestrator. Was passiert wenn es aufgerufen wird:

1. **Claude schreibt ein Script** — plain JavaScript mit `agent()`, `parallel()`, `pipeline()` Aufrufen
2. **Das Script wird im Hintergrund gestartet** — Claude bekommt sofort eine `runId` zurück
3. **Subagents werden gespawnt** — bis zu 16 gleichzeitig, bis 1000 insgesamt pro Workflow
4. **Ergebnis kommt als Notification** — als User-Message in einem späteren Turn

> **Hinweis:** `"use a workflow"` und `ultracode` sind **keine öffentlichen Slash-Commands**,
> sondern interne Verhaltensregeln aus Claudes Tool-Instruktionen. Claude darf das `Workflow`-Tool
> nur aufrufen, wenn eine dieser Phrasen im Prompt steht (Kostenschutz: Workflows können
> Dutzende Agents spawnen). Ohne explizites Opt-in wird kein Workflow gestartet.

> **Sandbox dauerhaft aktivieren** — `/sandbox` gilt nur für die Session. Für automatisches Aktivieren beim Start in `~/.claude/settings.json` (global) oder `.claude/settings.local.json` (projekt-lokal, nicht im Git) eintragen:
>
> ```json
> { "sandbox": { "enabled": true, "autoAllowBashIfSandboxed": false } }
> ```

## Sandbox vs. Permissions — wichtiger Unterschied

Die Sandbox und das Permissions-System sind **zwei unabhängige Schutzmechanismen**:

| Mechanismus     | Kontrolliert                                       | Gilt für                           |
| --------------- | -------------------------------------------------- | ---------------------------------- |
| **Sandbox**     | Dateisystem- & Netzwerkzugriff von Shell-Prozessen | `Bash`-Tool                        |
| **Permissions** | Welche Tools Claude aufrufen darf                  | `Edit`, `Write`, `Read`, `Bash`, … |

**Die Sandbox schützt nicht vor Claudes eigenen File-Tools.** `Edit` und `Write` laufen direkt im Claude Code Prozess — außerhalb der Sandbox. Sie werden nur durch das Permissions-System (Allow/Deny-Listen) und das manuelle Bestätigungs-Gate kontrolliert.

Beispiel: `Bash(cat ~/.claude/settings.json)` kann die Sandbox blockieren — `Edit(~/.claude/settings.json)` nicht.

Um auch direkte Datei-Edits durch Claude zu sperren, braucht es einen expliziten deny-Eintrag in den Permissions:

```json
{ "permissions": { "deny": ["Edit(/home/user/.claude/settings.json)"] } }
```

## Speicherorte

| Pfad                                   | Inhalt                                    |
| -------------------------------------- | ----------------------------------------- |
| `~/.claude/CLAUDE.md`                  | Globale Instruktionen für alle Projekte   |
| `~/.claude/settings.json`              | Globale Einstellungen, Hooks, Permissions |
| `~/.claude/projects/<project>/memory/` | Persistente Erinnerungen pro Projekt      |
| `~/.claude/skills/`                    | Eigene Skills                             |
| `<project>/CLAUDE.md`                  | Projektspezifische Instruktionen          |
| `<project>/.claude/settings.json`      | Projektspezifische Einstellungen          |

## Memory-Typen

| Typ         | Wann                                                         |
| ----------- | ------------------------------------------------------------ |
| `user`      | Rolle, Ziele, Wissensstand, Präferenzen des Nutzers          |
| `feedback`  | Korrekturen & bestätigte Ansätze (mit Why + How to apply)    |
| `project`   | Laufende Ziele, Entscheidungen, Deadlines                    |
| `reference` | Zeiger auf externe Systeme (Linear, Grafana, Slack-Channels) |
