# WSL Development Setup: WSL, Java und Spring Boot

Diese Anleitung beschreibt das Setup einer generischen Entwicklungsumgebung für WSL mit Java und Spring Boot. Sie richtet sich an Entwickler, die eine konsistente Umgebung für die Backend-Entwicklung einrichten möchten. Die Claude-Code-spezifischen Schritte sind in [`claude-code-setup.md`](./claude-code-setup.md) beschrieben.

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

## GitHub CLI installieren

Die GitHub CLI ermöglicht die Verwaltung von GitHub-Repositories direkt vom Terminal aus, inklusive Commits, Pull-Requests und Issues.

```bash
sudo apt install gh -y
```

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

---

## Weiterführend

- Claude Code unter WSL: [`claude-code-setup.md`](./claude-code-setup.md)
- Claude-Code-Cheatsheet: [`claude-code-cheat.md`](./claude-code-cheat.md)
