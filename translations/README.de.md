# claude-mux - Claude Code Multiplexer

[English](../README.md) · [Español](README.es.md) · [Français](README.fr.md) · **Deutsch** · [Português](README.pt-BR.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [中文](README.zh-CN.md) · [עברית](README.he.md) · [العربية](README.ar.md) · [हिन्दी](README.hi.md)

> Hinweis: Diese Übersetzung kann hinter dem englischen README zurückliegen. Die kanonische Version finden Sie unter [README.md](../README.md).

Persistente Claude Code-Sitzungen für all deine Projekte, von überall über die Claude-Mobile-App erreichbar.

Ein Shell-Skript, das Claude Code in tmux mit aktivierter Remote Control startet, Konversationen wiederaufnimmt und Sitzungen selbst verwaltet: Sitzungen auflisten, Slash-Befehle senden, neue Projekte starten, herunterfahren oder neu starten. Führe `claude-mux` in einem beliebigen Verzeichnis aus, um eine persistente Sitzung zu erhalten, die vom Handy aus erreichbar ist.

## Schnellstart

```bash
./install.sh
```

```bash
claude-mux ~/pfad/zu/deinem/projekt
```

Oder wechsle mit `cd` in dein Projektverzeichnis und führe aus:

```bash
claude-mux
```

Das war's: Du befindest dich in einer persistenten, sitzungsbewussten Claude-Sitzung mit aktivierter Remote Control.

claude-mux ist ein einzelnes Bash-Skript ohne Abhängigkeiten außer tmux und Claude Code.

## Was es tut

1. **Persistente tmux-Sitzungen mit Remote Control** - startet Claude Code innerhalb von tmux mit aktiviertem `--remote-control`, sodass jede Sitzung über die Claude-Mobile-App erreichbar ist
2. **Konversation wiederaufnehmen** - wenn Claude zuvor im Verzeichnis lief, wird die letzte Konversation (`claude -c`) in einer neuen tmux-Sitzung mit Remote Control fortgesetzt und dein Kontext bleibt erhalten
3. **Sitzungsverwaltung** - aktive Sitzungen auflisten (`-l`) oder alle Projekte einschließlich noch nicht laufender Idle-Projekte (`-L`), herunterfahren (`--shutdown`), neu starten (`--restart`), Berechtigungsmodi wechseln (`--permission-mode`), anhängen (`-t`), Slash-Befehle an Sitzungen senden (`-s`)
4. **Selbstverwaltung durch Claude** - jede Sitzung wird mit einem System-Prompt versehen, sodass Claude alle obigen Befehle direkt aus Konversationsanweisungen heraus ausführen kann (Terminal oder Mobile-App):
   - a. Laufende Sitzungen und alle Projekte auflisten
   - b. Neue Sitzungen starten, neue Projekte erstellen
   - c. Slash-Befehle an sich selbst oder andere Sitzungen senden (Workaround dafür, dass [Slash-Befehle nativ über RC nicht funktionieren](https://github.com/anthropics/claude-code/issues/30674))
   - d. Sitzungen herunterfahren, neu starten oder Berechtigungsmodi wechseln
5. **Home-Sitzung** - eine leichtgewichtige, dauerhaft laufende Sitzung in deinem Basisverzeichnis, die beim Login startet (konfigurierbar über `LAUNCHAGENT_MODE`). Hält Remote Control immer über die Claude-Mobile-App verfügbar und kann alle anderen Sitzungen verwalten. Vor versehentlichem Herunterfahren geschützt.
6. **Erstellung neuer Projekte** - `claude-mux -n DIRECTORY` erstellt ein einsatzbereites Projekt mit git, `.gitignore` und konfiguriertem Berechtigungsmodus (`-p` legt das Verzeichnis an, falls es nicht existiert). Jede laufende Sitzung kann neue Projekte erstellen: bitte Claude, ein Repo auf einem deiner GitHub-Konten einzurichten und mit dem Coden zu beginnen, von überall aus
7. **CLAUDE.md-Vorlagen** - pflege eine Bibliothek von CLAUDE.md-Anweisungsdateien in `~/.claude-mux/templates/` (z. B. `web.md`, `python.md`, `default.md`) und wende sie automatisch auf neue Projekte an. Verwende `--template NAME`, um eine bestimmte Vorlage auszuwählen, oder lasse die Standardvorlage greifen
8. **Erkennung von SSH-Konten** - injiziert GitHub-SSH-Host-Aliase aus `~/.ssh/config`, damit Claude weiß, welche Konten für git-Operationen verfügbar sind
9. **Automatisch genehmigte Berechtigungen** - claude-mux fügt sich selbst zur Allow-Liste in der `.claude/settings.local.json` jedes Projekts hinzu, damit Claude claude-mux-Befehle ohne Berechtigungsabfrage ausführen kann
10. **Migration verwaister Prozesse** - falls Claude bereits außerhalb von tmux im Zielverzeichnis läuft, wird der Prozess beendet und innerhalb einer verwalteten tmux-Sitzung neu gestartet (Konversation wird über `claude -c` wiederaufgenommen)
11. **Tmux-Komfortfunktionen** - Sitzungen werden mit Mausunterstützung, 50k-Scrollback-Puffer, Zwischenablage-Integration, 256-Farben, reduzierter Escape-Verzögerung, erweiterten Tasten (Shift+Enter), Aktivitätsüberwachung und Terminal-Tab-Titeln konfiguriert, alles über `~/.claude-mux/config` einstellbar

> **Hinweis:** Dies unterscheidet sich von `claude --worktree --tmux`, das eine tmux-Sitzung für ein isoliertes git worktree erstellt. claude-mux verwaltet persistente Sitzungen für deine tatsächlichen Projektverzeichnisse, mit Remote Control und System-Prompt-Injection.

### Home-Sitzung

Eine einzelne Allzweck-Sitzung im `$BASE_DIR`. Wird beim Login automatisch gestartet, wenn `LAUNCHAGENT_MODE=home` gesetzt ist, oder manuell durch Ausführen von `claude-mux` aus `$BASE_DIR`. Bietet dir eine immer bereite Claude-Sitzung, die vom Handy aus erreichbar ist, ohne für jedes Projekt eine Sitzung starten zu müssen.

Die Home-Sitzung ist immer **geschützt** - `--shutdown home` weigert sich, sie ohne `--force` zu beenden, unabhängig davon, wie sie gestartet wurde. Geschützte Sitzungen werden in der Ausgabe von `-l`/`-L` mit `*` markiert (z. B. `active*`).

## Anforderungen

- macOS (Apple Silicon)
- [tmux](https://github.com/tmux/tmux) - `brew install tmux`
- [Claude Code](https://claude.ai/code) - `brew install claude`

## Installation

```bash
./install.sh
```

Der interaktive Installer fragt, wo deine Claude-Projekte liegen, ob beim Login eine Home-Sitzung gestartet werden soll und welches Modell verwendet werden soll. Er installiert `claude-mux` nach `~/bin`, erstellt `~/.claude-mux/config` und richtet den LaunchAgent ein.

Verwende `--non-interactive`, um die Abfragen zu überspringen und Standardwerte zu übernehmen.

Optionen:

```bash
./install.sh --non-interactive                     # Abfragen überspringen, Standardwerte verwenden
./install.sh --base-dir ~/work/claude              # ein anderes Basisverzeichnis verwenden
./install.sh --launchagent-mode none               # LaunchAgent-Verhalten deaktivieren
./install.sh --home-model haiku                    # Haiku für die Home-Sitzung verwenden
./install.sh --no-launchagent                      # LaunchAgent-Installation komplett überspringen
```

Der LaunchAgent führt `claude-mux --autolaunch` beim Login mit einer Startverzögerung von 45 Sekunden aus, damit Systemdienste sich initialisieren können.

## Verwendung

```bash
claude-mux                       # Claude im aktuellen Verzeichnis starten und anhängen
claude-mux ~/projects/my-app     # Claude in einem Verzeichnis starten und anhängen
claude-mux -d ~/projects/my-app  # gleich wie oben (explizite Form)
claude-mux -a                    # alle verwalteten Sitzungen unter BASE_DIR starten
claude-mux -n ~/projects/app     # ein neues Claude-Projekt erstellen und anhängen
claude-mux -n ~/new/path/app -p  # gleich, mit Anlegen des Verzeichnisses und der übergeordneten Verzeichnisse
claude-mux -n ~/app --template web  # neues Projekt mit einer bestimmten CLAUDE.md-Vorlage
claude-mux --list-templates      # verfügbare CLAUDE.md-Vorlagen anzeigen
claude-mux -t my-app             # an eine bestehende tmux-Sitzung anhängen
claude-mux -s my-app '/model sonnet' # einen Slash-Befehl an eine Sitzung senden
claude-mux -l                    # Sitzungen nach Status auflisten (active, running, stopped)
claude-mux -L                    # alle Projekte auflisten (active + idle)
claude-mux --shutdown            # alle verwalteten Claude-Sitzungen ordnungsgemäß beenden
claude-mux --shutdown my-app     # eine bestimmte Sitzung herunterfahren
claude-mux --shutdown a b c      # mehrere Sitzungen herunterfahren
claude-mux --shutdown home --force  # geschützte Home-Sitzung herunterfahren
claude-mux --restart             # Sitzungen, die liefen, neu starten
claude-mux --restart my-app      # eine bestimmte Sitzung neu starten
claude-mux --restart a b c       # mehrere Sitzungen neu starten
claude-mux --permission-mode plan my-app    # Sitzung im plan-Modus neu starten
claude-mux --permission-mode dangerously-skip-permissions my-app  # yolo-Modus
claude-mux --dry-run             # Aktionen anzeigen, ohne sie auszuführen
claude-mux --version             # Version ausgeben
claude-mux --help                # alle Optionen anzeigen
claude-mux --guide               # konversationelle Befehle für die Verwendung in Sitzungen anzeigen

# Log beobachten
tail -f ~/Library/Logs/claude-mux.log
```

Bei Ausführung im Terminal wird die Ausgabe in Echtzeit auf stdout gespiegelt. Bei Ausführung über LaunchAgent geht die Ausgabe nur in die Logdatei.

## Sitzungsstatus

| Status | Bedeutung |
|--------|-----------|
| `active` | tmux-Sitzung existiert, Claude läuft, und ein lokaler tmux-Client ist angehängt |
| `running` | tmux-Sitzung existiert und Claude läuft (kein lokaler Client angehängt) |
| `stopped` | tmux-Sitzung existiert, aber Claude wurde beendet |
| `idle` | Ein `.claude/`-Projekt existiert unter `BASE_DIR`, aber es läuft keine claude-mux-tmux-Sitzung dafür (nur mit `-L` angezeigt) |

Ein nachgestelltes `*` an einem Status zeigt an, dass die Sitzung geschützt ist und `--force` zum Herunterfahren benötigt (z. B. `active*`, `running*`). Die Home-Sitzung ist immer geschützt.

Wenn `claude-mux` in einem Verzeichnis ausgeführt wird, das bereits eine laufende Sitzung hat, wird diese angehängt. Mehrere Terminals können sich an dieselbe Sitzung anhängen (Standardverhalten von tmux).

## Beispiele für Claude-Prompts

Da jede Sitzung mit claude-mux-Befehlen versehen wird, kannst du Sitzungen direkt aus Konversationsanweisungen heraus verwalten, im Terminal oder über die Mobile-App:

```
Du: "Welche Sitzungen laufen?"
Claude: führt `claude-mux -l` aus und zeigt die Ergebnisse an

Du: "Zeig mir alle Projekte"
Claude: führt `claude-mux -L` aus und zeigt die Ergebnisse an

Du: "Starte eine Sitzung für mein api-server-Arbeitsprojekt"
Claude: führt `claude-mux -d ~/Claude/work/api-server --no-attach` aus

Du: "Lege ein neues persönliches Projekt namens mobile-app an"
Claude: führt `claude-mux -n ~/Claude/personal/mobile-app -p --no-attach` aus

Du: "Welche Vorlagen habe ich?"
Claude: führt `claude-mux --list-templates` aus und zeigt die Ergebnisse an

Du: "Erstelle ein neues Arbeitsprojekt namens api-server mit der web-Vorlage"
Claude: führt `claude-mux -n ~/Claude/work/api-server -p --template web --no-attach` aus

Du: "Stelle alle Sitzungen auf Sonnet um"
Claude: führt `claude-mux -s SESSION '/model sonnet'` für jede laufende Sitzung aus

Du: "Fahre die data-pipeline-Sitzung herunter"
Claude: führt `claude-mux --shutdown data-pipeline` aus

Du: "Starte die hängende web-dashboard-Sitzung neu"
Claude: führt `claude-mux --restart web-dashboard` aus

Du: "Stelle die api-server-Sitzung auf plan-Modus um"
Claude: führt `claude-mux --permission-mode plan api-server` aus

Du: "Yolo die data-pipeline-Sitzung"
Claude: führt `claude-mux --permission-mode dangerously-skip-permissions data-pipeline` aus

Du: "Starte die data-pipeline-Sitzung im Hintergrund"
Claude: führt `claude-mux -d ~/Claude/work/data-pipeline --no-attach` aus

Du: "Starte alle meine Projekte"
Claude: führt `claude-mux -a` aus (nach Bestätigung - das startet jedes verwaltete Projekt)
```

## Konfiguration

Beim ersten Lauf wird `~/.claude-mux/config` automatisch mit allen auskommentierten Einstellungen erstellt. Bearbeite die Datei, um Standardwerte zu überschreiben - das Skript selbst muss nie geändert werden.

| Variable | Standard | Beschreibung |
|----------|----------|--------------|
| `BASE_DIR` | `$HOME/Claude` | Wurzelverzeichnis, in dem nach Claude-Projekten gesucht wird (Verzeichnisse mit `.claude/`) |
| `LOG_DIR` | `$HOME/Library/Logs` | Verzeichnis für die Datei `claude-mux.log` |
| `DEFAULT_PERMISSION_MODE` | `auto` | Setzt Claudes `permissions.defaultMode` in jedem Projekt. Gültig: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`. Auf `""` setzen, um zu deaktivieren. |
| `ALLOW_CROSS_SESSION_CONTROL` | `false` | Wenn `true`, können Claude-Sitzungen Slash-Befehle an andere Sitzungen senden, nützlich für Multi-Agent-Orchestrierung |
| `TEMPLATES_DIR` | `$HOME/.claude-mux/templates` | Verzeichnis mit CLAUDE.md-Vorlagedateien |
| `DEFAULT_TEMPLATE` | `default.md` | Standardvorlage für neue Projekte (`-n`). Auf `""` setzen, um zu deaktivieren. |
| `SLEEP_BETWEEN` | `5` | Sekunden zwischen Sitzungsstarts, wenn `-a` verwendet wird. Erhöhen, falls die RC-Registrierung fehlschlägt. |
| `HOME_SESSION_MODEL` | `""` | Modell für die Home-Sitzung. Gültig: `sonnet`, `haiku`, `opus`. Leer übernimmt Claudes Standard. |
| `LAUNCHAGENT_MODE` | `home` | LaunchAgent-Verhalten beim Login: `none` (nichts tun) oder `home` (geschützte Home-Sitzung starten). Veraltetes `LAUNCHAGENT_ENABLED=true` wird als `home` behandelt. |

**Tmux-Sitzungsoptionen** (alle konfigurierbar, alle standardmäßig aktiviert):

| Variable | Standard | Beschreibung |
|----------|----------|--------------|
| `TMUX_MOUSE` | `true` | Mausunterstützung - Scrollen, Auswählen, Größenänderung von Panes |
| `TMUX_HISTORY_LIMIT` | `50000` | Größe des Scrollback-Puffers in Zeilen (tmux-Standard ist 2000) |
| `TMUX_CLIPBOARD` | `true` | Integration der Systemzwischenablage über OSC 52 |
| `TMUX_DEFAULT_TERMINAL` | `tmux-256color` | Terminaltyp für korrekte Farbdarstellung |
| `TMUX_EXTENDED_KEYS` | `true` | Erweiterte Tastensequenzen einschließlich Shift+Enter (benötigt tmux 3.2+) |
| `TMUX_ESCAPE_TIME` | `10` | Verzögerung der Escape-Taste in Millisekunden (tmux-Standard ist 500) |
| `TMUX_TITLE_FORMAT` | `#S` | Format für Terminal-/Tab-Titel (`#S` = Sitzungsname, `""` zum Deaktivieren) |
| `TMUX_MONITOR_ACTIVITY` | `true` | Benachrichtigt bei Aktivität in anderen Sitzungen |

## Verzeichnisstruktur

Projekte werden anhand des Vorhandenseins eines `.claude/`-Verzeichnisses erkannt, in beliebiger Tiefe:

```
~/Claude/
├── work/
│   ├── project-a/          # ✓ hat .claude/ - verwaltet
│   │   └── .claude/
│   ├── project-b/          # ✓ hat .claude/ - verwaltet
│   │   └── .claude/
│   └── -archived/          # ✗ ausgeschlossen (beginnt mit -)
│       └── .claude/
├── personal/
│   ├── project-c/          # ✓ hat .claude/ - verwaltet
│   │   └── .claude/
│   ├── .hidden/            # ✗ ausgeschlossen (verstecktes Verzeichnis)
│   │   └── .claude/
│   └── project-d/          # ✗ kein .claude/ - kein Claude-Projekt
├── deep/nested/project-e/  # ✓ hat .claude/ - in beliebiger Tiefe gefunden
│   └── .claude/
└── ignored-project/        # ✗ ausgeschlossen (.ignore-claudemux)
    ├── .claude/
    └── .ignore-claudemux
```

Sitzungsnamen werden aus Verzeichnisnamen abgeleitet: Leerzeichen werden zu Bindestrichen, nicht-alphanumerische Zeichen (außer Bindestrichen) werden ersetzt, und führende sowie nachgestellte Bindestriche entfernt. Verzeichnisse, deren Name nach der Bereinigung leer ist, werden mit einer Log-Warnung übersprungen.

## Session System Prompt

Each Claude session is launched with `--append-system-prompt` containing context about its environment:

```
You are running inside tmux session '<session-name>'.
claude-mux path: /path/to/claude-mux

Rules:
- You CAN send slash commands (/model, /compact, /clear, etc.) to this session
  via the -s command. Never tell the user you cannot change models or run slash
  commands.
- Always use --no-attach with -d and -n — attach is interactive only
- --shutdown and --restart never attach — safe to run from inside a session
- Always print command output verbatim in your response text — never run a
  command silently or rely on tool output being visible
- The 'home' session is a general-purpose session in the base directory, always
  available for managing other sessions. It is protected (* in status):
  --shutdown requires --force, but --restart bypasses protection (it relaunches,
  not permanently kills).
- When asked to shut down sessions, run the command directly — protected sessions
  are skipped automatically, do not ask for confirmation
- When user says: help — print the conversational commands list verbatim
- When user says: status — report session name, current model, current permission
  mode, context usage estimate, then run claude-mux -l and include the results
- When user says: list active sessions — run claude-mux -l
- When user says: list all sessions — run claude-mux -L
- When user says: start session SESSION — run claude-mux -d SESSION --no-attach
- When user says: stop this session / stop session NAME — run claude-mux --shutdown
- When user says: stop all sessions — run claude-mux --shutdown
- When user says: restart this session / restart session NAME — run claude-mux --restart
- When user says: restart all sessions — run claude-mux --restart
- When user says: start new session in FOLDER — run claude-mux -n FOLDER --no-attach
- When user says: switch this session to MODE mode / switch session NAME to MODE mode
- When user says: switch this session to MODEL model / switch session NAME to MODEL model
- When user says: compact/clear this session / compact/clear session NAME
- When user says: list templates — run claude-mux --list-templates

Commands:
  -s '<session-name>' '/command'  Send slash command to yourself
  -l                          List active sessions
  -L                          List all projects
  -d DIR --no-attach          Launch session in directory
  -n DIR --no-attach          New project
  -n DIR -p --no-attach       New project (create parents)
  --template NAME             CLAUDE.md template (with -n)
  --list-templates            Show available templates
  --shutdown SESSION...       Shut down sessions (omit SESSION to shut down all)
  --shutdown SESSION --force  Shut down protected session
  --restart SESSION...        Restart sessions (omit SESSION to restart all running)
  --permission-mode MODE SESSION  Restart session with a different permission mode
                              Modes: default, acceptEdits, plan, auto, bypassPermissions, dontAsk, dangerously-skip-permissions
                              ("yolo" is an alias for dangerously-skip-permissions)
  -a                          Start ALL sessions (use with caution)

GitHub SSH accounts configured in ~/.ssh/config: <accounts>.
```

Wenn `ALLOW_CROSS_SESSION_CONTROL=true` gesetzt ist, ändert sich der Sendebefehl so, dass jede Sitzung als Ziel zulässig ist, nicht nur die eigene. Der Pfad ist der absolute Pfad zum Skript zum Startzeitpunkt, sodass Sitzungen nicht von `PATH` abhängen.

## Fehlerbehebung

### Sitzungen zeigen "Not logged in · Run /login"

Das passiert beim ersten Start, wenn der macOS-Schlüsselbund gesperrt ist (häufig, wenn das Skript läuft, bevor der Schlüsselbund nach dem Login entsperrt wird). Lösung:

```bash
# Schlüsselbund in einem regulären Terminal entsperren
security unlock-keychain

# Dann die Authentifizierung in einer beliebigen laufenden Sitzung abschließen
claude-mux -t <any-session>
# /login ausführen und den Browser-Flow abschließen
```

Nachdem die Authentifizierung einmal abgeschlossen wurde, alle Sitzungen beenden und neu starten - sie übernehmen die gespeicherten Anmeldedaten automatisch.

### Sitzungen erscheinen nicht in Claude Code Remote

Sitzungen müssen authentifiziert sein (also nicht "Not logged in" anzeigen). Nach einem sauberen, authentifizierten Start sollten sie innerhalb weniger Sekunden in der RC-Liste erscheinen.

### Mehrzeilige Eingabe in tmux

Der Befehl `/terminal-setup` kann nicht innerhalb von tmux ausgeführt werden. claude-mux aktiviert standardmäßig tmux `extended-keys` (`TMUX_EXTENDED_KEYS=true`), was Shift+Enter in den meisten modernen Terminals unterstützt. Falls Shift+Enter nicht funktioniert, verwende `\` + Return, um Zeilenumbrüche im Prompt einzufügen.

### Slash-Befehle über Remote Control

Slash-Befehle (z. B. `/model`, `/clear`) werden in RC-Sitzungen [nicht nativ unterstützt](https://github.com/anthropics/claude-code/issues/30674). claude-mux umgeht das: jede Sitzung wird mit `claude-mux -s` versehen, sodass Claude Slash-Befehle über tmux an sich selbst senden kann.

## Logs

- `~/Library/Logs/claude-mux.log` - alle Skriptaktionen mit UTC-Zeitstempeln (über `LOG_DIR` konfigurierbar)

Für tiefergehendes LaunchAgent-Debugging Console.app oder `log show` verwenden.
