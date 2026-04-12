# claude-mux — Claude Code Multiplexer

Persistent Claude Code sessions for all your projects — accessible from anywhere via the Claude mobile app.

A shell script and macOS LaunchAgent that keeps a Claude Code session running for every project directory under `~/Claude/` (configurable via `BASE_DIR`). Persistent sessions mean Remote Control is always available — giving you access to all your projects from the Claude mobile app, wherever you are.

## What It Does

On login (or manual run), the script:

1. Finds all Claude projects under `~/Claude/` — any directory containing a `.claude/` subdirectory, at any depth
2. Skips directories starting with `-`, hidden directories, and directories containing `.ignore-claudemux`
3. Migrates any Claude Code processes already running outside tmux — SIGTERMs them so they resume cleanly inside tmux via `claude -c`
4. Creates a persistent tmux session per project with Claude Code running, with Remote Control enabled (if you've enabled RC globally via `/config`, the flag is redundant but harmless)
5. Attempts to resume the last conversation (`claude -c`), falling back to a fresh start

Each Claude session is injected with its tmux session name (so it can send slash commands like `/model` and `/compact` to itself), and any GitHub SSH accounts found in `~/.ssh/config` (so it knows which accounts are available for git operations).

You can also launch a single Claude session in any directory with `claude-mux -d DIRECTORY`, or create a new project with `claude-mux -n DIRECTORY` (which initializes git, creates a `.gitignore`, sets permission mode, and launches Claude).

## Requirements

- macOS (Apple Silicon)
- [tmux](https://github.com/tmux/tmux) — `brew install tmux`
- [Claude Code](https://claude.ai/code) — `brew install claude`

## Install

```bash
./install.sh
```

This installs `claude-mux` to the first writable bin directory in your `PATH`, creates `~/.claude-mux-rc` with your settings, and installs the LaunchAgent so sessions start automatically at login.

Options:

```bash
./install.sh --base-dir ~/work/claude              # use a different base directory
./install.sh --bin-dir ~/.local/bin                # specify bin directory explicitly
./install.sh --permission-mode acceptEdits         # set default Claude permission mode
./install.sh --cross-session-control               # enable multi-agent session control
./install.sh --no-launchagent                      # skip LaunchAgent installation
```

The LaunchAgent runs the script at login with a 45-second startup delay to allow system services to initialize.

## Usage

```bash
claude-mux                       # start all managed sessions under BASE_DIR
claude-mux ~/projects             # use ~/projects as the base dir instead
claude-mux -d ~/projects/my-app  # launch single session in a directory and attach
claude-mux -n ~/projects/app     # create a new Claude project in existing dir and attach
claude-mux -n ~/new/path/app -p  # same, but create the directory and parents first
claude-mux -t my-app             # attach to an existing tmux session
claude-mux -l                    # list managed sessions and their status
claude-mux --shutdown            # gracefully exit all managed Claude sessions
claude-mux --shutdown my-app     # shut down a specific session
claude-mux --restart             # shutdown then restart all managed sessions
claude-mux --dry-run             # preview actions without executing
claude-mux --version             # print version
claude-mux --help                # show all options

# Watch the log
tail -f ~/Library/Logs/claude-mux.log
```

When run from the terminal, output is mirrored to stdout in real time. When run via LaunchAgent, output goes to the log file only.

## Configuration

On first run, `~/.claude-mux-rc` is created automatically with all settings commented out. Edit it to override any defaults — the script never needs to be modified directly.

| Variable | Default | Description |
|----------|---------|-------------|
| `BASE_DIR` | `$HOME/Claude` | Root directory to scan for Claude projects (directories containing `.claude/`) |
| `LOG_DIR` | `$HOME/Library/Logs` | Directory for the `claude-mux.log` file |
| `DEFAULT_PERMISSION_MODE` | `auto` | Set Claude's `permissions.defaultMode` in each project. Valid: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`. Set to `""` to disable. |
| `ALLOW_CROSS_SESSION_CONTROL` | `false` | When `true`, Claude sessions can send slash commands to other sessions via tmux — useful for multi-agent orchestration. When `false`, sessions can only command themselves. |
| `SLEEP_BETWEEN` | `5` | Seconds to wait between launching each session. Increase if sessions fail to register with Remote Control. |

## Directory Structure

Projects are discovered by the presence of a `.claude/` directory, at any depth:

```
~/Claude/
├── work/
│   ├── project-a/          # ✓ has .claude/ — managed
│   │   └── .claude/
│   ├── project-b/          # ✓ has .claude/ — managed
│   │   └── .claude/
│   └── -archived/          # ✗ excluded (starts with -)
│       └── .claude/
├── personal/
│   ├── project-c/          # ✓ has .claude/ — managed
│   │   └── .claude/
│   ├── .hidden/            # ✗ excluded (hidden directory)
│   │   └── .claude/
│   └── project-d/          # ✗ no .claude/ — not a Claude project
├── deep/nested/project-e/  # ✓ has .claude/ — found at any depth
│   └── .claude/
└── ignored-project/        # ✗ excluded (.ignore-claudemux)
    ├── .claude/
    └── .ignore-claudemux
```

Session names are derived from directory names: spaces become hyphens, non-alphanumeric characters (except hyphens) are replaced, and leading/trailing hyphens are stripped. Directories whose name sanitizes to empty are skipped with a log warning.

## Session System Prompt

Each Claude session is launched with `--append-system-prompt` containing context about its environment. This is fully transparent — here is what gets injected:

```
You are running inside tmux session '<session-name>'.
You can send slash commands to yourself via: /path/to/claude-mux -s '<session-name>' '/command args'.
Other claude-mux commands:
  /path/to/claude-mux -l                    (list sessions)
  /path/to/claude-mux -t SESSION            (attach to session)
  /path/to/claude-mux -d DIRECTORY          (launch session in directory)
  /path/to/claude-mux -n DIRECTORY          (create new project)
  /path/to/claude-mux -n DIRECTORY -p       (create new project with parents)
  /path/to/claude-mux --shutdown SESSION    (shut down a session)
  /path/to/claude-mux --restart SESSION     (restart a session)
GitHub SSH accounts configured in ~/.ssh/config: <accounts>.
```

When `ALLOW_CROSS_SESSION_CONTROL=true`, the send command description changes to allow targeting any session, not just itself.

The `/path/to/claude-mux` is the absolute path to the script at launch time, so sessions don't depend on `PATH` being set correctly.

## Troubleshooting

### Sessions show "Not logged in · Run /login"

This happens on first launch if the macOS keychain is locked (common when the script runs before the keychain is unlocked after login). Fix:

```bash
# Unlock the keychain in a regular terminal
security unlock-keychain

# Then complete auth in any one running session
tmux attach -t <any-session>
# Run /login and complete the browser flow
```

After completing auth once, kill and relaunch all sessions — they'll pick up the stored credential automatically.

### Sessions not appearing in Claude Code Remote

Sessions must be authenticated (not showing "Not logged in"). After a clean authenticated launch they should appear in the RC list within a few seconds.

### Slash commands not available over Remote Control

Most slash commands (e.g. `/model`, `/clear`) are not currently supported in RC sessions. This is a [known open issue](https://github.com/anthropics/claude-code/issues/30674).

## Logs

- `~/Library/Logs/claude-mux.log` — all script actions with UTC timestamps (configurable via `LOG_DIR`)

For low-level LaunchAgent debugging, use Console.app or `log show`.
