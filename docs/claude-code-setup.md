# Claude Code Setup unter WSL

Diese Anleitung beschreibt die Claude-Code-spezifische Einrichtung unter WSL. Die generische Basisumgebung (WSL, Java, Spring Boot, GitHub CLI) wird in [`wsl-dev-setup.md`](./wsl-dev-setup.md) beschrieben und vorausgesetzt.

---

## Claude Code installieren

Claude Code ist ein Kommandozeilen-Werkzeug von Anthropic für die Interaktion mit Claude direkt im Terminal.

### Installationsskript ausführen

Das offizielle Installationsskript lädt Claude Code herunter und richtet es im System ein.

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

### socat installieren

Claude Code benötigt socat als Abhängigkeit für die Kommunikation zwischen dem Terminal und dem Claude-Prozess.

```bash
sudo apt install socat
```

### Context7 CLI installieren

Context7 bietet Zugriff auf aktuelle Dokumentationen für Bibliotheken und Frameworks wie Spring Boot und Java. Die CLI wird global über npm installiert, um sie projektübergreifend verfügbar zu machen. Weitere Informationen sind unter https://context7.com verfügbar.

```bash
npm install -g ctx7
```

### Wie Context7 in Claude Code greift

Context7 ist kein Skill, sondern eine **globale Regel** (`~/.claude/rules/context7.md`), die in jeder Session automatisch aktiv ist. Sie weist Claude an, vor Antworten zu Library-Fragen das `ctx7`-CLI zu nutzen, um aktuelle Dokumentation zu holen — statt auf potenziell veraltetes Trainingswissen zu vertrauen.

Betroffen sind z.B. Fragen zu Spring Boot, Apache Camel, Maven, Docker, Kubernetes, aber auch Claude-eigene Tooling-Themen wie Hooks, Skills oder die Anthropic API.

Es gibt keinen `/context7`-Befehl — die Regel greift automatisch, sobald nach einer Library, einem Framework oder einem SDK gefragt wird.

---

## Claude Code Konfiguration

Die globale Konfiguration von Claude Code wird in `~/.claude/settings.json` gespeichert. Die Datei kann direkt bearbeitet werden.

### Empfohlene Grundkonfiguration (WSL / Linux)

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

`<username>` durch den eigenen Linux-Benutzernamen ersetzen.

### Empfohlene Grundkonfiguration (Windows — `%USERPROFILE%\.claude\settings.json`)

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

> **Formatierung:** Dieses Repository formatiert manuell mit `bash scripts/format.sh` (siehe `AGENTS.md`).

---

## Sandboxing in Claude Code

Claude Code verfügt über ein integriertes Sandbox-System, das den Zugriff von Shell-Befehlen auf das Dateisystem und das Netzwerk einschränkt. **Sandboxing ist standardmässig aktiviert** und schützt das System vor unbeabsichtigten oder schädlichen Operationen.

### Was das Sandbox-System kontrolliert

- **Dateisystem**: Lese- und Schreibzugriffe sind auf bestimmte Verzeichnisse beschränkt. Schreibzugriff ist z.B. standardmässig auf das aktuelle Projektverzeichnis, `/tmp` und ausgewählte Konfigurationspfade begrenzt.
- **Netzwerk**: Netzwerkzugriffe sind auf explizit erlaubte Hosts eingeschränkt. Nicht auf der Allowlist stehende Hosts werden blockiert.

### Sandbox verwalten

Der aktuelle Sandbox-Status kann jederzeit mit dem folgenden Slash-Befehl in Claude Code eingesehen und angepasst werden:

```
/sandbox
```

Über diesen Befehl lassen sich Verzeichnisse oder Hosts zur Allowlist hinzufügen, wenn ein bestimmter Befehl legitim blockiert wird. Claude Code weist bei sandbox-bedingten Fehlern ausdrücklich darauf hin, sodass erkennbar ist, wenn eine Einschränkung die Ursache ist.

### Sandboxing automatisch beim Start aktivieren

Damit Sandboxing bei jedem Projektstart automatisch aktiv ist, wird es in der `settings.json` konfiguriert — nicht über `/sandbox` (das gilt nur für die laufende Session).

**Global für alle Projekte** (`~/.claude/settings.json`):

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": false
  }
}
```

**Nur für ein bestimmtes Projekt, nicht ins Git** (`.claude/settings.local.json`):

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": false
  }
}
```

`autoAllowBashIfSandboxed: false` sorgt dafür, dass Bash-Befehle auch im Sandbox-Modus weiterhin eine Bestätigung erfordern. Mit `true` würden alle Bash-Befehle automatisch erlaubt — was den Schutz teilweise aufhebt.

### Sandboxing deaktivieren

Das Sandboxing kann für den gesamten Claude Code Prozess deaktiviert werden. Dies wird jedoch nur empfohlen, wenn es explizit benötigt wird, da es den Schutz des Systems aufhebt.

---

## Projektverzeichnis für Claude Code freigeben

Claude Code benötigt Zugriff auf das Projektverzeichnis, um Code lesen und bearbeiten zu können. Bei der ersten Interaktion in einem Verzeichnis wird entsprechende Berechtigung erteilt. Ein typischer Pfad für ein Spring-Boot-Projekt unter Windows könnte wie folgt aussehen:

```
/mnt/c/development/projects/spring-6-rest-mvc/
```

---

## IntelliJ Claude Code Plugin einrichten

Das Claude Code Plugin für IntelliJ ermöglicht die Nutzung von Claude Code direkt aus der IDE heraus, ohne das Terminal manuell öffnen zu müssen.

### Plugin konfigurieren

Nach der Installation des Plugins in IntelliJ die folgenden Einstellungen setzen:

| Einstellung          | Wert                                           |
| -------------------- | ---------------------------------------------- |
| `claude-command`     | `wsl.exe -d Ubuntu-26.04 -- bash -lc 'claude'` |
| `wsl localhost path` | `\\wsl.localhost\Ubuntu-26.04`                 |

Der `claude-command` startet Claude Code direkt in der WSL-Distribution `Ubuntu-26.04`. Der `wsl localhost path` gibt IntelliJ den UNC-Pfad zur Distribution an, damit Dateipfade korrekt zwischen Windows und WSL übersetzt werden.

### MCP Server aktivieren

Im Plugin-Panel den **MCP Server aktivieren** (Checkbox „Enable MCP Server"). Damit wird IntelliJ selbst zum MCP-Server, und Claude Code verbindet sich als MCP-Client dazu.

**Warum das wichtig ist:** Ohne MCP-Server sieht Claude Code nur Dateiinhalte. Mit aktiviertem MCP-Server erhält Claude Code direkten Zugriff auf die IDE-Intelligenz:

- Offene Dateien und Editor-Zustand
- Projektstruktur und Symbole (Klassen, Methoden, Interfaces)
- Run- und Debug-Konfigurationen — Claude kann Builds direkt triggern
- IntelliJ-Aktionen wie Refactoring, „Find Usages" oder „Go to Definition"

Damit Claude Code im WSL-Terminal den IntelliJ-MCP-Server erreicht, muss WSL2 im **mirrored networking mode** betrieben werden (siehe [`wsl-dev-setup.md`](./wsl-dev-setup.md#wsl-mirrored-networking-für-intellij-mcp-server)). Der Server ist dann unter `http://127.0.0.1:64342/stream` erreichbar.

> **Brave Mode** (Run shell commands without confirmation) bleibt deaktiviert — Claude Code übernimmt die Ausführung von Shell-Befehlen selbst und bringt sein eigenes Berechtigungssystem mit.

---

## IntelliJ MCP Server in Claude Code registrieren (HTTP)

Dieser Abschnitt beschreibt, wie IntelliJ als MCP Server in Claude Code registriert wird — damit Claude Code aus dem Terminal heraus auf die IDE-Intelligenz zugreifen kann (Projektstruktur, Symbole, Run-Konfigurationen, Refactoring).

### Exakte IntelliJ-Konfiguration kopieren

In IntelliJ öffnen:

**Settings → Tools → MCP Server**

Dort den Server aktivieren und unter «Manual Client Configuration» auf **Copy HTTP Stream Config** klicken.

Die Standard-Adresse lautet:

```
http://127.0.0.1:64342/stream
```

Falls IntelliJ beim Kopieren einen abweichenden Pfad ausgibt (z.B. `/mcp`), diesen stattdessen verwenden.

### MCP Server in Claude Code registrieren

In Claude Code (WSL) den Server mit folgendem Befehl hinzufügen:

```bash
claude mcp add --transport http --scope user intellij \
  http://127.0.0.1:64342/stream
```

Erwartete Ausgabe:

```
Added HTTP MCP server intellij with URL: http://127.0.0.1:64342/stream to user config
File modified: /home/dboeckli/.claude.json
```

Falls der kopierte Pfad `/mcp` lautet:

```bash
claude mcp add --transport http --scope user intellij \
  http://127.0.0.1:64342/mcp
```

### Verbindung prüfen

```bash
claude mcp list
claude mcp get intellij
```

Danach Claude Code neu starten und innerhalb der Sitzung eingeben:

```
/mcp
```

Dort sollte `intellij` verbunden angezeigt werden.

---

## Weiterführend

- Generische WSL-/Java-Basis: [`wsl-dev-setup.md`](./wsl-dev-setup.md)
- Claude-Code-Cheatsheet: [`claude-code-cheat.md`](./claude-code-cheat.md)
