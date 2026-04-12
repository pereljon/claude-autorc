# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**claude-mux** (Claude Code Multiplexer) — a shell script and macOS LaunchAgent that automatically creates and maintains persistent Claude Code sessions in tmux for every project directory under `~/Claude/`. Persistent sessions enable Claude Code Remote Control, giving full mobile app access to all projects via the Claude iOS/Android app.

### Deliverables

1. `claude-mux` — main script (Bash), installed to a bin directory in `$PATH`
2. `com.user.claude-mux.plist` — LaunchAgent plist, installed to `~/Library/LaunchAgents/`
3. `install.sh` — installer script
4. `claude-mux-rc` — example config file template

## Architecture

The startup script dynamically discovers category directories under `~/Claude/` (any subdir not starting with `.` or `-`), migrates stray Claude processes into tmux, optionally initializes git repos (disabled by default), and creates one tmux session per project with Claude running in RC mode. It attempts `claude -c` to resume a prior session, falling back to a fresh `claude --remote-control` on failure.

The LaunchAgent runs the script at login with a 45-second startup delay for system services to initialize.

### Key behaviors

- **Idempotent**: safe to re-run; skips sessions where claude is already running, relaunches where it has exited
- **Exclusion**: directories starting with `.` or `-` are skipped
- **Dynamic categories**: all top-level subdirs of `~/Claude/` (not starting with `.` or `-`) are treated as categories
- **Session migration**: SIGTERMs Claude processes running outside tmux in managed directories; `claude -c` resumes them in the new tmux session
- **Dry run**: `--dry-run` flag prints actions without executing (skips migration)
- **Logging**: all actions appended to `~/Library/Logs/claude-mux.log` (UTC ISO 8601, configurable via `LOG_DIR`)
- **Auto-gitignore**: optionally creates `.gitignore` with common dev exclusions (secrets, tokens, .env, IDE, build artifacts)
- **Default permission mode**: optionally sets Claude's `permissions.defaultMode` per project via `.claude/settings.local.json`
- **Tmux-aware sessions**: each session gets `--append-system-prompt` with its tmux session name, so Claude knows how to send slash commands (e.g. `/model`, `/compact`) to itself via `tmux send-keys` (cross-session control available when `ALLOW_CROSS_SESSION_CONTROL=true`)

## Dependencies

- macOS (Apple Silicon / arm64)
- `/opt/homebrew/bin/tmux`
- `/opt/homebrew/bin/claude`
- System `/bin/bash`

## Commands

```bash
# Install
./install.sh

# Usage
claude-mux                       # start all sessions
claude-mux DIRECTORY             # use DIRECTORY as base dir (scan its subdirs)
claude-mux -d DIRECTORY          # launch single session in directory and attach
claude-mux -t SESSION            # attach to a session
claude-mux -l                    # show session status
claude-mux --shutdown            # gracefully exit all Claude sessions
claude-mux --shutdown SESSION    # shut down a specific session
claude-mux --restart             # shutdown then restart all sessions
claude-mux --dry-run             # preview actions without executing

# Verify LaunchAgent
launchctl list | grep claude-mux

# Check logs
tail -f ~/Library/Logs/claude-mux.log

# LaunchAgent debug (stdout/stderr go to macOS unified log, not a file)
log show --predicate 'process == "launchd"' --last 5m | grep claude
```

## Development workflow

The script has two locations:
- **Repo**: `~/Claude/development/claude-code-sessions/claude-mux` (version-controlled)
- **Active**: `~/Claude/claude-mux` (what actually runs)

Always edit the repo copy first, then **ask before committing** — do not run `git commit` or `git push` without explicit approval. After committing, deploy to the active location:

```bash
# After editing and committing in the repo:
cp ~/Claude/development/claude-code-sessions/claude-mux ~/Claude/
```

The plist and `claude-mux-rc` follow the same pattern — edit in repo, copy to deploy.

## Configuration file

`~/.claude-mux-rc` is the user config (not in this repo). A documented template is at `claude-mux-rc`. Key variables:

- `BASE_DIR` — root directory (default: `~/Claude`)
- `LOG_DIR` — directory for `claude-mux.log` (default: `~/Library/Logs`)
- `AUTO_GIT_INIT` — run `git init` and create `.gitignore` in projects without a repo (default: `false`)
- `DEFAULT_PERMISSION_MODE` — Claude permission mode per project (default: `auto`)
- `ALLOW_CROSS_SESSION_CONTROL` — allow sessions to send commands to each other (default: `false`)

## Implementation spec

See `implentation-spec.md` for the full specification including pseudocode, edge cases, plist configuration, and open items for the implementer.
