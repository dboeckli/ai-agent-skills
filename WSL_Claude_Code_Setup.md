# WSL Claude Code Setup: Installationsanleitung

Diese Anleitung beschreibt das Setup einer Entwicklungsumgebung für WSL mit Claude Code, Java und Spring Boot. Sie richtet sich an Entwickler, die eine konsistente Umgebung für die Backend-Entwicklung einrichten möchten.

---

## WSL Distributionen anzeigen und verwalten

### Alle installierten Distributionen anzeigen

Mit dem folgenden Befehl werden alle installierten WSL-Distributionen samt ihrem Status und der WSL-Version aufgelistet.

```bash
wsl -l -v --all
```

Beispielausgabe:

```
  NAME              STATE           VERSION
* Ubuntu-24.04      Running         2
  Ubuntu            Running         2
  docker-desktop    Running         2
```

Die Ausgabe zeigt, dass Ubuntu-24.04 als Standarddistribution aktiv ist und mit WSL Version 2 läuft.

### Eine bestimmte Distribution starten

Um eine spezifische Distribution zu starten, wird der Befehl `wsl -d` mit dem gewünschten Distributamen verwendet.

```bash
wsl -d Ubuntu-24.04
wsl -d Ubuntu-26.04
```

Es können beliebige installierte Distributionen auf diese Weise gestartet werden.

### Eine Distribution beenden

Eine laufende Distribution kann bei Bedarf manuell beendet werden.

```bash
wsl --terminate Ubuntu-26.04
```

### Standarddistribution starten

Wenn der Befehl `wsl` ohne Parameter ausgeführt wird, startet automatisch die als Standard markierte Distribution. In diesem Fall ist das Ubuntu-24.04.

### Verfügbare Distributionen anzeigen

Um zu prüfen, welche Distributionen über den Microsoft Store beziehungsweise über `wsl --install` verfügbar sind, dient dieser Befehl.

```bash
wsl --list --online
```

---

## Java und Spring Boot Entwicklungsumgebung einrichten

Die folgenden Schritte sollten nach dem ersten Start einer neuen Distribution durchgeführt werden.

### System aktualisieren

Zunächst werden die Paketlisten aktualisiert und alle installierten Pakete auf den neuesten Stand gebracht.

```bash
sudo apt update && sudo apt upgrade -y
```

### SDKMAN installieren

SDKMAN ist ein Werkzeug zum komfortablen Verwalten mehrerer Java und Gradle Versionen. Es ermöglicht das Wechseln zwischen verschiedenen Versionen ohne grossen Aufwand. Zunächst werden die benötigten Abhängigkeiten installiert, anschliessend SDKMAN selbst.

```bash
sudo apt-get install zip unzip
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
```

### Java installieren

Mit SDKMAN wird eine spezifische Java-Version installiert. Das folgende Beispiel zeigt die Installation von Java 25 aus der librca-Distribution.

```bash
sdk install java 25.0.4-librca
```

### Maven installieren

Maven ist ein weit verbreitetes Build-Werkzeug für Java-Projekte und wird ebenfalls über SDKMAN installiert.

```bash
sdk install maven
```

### Git installieren

Git ist für die Versionsverwaltung und die Zusammenarbeit mit GitHub unerlässlich.

```bash
sudo apt install git -y
```

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
    "allow": [
      "Bash(npx ctx7@latest *)",
      "Bash(ctx7 *)"
    ]
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
    "allow": [
      "Bash(npx ctx7@latest *)",
      "Bash(ctx7 *)"
    ]
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

> **Hinweis:** Der Stop-Hook für `format.sh` wird automatisch durch das Install-Script eingetragen (siehe nächster Abschnitt) — er muss hier nicht manuell ergänzt werden.

---

## Stop-Hook: Formatter (format.sh)

Nach jeder Claude-Session wird automatisch ein Stop-Hook ausgeführt, der Dateien mit Prettier und `shfmt` formatiert. Der Scope ist bewusst eingeschränkt auf:

- `CLAUDE.md` im Projekt-Root
- alle Dateien unter `.claude/` (Markdown, JSON, YAML, Shell-Skripte)

**Warum nicht das gesamte Projekt?** Spring-Boot-Projekte haben in ihrer `pom.xml` Spotless konfiguriert, das für Markdown Flexmark und für Shell-Skripte eigene Formatierungsregeln nutzen kann. Prettier und Flexmark produzieren bei Markdown-Dateien teilweise inkompatible Ausgaben — z.B. bei Tabellen, Code-Blöcken oder Zeilenumbrüchen. Dasselbe gilt für Shell-Skripte: Ein projektweiter `shfmt`-Lauf würde die Spotless-Formatierung überschreiben und bei `mvn verify` zu Formatierungsfehlern führen.

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

## Projektzugriff und GitHub CLI

### Projektverzeichnis für Claude Code freigeben

Claude Code benötigt Zugriff auf das Projektverzeichnis, um Code lesen und bearbeiten zu können. Bei der ersten Interaktion in einem Verzeichnis wird entsprechende Berechtigung erteilt. Ein typischer Pfad für ein Spring-Boot-Projekt unter Windows könnte wie folgt aussehen:

```
/mnt/c/development/projects/spring-6-rest-mvc/
```

### GitHub CLI installieren

Die GitHub CLI ermöglicht die Verwaltung von GitHub-Repositories direkt vom Terminal aus, inklusive Commits, Pull-Requests und Issues.

```bash
sudo apt install gh -y
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

Damit Claude Code im WSL-Terminal den IntelliJ-MCP-Server erreicht, muss WSL2 im **mirrored networking mode** betrieben werden (siehe nächster Abschnitt). Der Server ist dann unter `http://127.0.0.1:64342/stream` erreichbar.

> **Brave Mode** (Run shell commands without confirmation) bleibt deaktiviert — Claude Code übernimmt die Ausführung von Shell-Befehlen selbst und bringt sein eigenes Berechtigungssystem mit.

---

## WSL mirrored networking für IntelliJ MCP Server

Seit Windows 11 Version 22H2 unterstützt WSL2 den **mirrored networking mode**, bei dem WSL denselben Netzwerk-Stack wie Windows verwendet. Dadurch ist `127.0.0.1` aus WSL heraus direkt auf dem Windows-Host erreichbar — Voraussetzung für den IntelliJ-MCP-Server. Weitere Details: [WSL networking documentation](https://learn.microsoft.com/en-us/windows/wsl/networking)

### Aktivierung

Öffne in Windows die Datei `%USERPROFILE%\.wslconfig`. Falls die Datei nicht existiert, erstelle sie mit folgendem Inhalt:

```ini
[wsl2]
networkingMode=mirrored
```

Danach WSL vollständig neu starten:

```bash
wsl --shutdown
```

Anschliessend die WSL-Distribution wieder starten (z.B. Ubuntu über das Startmenü oder `wsl`).

### Testen

Nach dem Neustart prüfen, ob der IntelliJ-MCP-Server aus WSL erreichbar ist:

```bash
curl http://127.0.0.1:64342
```

Erwartete Ausgabe bei laufendem IntelliJ mit aktiviertem MCP Server:

```
OK
```

### MCP Server URL in IntelliJ holen

In IntelliJ unter **Settings → Tools → MCP Server** kann die können die URLs geholt werden:

```
http://127.0.0.1:64342/stream
http://127.0.0.1:64342/sse
```

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

## Opencode einrichten

Opencode ist ein CLI-Tool (Alternative zu Claude Code) für die KI-gestützte Code-Entwicklung im Terminal.

### Installation

```bash
curl -fsSL https://opencode.ai/install | bash
```

### Globale Konfiguration

Die globale Konfiguration liegt in `~/.config/opencode/opencode.jsonc`. Hier wird der IntelliJ-MCP-Server eingetragen, damit opencode auf die IDE-Intelligenz zugreifen kann:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "idea": {
      "type": "remote",
      "url": "http://127.0.0.1:64342/sse",
      "headers": {}
    }
  }
}
```

### Nutzung

```bash
# Im Projektverzeichnis starten
opencode

# Mit einem bestimmten Modell
opencode --model anthropic/claude-sonnet-4-6
```

Nach dem Start fragt opencode nach den nötigen Berechtigungen für das Projektverzeichnis. Der MCP-Server zu IntelliJ wird automatisch verbunden, sobald IntelliJ läuft und der MCP-Server dort aktiviert ist.

---

## Optionaler Ausblick

Diese Anleitung deckt die grundlegende Einrichtung ab. Für eine vollständige Entwicklungsumgebung empfiehlt sich eine Erweiterung um Docker-Integration für Container-basierte Entwicklung sowie weitere Build-Runner, Linter und Code-Formatierer.
