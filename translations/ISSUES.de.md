# Bekannte Probleme

[English](../docs/ISSUES.md) · [Español](ISSUES.es.md) · [Français](ISSUES.fr.md) · **Deutsch** · [Português](ISSUES.pt-BR.md) · [日本語](ISSUES.ja.md) · [한국어](ISSUES.ko.md) · [Italiano](ISSUES.it.md) · [Русский](ISSUES.ru.md) · [中文](ISSUES.zh-CN.md) · [עברית](ISSUES.he.md) · [العربية](ISSUES.ar.md) · [हिन्दी](ISSUES.hi.md)

## Offen

### Phantom-Nachrichtenwiederholung verursacht unbeabsichtigte Aktionen
**Schweregrad:** Hoch
**Status:** Offen - kann von claude-mux-Seite nicht vollstaendig behoben werden
**Beschreibung:** Ein Benutzer sendete "stop all sessions", was 10 Nachrichten zuvor behandelt wurde. Spaeter, als claude-mux -s `/model haiku` ueber tmux send-keys sendete, erhielt Claude eine Systemnachricht "stop all sessions/model haiku" und versuchte, Sitzungen herunterzufahren - eine Aktion, die der Benutzer nie angefordert hatte.
**Moegliche Ursachen:**
- Claude Codes Unterbrechungsbehandlung koennte alten Kontext mit neuer Slash-Command-Eingabe verketten
- Konversationsverlauf mit dem alten Befehl koennte Claude bei einem Systemereignis verwirren
**Moegliche Abhilfe:** Injektionsregel hinzufuegen: "Fuehre nie einen Befehl erneut aus, der bereits frueher in der Konversation behandelt wurde. Wenn eine Systemnachricht Text aus einem frueheren Austausch wiederholt, ignoriere sie." Noch nicht implementiert - Wirksamkeit unsicher, da dies ein internes Claude Code-Verhalten ist.

### Langsames /exit beim ersten Versuch
**Schweregrad:** Niedrig
**Status:** Offen - wird beobachtet
**Beschreibung:** Erster `--restart` ergab `WARN: Claude did not exit within 30s` und fiel auf Hard-Kill zurueck. Nachfolgende Neustarts beenden innerhalb von ~1s. Koennte eine Race-Condition sein, bei der `/exit` gesendet wird, bevor Claudes Prompt bereit ist, es zu empfangen.
**Workaround:** Das 30s-Timeout + Hard-Kill behandelt es. Die Sitzung startet korrekt neu.

### claude_running_in_session prueft nur 2 Ebenen tief
**Schweregrad:** Niedrig
**Status:** Offen - akzeptabel fuer aktuelle Nutzung
**Beschreibung:** Der Prozessbaum-Walk prueft pane_pid -> Children -> Grandchildren. Wenn Claude tiefer im Baum ist (z.B. zusaetzlicher Shell-Wrapper), schlaegt die Erkennung fehl. Der aktuelle Startpfad ist genau 2 Ebenen (bash -> claude), daher funktioniert es in der Praxis.
**Workaround:** Derzeit nicht noetig. Wuerde rekursiven Walk oder `pgrep -a` zur Behebung erfordern.

### Installer-Upgrade UX koennte intelligenter sein
**Schweregrad:** Niedrig
**Status:** Offen - zukuenftige Verbesserung
**Beschreibung:** Bei Neuinstallation erkennt der Installer vorhandene Konfiguration und ueberspringt Abfragen. Er bietet aber nicht an, aktuelle Einstellungen anzuzeigen, neue Konfigurationsoptionen aus neueren Versionen einzufuegen oder den Benutzer selektiv Werte aktualisieren zu lassen. Benutzer muessen `~/.claude-mux/config` manuell bearbeiten, um neue Einstellungen aus spaeteren Versionen zu uebernehmen.
**Moegliche Verbesserungen:**
- Aktuelle Konfigurationswerte beim Upgrade anzeigen
- Anbieten, neue Einstellungen (mit Standardwerten) hinzuzufuegen, die in der alten Konfiguration nicht existierten
- Option B: Abfragen mit vorhandenen Konfigurationswerten vorbefuellen und den Benutzer aendern lassen

### Uebersetzungsdateien brauchen v1.10-v1.12-Update
**Schweregrad:** Niedrig
**Status:** Offen - Uebersetzungen noch nicht aktualisiert
**Beschreibung:** Alle 12 Uebersetzungsdateien (`translations/README.*.md`) liegen mehrere Versionen zurueck (v1.10-v1.12). Aenderungen, die reflektiert werden muessen:
- curl als primaerer Quick Start (Einzeiler)
- Neue Install-Sektionsstruktur (curl empfohlen, Homebrew als macOS-Alternative)
- Sitzungsnamen statt Pfade fuer `--hide`/`--delete`/`--protect` (v1.11.0)
- Neue Konversationsbeispiele: rename, save-as-template, tip, enable/disable tips, update
- Anforderungen: "Apple Silicon or Intel" (nicht nur Apple Silicon)
- Neuer "Mehr"-Bereich mit Links zu FAQ, ISSUES, CHANGELOG
- FAQ- und ISSUES-Uebersetzungen muessen erstellt werden

### Code-Review-aufgeschobene Probleme (v1.9.0)
**Schweregrad:** Niedrig-Mittel
**Status:** In v1.10.0 behoben - M3, M4, M9/L8, L3, L9 gefixt; L4, L5, L6, L7, M7 mit Kommentaren adressiert

### Projekt umbenennen / verschieben mit Verlaufserhaltung
**Schweregrad:** Niedrig
**Status:** In v1.10.0 behoben - `--rename OLD NEW` und `--move SRC DEST` implementiert

### Projektkopie mit Verlauf
**Schweregrad:** Niedrig
**Status:** Offen - geplantes Feature, erfordert Untersuchung
**Beschreibung:** Ein Projekt inklusive Claude Code-Verlauf und -Speicher zu kopieren ist komplexer als Umbenennen/Verschieben, da fuer das Ziel neue UUIDs erstellt werden muessen.
**Vorgeschlagener Ansatz:**
1. Neues Projektverzeichnis erstellen (mit optionalem git init und Template)
2. Eine Sitzung darin starten und sofort stoppen - Claude Code initialisiert `~/.claude/projects/-kodierter-neuer-pfad/` mit einer frischen UUID und erstellt einen neuen Homunculus-Eintrag
3. `.jsonl`-Verlaufsdateien aus dem Quell-`~/.claude/projects/`-Ordner in den Zielordner kopieren
4. `memory/`-Ordnerinhalte kopieren - reines Markdown, keine eingebetteten UUIDs, sicher zum direkten Kopieren
5. UUID-Unterverzeichnisse (Task/Plan-Artefakte) zusammen mit ihren `.jsonl`-Dateien kopieren
6. Fuer Homunculus: `observations.jsonl`, `instincts`, `evolved`, `observations.archive` aus Quell-`~/.claude/homunculus/projects/<src-uuid>/` in den neuen Ziel-Homunculus-Ordner kopieren - die neue Projekt-UUID aus Schritt 2 beibehalten
**Offene Fragen, die Tests erfordern:**
- Betten `.jsonl`-Dateien den Quellprojektpfad in ihrem Inhalt oder ihren Metadaten ein? Falls ja, wuerde kopierter Verlauf den alten Pfad referenzieren.
- Werden UUID-Unterverzeichnisse innerhalb von `.jsonl`-Dateien per UUID referenziert? Falls ja, muessen sie unter ihren Original-UUIDs kopiert werden, nicht umgemappt.
- Liest Claude Code alle `.jsonl`-Dateien in einem Projektordner oder nur die, die zur aktiven Sitzungs-UUID passt?
- Was enthalten `~/.claude/homunculus/projects/<uuid>/evolved` und `instincts` - sind sie abgeleitet/berechnet oder benutzerrelevant? Lohnt sich das Bewahren bei einer Kopie?
- Gibt es weitere interne Referenzen, die bei einer naiven Dateikopie kaputtgehen wuerden?
**Voraussetzung:** Obiges vor der Implementierung testen, um kein Copy-Kommando auszuliefern, das subtil fehlerhaften Verlauf erzeugt.

### Tip of the Day
**Schweregrad:** Niedrig
**Status:** In v1.10.0 behoben - `--tip`, `TIP_OF_DAY`, `TIP_MODE`, Tagessperre, Zustellung bei Sitzungsstart implementiert

### Antwort-Zeitstempel
**Schweregrad:** Niedrig
**Status:** Offen - vor Implementierung diskutieren
**Beschreibung:** Optionale Config-Variable (`REPLY_TIMESTAMP=false` Standard), die eine Anweisung in den System-Prompt injiziert, die Claude anweist, jede Antwort mit aktuellem Datum und Uhrzeit ueber `date '+%Y-%m-%d %H:%M'` zu beginnen.
**Abwaegung:** Erfordert einen Bash-Tool-Aufruf am Anfang jeder Antwort (kleiner Overhead). Alternative: Sitzungsstartzeit in den Prompt injizieren (kostenlos, driftet aber in langen Sitzungen).
**Hinweis:** Eine projekt-eigene CLAUDE.md-Anweisung (wie im analytischen Template) ist die leichtere Version - nur bei Projekten, die es wollen. Die Config-Variable macht es global.

### Demo-Video
**Schweregrad:** Niedrig
**Status:** Offen - geplantes Asset
**Beschreibung:** Eine Bildschirmaufnahme, die claude-mux von der curl-Installation bis zu gaengigen und interessanten Befehlen zeigt, mit Terminal und Remote Control gleichzeitig sichtbar.
**Format:** Geteilter Bildschirm, eine Aufnahme. Terminal (vollstaendige claude-mux-Sitzung) links, RC auf iPhone gespiegelt per QuickTime rechts. Beide gleichzeitig live - der Zuschauer sieht Aktionen in RC sofort im Terminal und umgekehrt.
**Siehe:** `internal/demo-script.md` fuer den vollstaendigen Aufnahmeplan.
**Hinweise:**
- Die Schluesselszene: Tippen in RC auf dem Handy und beobachten, wie das Terminal in Echtzeit reagiert
- Kein Schnitt noetig ausser Trimmen - eine durchgehende Aufnahme
- Hosting auf YouTube + Einbettung in README; auch nuetzlich fuer Product Hunt Launch

### Einreichung bei homebrew-core fuer brew.sh-Listung
**Schweregrad:** Niedrig
**Status:** Zukunft - wartet auf Verbreitung
**Beschreibung:** claude-mux wird derzeit ueber einen persoenlichen Tap (`pereljon/tap`) verteilt. Um auf brew.sh zu erscheinen, muss es in homebrew-core aufgenommen werden. Homebrews Bekanntheitshuerde erfordert typischerweise einige hundert GitHub-Stars, bevor eine Shell-Skript-Einreichung akzeptiert wird; Einreichungen mit wenigen Stars werden schnell geschlossen.
**Wenn bereit:**
- Sicherstellen, dass die Formel `brew audit --strict --new` besteht
- PR an `Homebrew/homebrew-core` mit der Formel einreichen
- Hinweis: Nur-macOS-Tools unterliegen strengerer Pruefung; Linux-Unterstuetzung (siehe unten) wuerde helfen

### curl-Installationsunterstuetzung (macOS + Linux)
**Schweregrad:** Niedrig
**Status:** In v1.10.0 behoben - curl-Installation implementiert, Release-Assets-Workflow hinzugefuegt, README aktualisiert

### Nur macOS - keine Linux/systemd-Unterstuetzung
**Schweregrad:** Mittel
**Status:** Offen - teilweise adressiert (Pfaderkennung erledigt, LaunchAgent/Installer bleiben macOS-spezifisch)
**Beschreibung:** Verwendet macOS LaunchAgent (launchd) und macOS-spezifische Tools. Die Pfaderkennung wurde auf `command -v` umgestellt (nicht mehr fest `/opt/homebrew/bin`), sodass das Hauptskript jetzt auf jeder Plattform funktioniert, auf der tmux und claude im PATH sind. LaunchAgent und Installer bleiben macOS-spezifisch.
**Verbleibend:** systemd-User-Unit, XDG-Autostart-Fallback, `uname -s`-Dispatch im Installer.
**Paketstrategie (v1.10+):**
- curl-Installation: universeller Fallback, funktioniert ueberall (siehe oben)
- AUR: geringer Aufwand, hohe Reichweite bei der Zielgruppe auf Arch/Manjaro
- apt PPA: wenn es Nachfrage von Debian/Ubuntu-Benutzern gibt
- Homebrew auf Linux: deckt Benutzer ab, die es bereits haben
- Snap/Flatpak: lohnt sich nicht fuer ein Bash-Skript

### ! Befehle nicht verfuegbar in Remote Control
**Schweregrad:** Niedrig
**Status:** Geschlossen - nicht umsetzbar
**Beschreibung:** Claude Codes `!` Shell-Passthrough ist ein Feature des Claude Code CLI-Eingabe-Handlers - es faengt `!command` ab, bevor die Shell es sieht. tmux send-keys kann dies nicht replizieren: Tastatureingaben, die gesendet werden waehrend Claude Code aktiv ist, gehen ins Leere (getestet: `!touch test` ueber send-keys hat nicht ausgefuehrt). Es gibt keinen Weg fuer claude-mux, `!command`-Bypass fuer RC-Benutzer zu implementieren.
**Loesung:** Injektionsregel hinzufuegen, die Claude anweist, Benutzern nie `! <command>` vorzuschlagen, da RC-Benutzer keine Shell haben und Terminal-Benutzer es einfach selbst tippen koennen.

---

## v2.0-Meilenstein

Architekturelle Aenderungen, die gross genug sind, um einen Major-Versions-Bump zu rechtfertigen. Nicht geplant - hier gesammelt, damit sie nicht verloren gehen.

### Datenverzeichnis-Trennung
Statische Daten (Tipps, Standard-Templates, moeglicherweise Command/Guide-Ausgabe) aus dem Skript in ein plattformgerechtes Datenverzeichnis verschieben. Das Skript wuerde `DATA_DIR` beim Start relativ zum Binary-Standort aufloesen, mit eingebetteten Fallbacks fuer Einzeldatei-Installationen.

- Homebrew (Apple Silicon): `/opt/homebrew/share/claude-mux/`
- Homebrew (Intel): `/usr/local/share/claude-mux/`
- Linux: `/usr/local/share/claude-mux/` oder `$XDG_DATA_DIRS`
- Manuelle Installation: Fallback auf eingebettete Standardwerte (Einzeldatei-Installationen funktionieren weiterhin)

Ausloeser: wenn die eingebetteten Daten (Tipps, Standard-Templates) gross genug werden, um das Skript schwer lesbar zu machen, oder wenn Standard-Templates unabhaengig von Skript-Releases per Brew ausgeliefert werden muessen.

### Sprach-/Runtime-Neuueberlegung
Das monolithische Bash-Skript ist bei aktuellem Umfang die richtige Entscheidung. Wenn claude-mux signifikant waechst - Projekt-Umbenennen/Verschieben/Kopieren, ein Relay-Layer, plattformuebergreifendes Packaging, ein Datenverzeichnis - faengt Bash an, sich zu wehren. An dem Punkt lohnt es sich, den Sitzungsmanagement-Kern in Go oder einer anderen typisierten Sprache (mit Bash als duennem CLI-Wrapper) umzuschreiben.

---

## Behoben

### Claude ignoriert Injektion und behauptet, keine Slash Commands ausfuehren zu koennen
**Behoben in:** v1.2.0 (Injektion aktualisiert)
**Fix:** Explizite Regel zur Injektion hinzugefuegt: "You CAN send slash commands (`/model`, `/compact`, `/clear`, etc.) to this session via the `-s` command. Never tell the user you cannot change models or run slash commands." Claudes Basis-Training neigt dazu, dass es glaubt, seine eigenen Modell-/Einstellungen nicht steuern zu koennen; die explizite Regel ueberschreibt dies in der Praxis.

### Mehrere Befehle geben Exit-Code 1 trotz Erfolg zurueck
**Behoben in:** v1.2.0 (Restart), v1.3.0 (alle Befehle)
**Fix:** Explizites `exit 0` nach jedem Dispatch-Pfad im Case-Statement hinzugefuegt. Der letzte Befehl in einer Funktion kann einen Nicht-Null-Exit-Code von internen Tests oder grep-Aufrufen durchsickern lassen.

### --dry-run gibt irrefuehrende Ausgabe fuer --restart
**Behoben in:** v1.2.0 (Commit a10c0c2)
**Fix:** Dry-Run zeigt jetzt "Would restart session" statt Kill zu simulieren und dann echten Zustand zu pruefen.

### Sitzungserkennung schlaegt mit pgrep auf macOS fehl
**Behoben in:** Commit e1b11b5
**Fix:** `pgrep -P` durch `ps -eo` + `awk` fuer zuverlaessige Kindprozess-Erkennung ersetzt.

### $TMUX-Variable hat tmux' Umgebungsvariable ueberschattet
**Behoben in:** Commit 02a2e82
**Fix:** In `$TMUX_BIN` umbenannt.

### Bash 3.2-Inkompatibilitaet (declare -A)
**Behoben in:** Commit 575eac1
**Fix:** Assoziative Arrays durch stringbasierte Kollisionserkennung ersetzt.

---

## Referenz: ~/.claude-Ordnerstruktur

Hier dokumentiert, weil mehrere geplante Features (Umbenennen, Verschieben, Kopieren, Bereinigen) korrekt mit dieser Struktur interagieren muessen. Nicht vollstaendig - deckt die fuer claude-mux relevanten Teile ab.

### Projektverlauf und -speicher: `~/.claude/projects/`

Ein Unterverzeichnis pro Arbeitsverzeichnis, in dem Claude Code verwendet wurde. Benannt durch Kodierung des absoluten Pfads: `/` -> `-`, Leerzeichen und Sonderzeichen -> `-`. Verlustbehaftet, aber lesbar.

Inhalte jedes Projektordners:
- `<uuid>.jsonl` - vollstaendiges Konversationstranskript fuer diese Sitzung. Eine Datei pro Konversation.
- `<uuid>/` - Unterverzeichnis mit Artefakten einer Konversation (Tasks, Plaene). UUID stimmt mit der `.jsonl`-Datei ueberein.
- `memory/` - persistente sitzungsuebergreifende Speicherdateien (Markdown mit Frontmatter). Nur vorhanden, wenn Speicher fuer das Projekt geschrieben wurde.

Die Verbindung zwischen Arbeitsverzeichnis und Verlauf ist rein der kodierte Ordnername. Umbenennen oder Verschieben des Projektverzeichnisses ohne Umbenennung dieses Ordners fuehrt dazu, dass Claude Code ohne Verlauf neu beginnt.

**Kodierungsregel:** absoluter Pfad, wobei jeder `/`, Leerzeichen und jedes Sonderzeichen durch `-` ersetzt wird. Fuehrender `/` wird zu fuehrendem `-`. Kodierung ist verlustbehaftet - aufeinanderfolgende Sonderzeichen und Leerzeichen neben Schraegstrichen werden beide zu `-`, sodass das Original nicht immer perfekt rekonstruiert werden kann.

### Paralleles Beobachtbarkeitsregister: `~/.claude/homunculus/`

Ein separates System, das Tool-Level-Ereignisse pro Projekt verfolgt. Nicht Teil des Claude Code-Kernverlaufs - scheint eine Ueberwachungs-/Lernschicht zu sein.

- `projects.json` - Register aller bekannten Projekte, indexiert durch kurze Hex-UUID (`d6b3aef60967`, etc.). Jeder Eintrag hat: `id`, `name`, `root` (absoluter Pfad), `remote`, `created_at`, `last_seen`.
- `projects/<uuid>/project.json` - Pro-Projekt-Metadaten (gleiche Felder wie der Registereintrag).
- `projects/<uuid>/observations.jsonl` - Zeitgestempelte `tool_start`/`tool_complete`-Ereignisse: Tool-Name, Sitzungs-UUID, Projektname/-ID, Input/Output-Ausschnitte.
- `projects/<uuid>/instincts` - Abgeleitete Muster (Inhalte unbekannt, wahrscheinlich berechnet).
- `projects/<uuid>/evolved` - Weiterentwickelter/gelernter Zustand (Inhalte unbekannt).
- `projects/<uuid>/observations.archive` - Archivierte aeltere Beobachtungen.

**Wesentlicher Unterschied zu `~/.claude/projects/`:** Verwendet kurze Hex-UUIDs als Schluessel, keine kodierten Pfade. Das `root`-Feld enthaelt den absoluten Pfad. Jede Operation, die den Pfad eines Projekts aendert (Umbenennen, Verschieben), muss `root` sowohl in `projects.json` als auch in `projects/<uuid>/project.json` aktualisieren.

### Globale Konfiguration: `~/.claude/settings.json`

Haupt-Einstellungsdatei von Claude Code. Rollende Backups werden als `~/.claude.json.backup.<timestamp>` in `~/.claude/backups/` geschrieben - mehrere pro Stunde bei aktiver Nutzung. claude-mux sollte diese Datei nicht anfassen.

### Globale Agents, Skills, Commands

- `~/.claude/agents/` - Subagent-Definitionen (`.md`-Dateien, ~38). Global, nicht pro Projekt.
- `~/.claude/skills/` - Skill-Verzeichnisse (~125). Global, nicht pro Projekt.
- `~/.claude/commands/` - Slash-Command-Definitionen (`.md`-Dateien, ~72). Global, nicht pro Projekt.
- `~/.claude/hooks/hooks.json` - Hook-Definitionen. Global. claude-mux sollte diese nicht anfassen.

### Potenzielle zukuenftige Features

| Feature | Was anzufassen ist |
|---------|-------------------|
| `--copy` | Verzeichnis erstellen; Sitzung starten+stoppen um beide Register zu initialisieren; `.jsonl` + `memory/` + UUID-Unterverzeichnisse kopieren; Homunculus-Beobachtungsdateien in neuen UUID-Ordner kopieren |
| `--delete` Bereinigung | Verschiebt bereits den Projektordner in den Papierkorb. Optional: verwaisten `~/.claude/projects/`-kodierten Ordner und `~/.claude/homunculus/`-Eintrag entfernen |
| Verlaufsgroessen-Warnung | Warnen, wenn die `.jsonl`-Dateien eines Projekts einen Schwellenwert ueberschreiten (das Haupt-claude-mux-Transkript erreichte 107MB in einer einzelnen langen Sitzung) |
