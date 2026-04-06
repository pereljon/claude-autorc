# Claude Sessions Startup: Implementation Spec

## Overview

A shell script and macOS LaunchAgent that automatically creates persistent tmux sessions running Claude Code with Remote Control for each project directory under `~/Claude/`.

## Directory Structure (Expected)

```
~/Claude/
├── work/
│   ├── CLAUDE.md
│   ├── .claude/
│   ├── project-a/
│   ├── project-b/
│   └── -archived-thing/    ← excluded (starts with -)
└── personal/
    ├── CLAUDE.md
    ├── .claude/
    ├── project-c/
    └── project-d/
```

## Deliverables

1. `~/Claude/start-claude-sessions.sh` — main script
2. `~/Library/LaunchAgents/com.user.claude-sessions.plist` — triggers script at user login

## Script: start-claude-sessions.sh

### Requirements

- Bash (system `/bin/bash` is fine)
- `tmux` from Homebrew at `/opt/homebrew/bin/tmux`
- `claude` from Homebrew at `/opt/homebrew/bin/claude`
- Must be re-runnable: safe to execute multiple times, only creates sessions that don't already exist
- Must support a `--dry-run` flag that prints what it would do without executing

### Environment

- PATH must include `/opt/homebrew/bin`
- HOME is inherited from the login session via LaunchAgent
- Apple Silicon Mac (arm64)

### Configuration

At the top of the script, the following settings control optional per-project setup:

```bash
# When true, create a .gitignore with common development exclusions
# if one does not already exist in the project directory
AUTO_GITIGNORE=true

# When set to a valid mode, create/update .claude/settings.local.json
# to set permissions.defaultMode for the project.
# Valid values: "" (disabled), "default", "acceptEdits", "plan", "auto", "dontAsk", "bypassPermissions"
DEFAULT_PERMISSION_MODE="auto"
```

#### AUTO_GITIGNORE

When enabled, the script checks each project directory for a `.gitignore`. If none exists, it creates one with common development exclusions:

```
# Secrets and credentials
.env
.env.*
!.env.example
*.pem
*.key
*.p12
*.pfx
tokens.json
credentials.json
secrets.yaml
secrets.yml

# Claude
.claude/settings.local.json

# OS
.DS_Store
Thumbs.db

# IDE
.idea/
.vscode/
*.swp
*.swo

# Dependencies
node_modules/
vendor/
__pycache__/
*.pyc
venv/
.venv/

# Build
dist/
build/
*.o
*.so
*.dylib
```

If a `.gitignore` already exists, it is left untouched.

#### DEFAULT_PERMISSION_MODE

When set to a non-empty value, the script ensures `.claude/settings.local.json` exists in the project directory with `permissions.defaultMode` set to the configured value. If the file already exists, it merges the setting (preserving other keys). If the file does not exist, it creates the directory and file.

### Logic (Pseudocode)

```
BASE_DIR="$HOME/Claude"
CATEGORIES=("work" "personal")
SLEEP_BETWEEN=5  # seconds between claude launches
LOG_FILE="$BASE_DIR/startup.log"

log(message):
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $message" >> $LOG_FILE

for each CATEGORY in CATEGORIES:
    CATEGORY_DIR="$BASE_DIR/$CATEGORY"

    if CATEGORY_DIR does not exist:
        log "WARN: $CATEGORY_DIR not found, skipping"
        continue

    # Ensure git repo exists (bypasses trust prompt)
    ensure_git_repo(CATEGORY_DIR)

    # Create tmux session for category top-level
    create_claude_session(CATEGORY, CATEGORY_DIR)

    # Iterate subdirectories
    for each SUBDIR in CATEGORY_DIR/*/:
        dir_name = basename(SUBDIR)

        # Skip hidden dirs, .claude dir, dirs starting with -
        if dir_name starts with "." OR dir_name starts with "-":
            continue

        ensure_git_repo(SUBDIR)
        setup_gitignore(SUBDIR)
        setup_default_mode(SUBDIR)
        create_claude_session(dir_name, SUBDIR)

        sleep $SLEEP_BETWEEN
    done
done

setup_gitignore(dir):
    if not AUTO_GITIGNORE:
        return
    if exists "$dir/.gitignore":
        log "Gitignore already exists in $dir, skipping"
        return
    log "Creating .gitignore in $dir"
    if not DRY_RUN:
        write default gitignore template to "$dir/.gitignore"

setup_default_mode(dir):
    if DEFAULT_PERMISSION_MODE is empty:
        return
    settings_file="$dir/.claude/settings.local.json"
    log "Setting defaultMode=$DEFAULT_PERMISSION_MODE in $dir"
    if not DRY_RUN:
        mkdir -p "$dir/.claude"
        if exists "$settings_file":
            # merge defaultMode into existing JSON (use python or jq)
            merge permissions.defaultMode into settings_file
        else:
            write {"permissions":{"defaultMode":"$DEFAULT_PERMISSION_MODE"}} to settings_file

ensure_git_repo(dir):
    if not exists "$dir/.git":
        log "Initializing git repo in $dir"
        if not DRY_RUN:
            git init "$dir"

create_claude_session(session_name, working_dir):
    if tmux has-session -t "$session_name" 2>/dev/null:
        log "Session '$session_name' already exists, skipping"
        return

    log "Creating tmux session '$session_name' in $working_dir"

    if DRY_RUN:
        return

    tmux new-session -d -s "$session_name" -c "$working_dir"

    # Build system prompt with tmux session awareness
    TMUX_PROMPT="You are running inside tmux session '$session_name'. You can send slash commands to yourself or any other Claude session via: /opt/homebrew/bin/tmux send-keys -t <session-name> \"/command args\" Enter. To list all sessions: /opt/homebrew/bin/tmux list-sessions. To find your own session name: /opt/homebrew/bin/tmux display-message -p '#S'."

    # Attempt continue, fall back to new session
    # Send command to the tmux pane; claude -c will either
    # continue the last session or fail with exit message.
    # Use a wrapper that tries -c first, then falls back.
    tmux send-keys -t "$session_name" \
        "claude -c --rc --name '$session_name' --append-system-prompt '$TMUX_PROMPT' 2>/dev/null || claude --rc --name '$session_name' --append-system-prompt '$TMUX_PROMPT'" \
        Enter

    sleep $SLEEP_BETWEEN
```

### Fallback Behavior for claude -c

`claude -c` fails with "No conversation found to continue" and a non-zero exit code when no prior session exists in a directory. The script pipes this through `||` to fall back to `claude --rc --name <name>` which starts a fresh session.

The command is sent to the tmux pane via `send-keys`, so both commands execute within the tmux session's shell, not the script's shell. The `2>/dev/null` suppresses the error message from the failed `-c` attempt.

### --dry-run Flag

When `--dry-run` is passed as the first argument:

- Print every action that would be taken (git init, tmux session creation, claude command)
- Do not execute any of them
- Still log to stdout (not to file)

### Exclusion Rules

Skip any subdirectory where the directory name:

- Starts with `.` (hidden directories, includes `.claude`)
- Starts with `-` (user convention for excluded/archived folders)

### Logging

All output appended to `~/Claude/startup.log` with UTC timestamps in ISO 8601 format. One log entry per action (skip, create, git init, error).

## LaunchAgent: com.user.claude-sessions.plist

### Configuration

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.claude-sessions</string>

    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>~/Claude/start-claude-sessions.sh</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
    </dict>

    <key>StandardOutPath</key>
    <string>~/Claude/launchagent-stdout.log</string>

    <key>StandardErrorPath</key>
    <string>~/Claude/launchagent-stderr.log</string>
</dict>
</plist>
```

### Notes

- The plist uses `RunAtLoad` to execute at user login.
- The script itself contains a startup delay (`sleep 45` at the top) to allow networking and Homebrew services to initialize after login.
- `~` in plist paths: launchd expands `~` in `StandardOutPath`/`StandardErrorPath` but NOT in `ProgramArguments`. The script path in `ProgramArguments` must either use the full expanded path or the script must handle this. Implementation should use `$HOME` expansion in the bash script and a fully qualified path in the plist. The Claude Code implementer should resolve this: either hardcode the expanded `$HOME` path or use a wrapper approach.
- LaunchAgent runs in the user's login session, inheriting `$USER` and `$HOME`.

## Edge Cases

| Case | Handling |
|------|----------|
| No prior Claude session in directory | `claude -c` fails, `||` falls back to `claude --rc --name <name>` |
| Directory has no `.git` | Script runs `git init` before launching Claude (bypasses trust prompt) |
| tmux session already exists | Skip, log, continue to next |
| Category directory missing | Log warning, skip to next category |
| No subdirectories in a category | Only the category-level session is created |
| Folder name starts with `-` | Excluded |
| Folder name starts with `.` | Excluded (covers `.claude` and hidden dirs) |
| Script re-run after adding new project folder | Creates session for new folder, skips existing sessions |
| tmux not installed | Script should check for tmux/claude in PATH at startup and exit with error if missing |

## Testing Instructions

### Phase 1: Dry Run

```bash
chmod +x ~/Claude/start-claude-sessions.sh
~/Claude/start-claude-sessions.sh --dry-run
```

Verify printed output lists correct directories, session names, and git init targets.

### Phase 2: Single Session

Comment out the loop. Test with one project directory:

- Verify tmux session is created with correct name
- Verify Claude starts with Remote Control enabled
- Verify session appears in claude.ai/code
- Verify re-running the script skips the existing session

### Phase 3: Full Run

```bash
~/Claude/start-claude-sessions.sh
tmux list-sessions
```

Verify all expected sessions exist. Connect to each via `tmux attach -t <name>` and confirm Claude is running.

### Phase 4: LaunchAgent

```bash
# Install
cp com.user.claude-sessions.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.user.claude-sessions.plist

# Verify
launchctl list | grep claude-sessions

# Check logs
cat ~/Claude/launchagent-stdout.log
cat ~/Claude/startup.log

# Unload for debugging
launchctl unload ~/Library/LaunchAgents/com.user.claude-sessions.plist
```

### Phase 5: Reboot Test

Restart the Mac. After login, wait 60 seconds, then verify:

```bash
tmux list-sessions
```

All sessions should be present. Check `~/Claude/startup.log` for any errors.

## Open Items for Implementer

1. **Resolve plist path expansion**: `~` does not expand in `ProgramArguments`. Use either `$HOME` substitution during install or a fixed path like `/Users/<username>/Claude/start-claude-sessions.sh`. The install step can detect and substitute.
2. **Verify `claude -c` exit code**: Confirm that `claude -c` with no prior session returns a non-zero exit code (not just a message to stdout). If it exits 0 with an error message, the `||` fallback won't trigger and the approach needs adjustment (e.g., check stderr or use a temp file).
3. **tmux send-keys fallback**: Since the `claude -c || claude` command runs inside the tmux pane's shell, verify that the `||` operator works as expected when sent via `tmux send-keys`. If `claude -c` launches an interactive TUI that doesn't exit cleanly on failure, the fallback may not execute. Test this scenario explicitly.
4. **Rate limiting**: Multiple simultaneous RC registrations may hit API rate limits. The 5-second sleep between launches mitigates this, but adjust if errors appear in logs.
