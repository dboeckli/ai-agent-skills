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

WSL2 leitet `127.0.0.1` automatisch an den Windows-Host weiter. Claude Code im WSL-Terminal erreicht den IntelliJ-MCP-Server deshalb ohne weitere Konfiguration unter `http://127.0.0.1:64342/sse`.

> **Brave Mode** (Run shell commands without confirmation) bleibt deaktiviert — Claude Code übernimmt die Ausführung von Shell-Befehlen selbst und bringt sein eigenes Berechtigungssystem mit.

---

## Optionaler Ausblick

Diese Anleitung deckt die grundlegende Einrichtung ab. Für eine vollständige Entwicklungsumgebung empfiehlt sich eine Erweiterung um Docker-Integration für Container-basierte Entwicklung sowie weitere Build-Runner, Linter und Code-Formatierer.
