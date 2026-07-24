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

| Skill | Beschreibung |
|-------|-------------|
| `cc-best-practices` | Anleitung zur effektiven Nutzung von Claude Code: Kontextmanagement, Explore-Plan-Implement-Workflow, Prompting-Techniken und häufige Fehlermuster. |
| `skill-best-practices` | Leitfaden zum Erstellen, Strukturieren und Verbessern von SKILL.md Dateien: Frontmatter, Trigger-Beschreibungen, Testen und Troubleshooting. |
| `project-references` | Konventionen und Implementierungsmuster aus eigenen GitHub-Repositories nachschlagen, die lokal unter `~/projects/referenzen/` ausgecheckt sind. |

---

## Installation für Claude Code

Das Repository einmalig klonen und die gewünschten Skills per Symlink einbinden. Durch den Symlink werden Updates via `git pull` sofort wirksam, ohne erneutes Kopieren.

```bash
# Repository klonen (einmalig)
git clone https://github.com/[dein-user]/ai-agent-skills.git ~/projects/ai-agent-skills

# Einzelne Skills verlinken
ln -s ~/projects/ai-agent-skills/.claude/skills/cc-best-practices    ~/.claude/skills/cc-best-practices
ln -s ~/projects/ai-agent-skills/.claude/skills/skill-best-practices  ~/.claude/skills/skill-best-practices
ln -s ~/projects/ai-agent-skills/.claude/skills/project-references    ~/.claude/skills/project-references
```

Die verlinkten Skills stehen Claude Code anschliessend automatisch zur Verfügung und können per `/skill-name` aufgerufen werden.

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

---

## Beitragen

Du hast einen neuen Skill entwickelt, der hier nicht fehlen sollte? Wir freuen uns über Beiträge!

**So trägst du bei:**
1. Fork erstellen und einen neuen Branch anlegen (`feature/dein-skill-name`)
2. Deinen Skill als neues Verzeichnis mit SKILL.md hinzufügen
3. README.md aktualisieren (Tabelle der enthaltenen Skills ergänzen)
4. Pull Request mit kurzer Beschreibung des Skills einreichen

Wir prüfen jeden Beitrag und integrieren gut dokumentierte Skills so schnell wie möglich.