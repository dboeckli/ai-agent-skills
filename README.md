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

### Option 1: skills CLI — Empfohlen

Die `skills` CLI kopiert Skills direkt in die Agenten-Verzeichnisse und funktioniert mit Claude Code, Amp, Cline und weiteren Agenten. Nützlich wenn man Skills aus mehreren Repos kombinieren möchte.

```bash
# Global installieren
npx skills add -g https://github.com/dboeckli/ai-agent-skills

# Nur im aktuellen Projekt installieren
npx skills add https://github.com/dboeckli/ai-agent-skills

# Aktualisieren
npx skills update ai-agent-skills
```

> **Installationsmethode:** Bei der Abfrage _Installation method_ empfiehlt sich **Copy to all agents** — so sind die Skills unabhängig von Pfaden und funktionieren in allen Agenten (Claude Code, Amp, Cline usw.).
>
> **WSL-Hinweis:** In der interaktiven Skill-Auswahl **Space** drücken zum Auswählen/Abwählen eines Skills, dann **Enter** zum Bestätigen. Enter alleine wählt nichts aus.
>
> **Statusline:** Die `statusline.sh` wird von der `skills` CLI nicht automatisch installiert. Nach der Skill-Installation einmalig ausführen:
>
> ```bash
> curl -fsSL https://raw.githubusercontent.com/dboeckli/ai-agent-skills/master/scripts/statusline.sh \
>   -o ~/.claude/statusline.sh && chmod +x ~/.claude/statusline.sh
> ```

### Option 2: npm global

Installiert Skills und `statusline.sh` via `postinstall`-Script automatisch nach `~/.claude/`. Skills werden als Symlinks eingebunden — Updates via `npm update` werden sofort wirksam.

npm blockiert Git-URL-Installs standardmässig. Einmalig freischalten:

```bash
npm config set allow-git all
```

Installieren:

```bash
npm install -g https://github.com/dboeckli/ai-agent-skills.git#master
```

Aktualisieren:

```bash
npm update -g @dboeckli/ai-agent-skills
```

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
