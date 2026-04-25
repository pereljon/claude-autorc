# claude-mux - Multiplexeur Claude Code

[English](../README.md) · [Español](README.es.md) · **Français** · [Deutsch](README.de.md) · [Português](README.pt-BR.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [中文](README.zh-CN.md) · [עברית](README.he.md) · [العربية](README.ar.md) · [हिन्दी](README.hi.md)

> Remarque : Cette traduction peut être en retard par rapport au README anglais. Consultez [README.md](../README.md) pour la version canonique.

Des sessions Claude Code persistantes pour tous vos projets, accessibles depuis n'importe où via l'application mobile Claude.

Un script shell qui lance Claude Code dans tmux avec Remote Control activé, la reprise de conversation et l'autogestion des sessions : lister les sessions, envoyer des slash commands, démarrer de nouveaux projets, arrêter ou redémarrer. Lancez `claude-mux` dans n'importe quel répertoire pour obtenir une session persistante accessible depuis votre téléphone.

## Démarrage rapide

```bash
./install.sh
```

```bash
claude-mux ~/chemin/vers/votre/projet
```

Ou faites `cd` dans le répertoire de votre projet et exécutez :

```bash
claude-mux
```

C'est tout. Vous êtes dans une session Claude persistante, consciente de son contexte, avec Remote Control activé.

claude-mux est un simple script bash sans dépendances autres que tmux et Claude Code.

## Ce qu'il fait

1. **Sessions tmux persistantes avec Remote Control** : lance Claude Code dans tmux avec `--remote-control` activé, afin que chaque session soit accessible depuis l'application mobile Claude
2. **Reprise de conversation** : si Claude tournait précédemment dans le répertoire, reprend la dernière conversation (`claude -c`) dans une nouvelle session tmux avec Remote Control, en préservant votre contexte
3. **Gestion des sessions** : lister les sessions actives (`-l`) ou tous les projets, y compris ceux inactifs qui ne sont pas encore lancés (`-L`), arrêter (`--shutdown`), redémarrer (`--restart`), changer le mode de permission (`--permission-mode`), s'attacher (`-t`), envoyer des slash commands aux sessions (`-s`)
4. **Autogestion par Claude** : chaque session reçoit en injection un system prompt qui permet à Claude d'exécuter toutes les commandes ci-dessus directement depuis les prompts de conversation (terminal ou application mobile) :
   - a. Lister les sessions en cours d'exécution et tous les projets
   - b. Lancer de nouvelles sessions, créer de nouveaux projets
   - c. Envoyer des slash commands à elle-même ou à d'autres sessions (contournement pour [les slash commands qui ne fonctionnent pas nativement via RC](https://github.com/anthropics/claude-code/issues/30674))
   - d. Arrêter, redémarrer ou changer le mode de permission des sessions
5. **Session principale** : une session légère, toujours active dans votre répertoire de base, lancée à l'ouverture de session (configurable via `LAUNCHAGENT_MODE`). Garde Remote Control toujours disponible depuis l'application mobile Claude et peut gérer toutes vos autres sessions. Protégée contre les arrêts accidentels.
6. **Création de nouveaux projets** : `claude-mux -n DIRECTORY` crée un projet prêt à coder avec git, `.gitignore` et le mode de permission configuré (`-p` crée le répertoire s'il n'existe pas). Toute session en cours peut créer de nouveaux projets : demandez à Claude de configurer un dépôt sur n'importe lequel de vos comptes GitHub et commencez à coder, depuis n'importe où
7. **Modèles CLAUDE.md** : maintenez une bibliothèque de fichiers d'instructions CLAUDE.md dans `~/.claude-mux/templates/` (par exemple `web.md`, `python.md`, `default.md`) et appliquez-les automatiquement aux nouveaux projets. Utilisez `--template NAME` pour choisir un modèle spécifique ou laissez celui par défaut s'appliquer
8. **Reconnaissance des comptes SSH** : injecte les alias d'hôtes SSH GitHub depuis `~/.ssh/config` pour que Claude sache quels comptes sont disponibles pour les opérations git
9. **Permissions auto-approuvées** : claude-mux s'ajoute lui-même à la liste d'autorisations de chaque projet dans `.claude/settings.local.json` afin que Claude puisse exécuter les commandes claude-mux sans demander la permission
10. **Migration des processus orphelins** : si Claude tourne déjà dans le répertoire cible en dehors de tmux, il est arrêté et relancé dans une session tmux gérée (la conversation reprend via `claude -c`)
11. **Confort tmux** : les sessions sont configurées avec la prise en charge de la souris, un buffer de défilement de 50k lignes, l'intégration du presse-papiers, le 256-color, un délai d'échappement réduit, les extended keys (Shift+Enter), la surveillance d'activité et les titres d'onglets de terminal, le tout configurable dans `~/.claude-mux/config`

> **Remarque :** ceci diffère de `claude --worktree --tmux`, qui crée une session tmux pour un git worktree isolé. claude-mux gère des sessions persistantes pour vos répertoires de projet réels, avec Remote Control et injection de system prompt.

### Session principale

Une seule session généraliste vivant dans `$BASE_DIR`. Lancée automatiquement à l'ouverture de session quand `LAUNCHAGENT_MODE=home`, ou manuellement en exécutant `claude-mux` depuis `$BASE_DIR`. Vous donne une session Claude toujours prête, accessible depuis votre téléphone, sans avoir à lancer une session pour chaque projet.

La session principale est toujours **protégée** : `--shutdown home` refuse de l'arrêter sans `--force`, quelle que soit la façon dont elle a été démarrée. Les sessions protégées sont marquées d'un `*` dans la sortie de `-l`/`-L` (par exemple `active*`).

## Prérequis

- macOS (Apple Silicon)
- [tmux](https://github.com/tmux/tmux) - `brew install tmux`
- [Claude Code](https://claude.ai/code) - `brew install claude`

## Installation

```bash
./install.sh
```

L'installeur interactif demande où se trouvent vos projets Claude, s'il faut démarrer une session principale à l'ouverture de session, et quel modèle utiliser. Il installe `claude-mux` dans `~/bin`, crée `~/.claude-mux/config` et configure le LaunchAgent.

Utilisez `--non-interactive` pour ignorer les prompts et accepter les valeurs par défaut.

Options :

```bash
./install.sh --non-interactive                     # ignore les prompts, utilise les valeurs par défaut
./install.sh --base-dir ~/work/claude              # utilise un répertoire de base différent
./install.sh --launchagent-mode none               # désactive le comportement du LaunchAgent
./install.sh --home-model haiku                    # utilise Haiku pour la session principale
./install.sh --no-launchagent                      # ignore complètement l'installation du LaunchAgent
```

Le LaunchAgent exécute `claude-mux --autolaunch` à l'ouverture de session avec un délai de démarrage de 45 secondes pour permettre l'initialisation des services système.

## Utilisation

```bash
claude-mux                       # lance Claude dans le répertoire courant et s'attache
claude-mux ~/projects/my-app     # lance Claude dans un répertoire et s'attache
claude-mux -d ~/projects/my-app  # identique (forme explicite)
claude-mux -a                    # démarre toutes les sessions gérées sous BASE_DIR
claude-mux -n ~/projects/app     # crée un nouveau projet Claude et s'attache
claude-mux -n ~/new/path/app -p  # idem, en créant le répertoire et ses parents
claude-mux -n ~/app --template web  # nouveau projet avec un modèle CLAUDE.md spécifique
claude-mux --list-templates      # affiche les modèles CLAUDE.md disponibles
claude-mux -t my-app             # s'attache à une session tmux existante
claude-mux -s my-app '/model sonnet' # envoie une slash command à une session
claude-mux -l                    # liste les sessions par statut (active, running, stopped)
claude-mux -L                    # liste tous les projets (actifs + inactifs)
claude-mux --shutdown            # quitte proprement toutes les sessions Claude gérées
claude-mux --shutdown my-app     # arrête une session spécifique
claude-mux --shutdown a b c      # arrête plusieurs sessions
claude-mux --shutdown home --force  # arrête la session principale protégée
claude-mux --restart             # redémarre les sessions qui tournaient
claude-mux --restart my-app      # redémarre une session spécifique
claude-mux --restart a b c       # redémarre plusieurs sessions
claude-mux --permission-mode plan my-app    # redémarre la session en mode plan
claude-mux --permission-mode dangerously-skip-permissions my-app  # mode yolo
claude-mux --dry-run             # prévisualise les actions sans les exécuter
claude-mux --version             # affiche la version
claude-mux --help                # affiche toutes les options
claude-mux --guide               # affiche les commandes conversationnelles à utiliser dans les sessions

# Suivre le journal
tail -f ~/Library/Logs/claude-mux.log
```

Lorsqu'il est exécuté depuis le terminal, la sortie est dupliquée vers stdout en temps réel. Lorsqu'il est exécuté via le LaunchAgent, la sortie va uniquement dans le fichier de log.

## Statuts de session

| Statut | Signification |
|--------|---------------|
| `active` | la session tmux existe, Claude tourne, et un client tmux local est attaché |
| `running` | la session tmux existe et Claude tourne (aucun client local attaché) |
| `stopped` | la session tmux existe mais Claude s'est arrêté |
| `idle` | un projet `.claude/` existe sous `BASE_DIR` mais aucune session tmux claude-mux n'est en cours d'exécution (visible uniquement avec `-L`) |

Un `*` à la fin d'un statut indique que la session est protégée et nécessite `--force` pour être arrêtée (par exemple `active*`, `running*`). La session principale est toujours protégée.

Lancer `claude-mux` dans un répertoire qui a déjà une session en cours s'y attache. Plusieurs terminaux peuvent s'attacher à la même session (comportement standard de tmux).

## Exemples de prompts Claude

Comme chaque session reçoit en injection les commandes claude-mux, vous pouvez gérer les sessions directement depuis les prompts de conversation, dans le terminal ou via l'application mobile :

```
Vous : « Quelles sessions sont en cours ? »
Claude : exécute `claude-mux -l` et affiche les résultats

Vous : « Affiche tous mes projets »
Claude : exécute `claude-mux -L` et affiche les résultats

Vous : « Lance une session pour mon projet de travail api-server »
Claude : exécute `claude-mux -d ~/Claude/work/api-server --no-attach`

Vous : « Crée un nouveau projet personnel appelé mobile-app »
Claude : exécute `claude-mux -n ~/Claude/personal/mobile-app -p --no-attach`

Vous : « Quels modèles est-ce que j'ai ? »
Claude : exécute `claude-mux --list-templates` et affiche les résultats

Vous : « Crée un nouveau projet de travail appelé api-server avec le modèle web »
Claude : exécute `claude-mux -n ~/Claude/work/api-server -p --template web --no-attach`

Vous : « Bascule toutes les sessions sur Sonnet »
Claude : exécute `claude-mux -s SESSION '/model sonnet'` pour chaque session en cours

Vous : « Arrête la session data-pipeline »
Claude : exécute `claude-mux --shutdown data-pipeline`

Vous : « Redémarre la session web-dashboard bloquée »
Claude : exécute `claude-mux --restart web-dashboard`

Vous : « Bascule la session api-server en mode plan »
Claude : exécute `claude-mux --permission-mode plan api-server`

Vous : « Passe la session data-pipeline en yolo »
Claude : exécute `claude-mux --permission-mode dangerously-skip-permissions data-pipeline`

Vous : « Lance la session data-pipeline en arrière-plan »
Claude : exécute `claude-mux -d ~/Claude/work/data-pipeline --no-attach`

Vous : « Démarre tous mes projets »
Claude : exécute `claude-mux -a` (après confirmation : cela démarre tous les projets gérés)
```

## Configuration

Au premier lancement, `~/.claude-mux/config` est créé automatiquement avec tous les paramètres en commentaires. Modifiez-le pour surcharger les valeurs par défaut. Le script lui-même n'a jamais besoin d'être modifié directement.

| Variable | Valeur par défaut | Description |
|----------|-------------------|-------------|
| `BASE_DIR` | `$HOME/Claude` | Répertoire racine à scanner pour trouver les projets Claude (répertoires contenant `.claude/`) |
| `LOG_DIR` | `$HOME/Library/Logs` | Répertoire pour le fichier `claude-mux.log` |
| `DEFAULT_PERMISSION_MODE` | `auto` | Définit `permissions.defaultMode` de Claude dans chaque projet. Valeurs valides : `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`. Mettez `""` pour désactiver. |
| `ALLOW_CROSS_SESSION_CONTROL` | `false` | Quand `true`, les sessions Claude peuvent envoyer des slash commands à d'autres sessions. Utile pour l'orchestration multi-agent. |
| `TEMPLATES_DIR` | `$HOME/.claude-mux/templates` | Répertoire contenant les fichiers modèles CLAUDE.md |
| `DEFAULT_TEMPLATE` | `default.md` | Modèle par défaut appliqué aux nouveaux projets (`-n`). Mettez `""` pour désactiver. |
| `SLEEP_BETWEEN` | `5` | Secondes entre les lancements de session quand `-a` est utilisé. À augmenter si l'enregistrement RC échoue. |
| `HOME_SESSION_MODEL` | `""` | Modèle pour la session principale. Valeurs valides : `sonnet`, `haiku`, `opus`. Vide hérite de la valeur par défaut de Claude. |
| `LAUNCHAGENT_MODE` | `home` | Comportement du LaunchAgent à l'ouverture de session : `none` (ne rien faire) ou `home` (lance la session principale protégée). L'ancienne valeur `LAUNCHAGENT_ENABLED=true` est traitée comme `home`. |

**Options de session tmux** (toutes configurables, toutes activées par défaut) :

| Variable | Valeur par défaut | Description |
|----------|-------------------|-------------|
| `TMUX_MOUSE` | `true` | Prise en charge de la souris : défilement, sélection, redimensionnement de panneaux |
| `TMUX_HISTORY_LIMIT` | `50000` | Taille du buffer de défilement en lignes (la valeur par défaut de tmux est 2000) |
| `TMUX_CLIPBOARD` | `true` | Intégration du presse-papiers système via OSC 52 |
| `TMUX_DEFAULT_TERMINAL` | `tmux-256color` | Type de terminal pour un rendu correct des couleurs |
| `TMUX_EXTENDED_KEYS` | `true` | Séquences de touches étendues, dont Shift+Enter (nécessite tmux 3.2+) |
| `TMUX_ESCAPE_TIME` | `10` | Délai de la touche Échap en millisecondes (la valeur par défaut de tmux est 500) |
| `TMUX_TITLE_FORMAT` | `#S` | Format du titre de terminal/onglet (`#S` = nom de session, `""` pour désactiver) |
| `TMUX_MONITOR_ACTIVITY` | `true` | Notifie quand une activité survient dans d'autres sessions |

## Structure des répertoires

Les projets sont découverts par la présence d'un répertoire `.claude/`, à n'importe quelle profondeur :

```
~/Claude/
├── work/
│   ├── project-a/          # ✓ a .claude/ - géré
│   │   └── .claude/
│   ├── project-b/          # ✓ a .claude/ - géré
│   │   └── .claude/
│   └── -archived/          # ✗ exclu (commence par -)
│       └── .claude/
├── personal/
│   ├── project-c/          # ✓ a .claude/ - géré
│   │   └── .claude/
│   ├── .hidden/            # ✗ exclu (répertoire caché)
│   │   └── .claude/
│   └── project-d/          # ✗ pas de .claude/ - n'est pas un projet Claude
├── deep/nested/project-e/  # ✓ a .claude/ - trouvé à n'importe quelle profondeur
│   └── .claude/
└── ignored-project/        # ✗ exclu (.ignore-claudemux)
    ├── .claude/
    └── .ignore-claudemux
```

Les noms de session sont dérivés des noms de répertoire : les espaces deviennent des tirets, les caractères non alphanumériques (sauf les tirets) sont remplacés, et les tirets en début/fin sont supprimés. Les répertoires dont le nom assaini est vide sont ignorés avec un avertissement dans le log.

## System prompt de session

Chaque session Claude est lancée avec `--append-system-prompt` contenant le contexte de son environnement :

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

Quand `ALLOW_CROSS_SESSION_CONTROL=true`, la commande d'envoi change pour permettre de cibler n'importe quelle session, pas seulement elle-même. Le chemin est le chemin absolu vers le script au moment du lancement, donc les sessions ne dépendent pas de `PATH`.

## Dépannage

### Les sessions affichent « Not logged in · Run /login »

Cela arrive au premier lancement si le keychain de macOS est verrouillé (fréquent quand le script tourne avant que le keychain soit déverrouillé après l'ouverture de session). Solution :

```bash
# Déverrouiller le keychain dans un terminal classique
security unlock-keychain

# Puis terminer l'authentification dans n'importe quelle session en cours
claude-mux -t <any-session>
# Lancer /login et compléter le flux dans le navigateur
```

Une fois l'authentification faite, tuez et relancez toutes les sessions : elles récupéreront automatiquement les identifiants stockés.

### Sessions absentes de Claude Code Remote

Les sessions doivent être authentifiées (ne pas afficher « Not logged in »). Après un lancement propre et authentifié, elles devraient apparaître dans la liste RC en quelques secondes.

### Saisie multiligne dans tmux

La commande `/terminal-setup` ne peut pas tourner dans tmux. claude-mux active les `extended-keys` de tmux par défaut (`TMUX_EXTENDED_KEYS=true`), ce qui prend en charge Shift+Enter dans la plupart des terminaux modernes. Si Shift+Enter ne fonctionne pas, utilisez `\` + Entrée pour insérer des sauts de ligne dans votre prompt.

### Slash commands via Remote Control

Les slash commands (par exemple `/model`, `/clear`) [ne sont pas prises en charge nativement](https://github.com/anthropics/claude-code/issues/30674) dans les sessions RC. claude-mux contourne ce problème : chaque session reçoit l'injection de `claude-mux -s` afin que Claude puisse s'envoyer des slash commands à elle-même via tmux.

## Logs

- `~/Library/Logs/claude-mux.log` : toutes les actions du script avec horodatage UTC (configurable via `LOG_DIR`)

Pour le débogage bas niveau du LaunchAgent, utilisez Console.app ou `log show`.
