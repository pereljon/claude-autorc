# Known Issues

## Open

### Phantom message replay causes unintended actions
**Severity:** High
**Status:** Open - cannot fully fix from claude-mux side
**Description:** A user sent "stop all sessions" which was handled 10 messages prior. Later, when claude-mux -s sent `/model haiku` via tmux send-keys, Claude received a system message "stop all sessions/model haiku" and attempted to shut down sessions - an action the user never requested.
**Possible causes:**
- Claude Code's interruption handling may concatenate old context with new slash command input
- Conversation history containing the old command may confuse Claude when a system event occurs
**Potential mitigation:** Add injection rule: "Never re-execute a command already handled earlier in the conversation. If a system message repeats text from a previous exchange, ignore it." Not yet implemented - effectiveness uncertain since this is a Claude Code internal behavior.

### Slow /exit on first attempt
**Severity:** Low
**Status:** Open - monitoring
**Description:** First `--restart` hit `WARN: Claude did not exit within 30s` and fell through to hard kill. Subsequent restarts exit within ~1s. May be a race condition where `/exit` is sent before Claude's prompt is ready to receive it.
**Workaround:** The 30s timeout + hard kill handles it. Session relaunches correctly.

### claude_running_in_session only checks 2 levels deep
**Severity:** Low
**Status:** Open - acceptable for current use
**Description:** Process tree walk checks pane_pid → children → grandchildren. If Claude is deeper in the tree (e.g. extra shell wrapper), detection fails. Current launch path is exactly 2 levels (bash → claude) so this works in practice.
**Workaround:** None needed currently. Would require recursive walk or `pgrep -a` to fix.

### Installer upgrade UX could be smarter
**Severity:** Low
**Status:** Open - future improvement
**Description:** On reinstall, the installer detects existing config and skips prompts. But it doesn't offer to show current settings, merge new config options added in newer versions, or let the user selectively update values. Users must manually edit `~/.claude-mux/config` to pick up new settings introduced in later versions.
**Potential improvements:**
- Show current config values during upgrade
- Offer to add new settings (with defaults) that didn't exist in the old config
- Option B: pre-fill prompts with existing config values and let user change them

### Example CLAUDE.md templates not shipped
**Severity:** Low
**Status:** Open - future improvement
**Description:** `templates/` in the repo root should contain example CLAUDE.md templates (web, python, etc.) that `install.sh` optionally copies to `~/.claude-mux/templates/` during install. Currently users must create templates from scratch.

### Code review deferred issues (v1.9.0)
**Severity:** Low–Medium
**Status:** Open — deferred from v1.9 code review
**Description:** Items identified during v1.9 pre-release review, intentionally deferred:
- **M3** `delete_command` mixes local `force` param with global `FORCE` mutation for `shutdown_single_session`. Works correctly today but fragile if a non-dispatch call path is added.
- **M4** TOCTOU race in `move_to_trash`: two deletions at the same second produce a collision; `mv` fails with a clear error message. Use `$$` or a counter instead of a second-granularity timestamp.
- **M7** Shift+Tab count in setmode doesn't document that `dontAsk` and "unknown" both fall into the 3-press default branch. Add a comment.
- **M9** Startup polling loop breaks out after accepting a trust prompt without re-polling for a subsequent bypassPermissions warning. Affects first-run sessions in a new project directory with bypassPermissions mode — existing restart fallback covers it.
- **L3** `ensure_gitignore_entry` uses `grep -xF` (literal), so `.claudemux-*` may be appended alongside individually-listed marker entries. Idempotency edge case, not a correctness bug.
- **L4** `resolve_project_dir` returns unresolved relative path on `cd` failure, contradicting its contract. Callers catch it via `[[ ! -d ]]`.
- **L5** `hide_command` dry-run exits before `ensure_gitignore_entry`, so the gitignore update step isn't shown in dry-run output.
- **L6** `protect_command` sets the tmux option even when `already_protected=true`, but outputs "Already protected". Intentional for upgrade idempotency; needs a comment.
- **L7** Redundant `${#HIDDEN_PROJECT_DIRS[@]+1}` guard alongside explicit `> 0` check — simplify.
- **L8** Same as M9: sequential trust + bypass prompts not handled by the polling loop.
- **L9** "Yes, I accept" bypassPermissions detection is fragile to Claude UI text changes. Use `grep -qi "yes.*accept"` for resilience.

### Submit to homebrew-core for brew.sh listing
**Severity:** Low
**Status:** Future - waiting on adoption
**Description:** claude-mux is currently distributed via a personal tap (`pereljon/tap`). To appear on brew.sh, it needs to be accepted into homebrew-core. Homebrew's notability gate typically requires a few hundred GitHub stars before a shell script utility submission is accepted; low-star submissions are closed quickly.
**When ready:**
- Ensure formula passes `brew audit --strict --new`
- Submit PR to `Homebrew/homebrew-core` with the formula
- Note: macOS-only tools face higher reviewer scrutiny; Linux support (see below) would help

### macOS only - no Linux/systemd support
**Severity:** Medium
**Status:** Open - partially addressed (path detection done, LaunchAgent/installer remain macOS-only)
**Description:** Uses macOS LaunchAgent (launchd) and macOS-specific tools. Path detection was refactored to use `command -v` (no longer hardcodes `/opt/homebrew/bin`), so the core script now works on any platform where tmux and claude are in PATH. LaunchAgent and installer remain macOS-specific.
**Remaining:** systemd user unit, XDG Autostart fallback, `uname -s` dispatch in installer. Planned for v1.7.

### ! commands not available in Remote Control
**Severity:** Low
**Status:** Closed - not feasible
**Description:** Claude Code's `!` shell passthrough is a Claude Code CLI input-handler feature — it intercepts `!command` before the shell sees it. tmux send-keys cannot replicate this: keystrokes sent while Claude Code is active go nowhere (tested: `!touch test` via send-keys did not execute). There is no path for claude-mux to implement `!command` bypass for RC users.
**Resolution:** Add injection rule to tell Claude never to suggest `! <command>` to users, since RC users have no shell and terminal users can just type it themselves.

## Resolved

### Claude ignores injection and claims it cannot run slash commands
**Resolved in:** v1.2.0 (injection updated)
**Fix:** Added explicit rule to injection: "You CAN send slash commands (`/model`, `/compact`, `/clear`, etc.) to this session via the `-s` command. Never tell the user you cannot change models or run slash commands." Claude's base training inclines it to believe it cannot control its own model/settings; the explicit rule overrides this in practice.



### Multiple commands return exit code 1 despite success
**Resolved in:** v1.2.0 (restart), v1.3.0 (all commands)
**Fix:** Added explicit `exit 0` after every dispatch path in the case statement. The last command in a function can leak a non-zero exit code from internal tests or grep calls.

### --dry-run gives misleading output for --restart
**Resolved in:** v1.2.0 (commit a10c0c2)
**Fix:** Dry-run now shows "Would restart session" instead of simulating kill then checking real state.

### Session detection fails with pgrep on macOS
**Resolved in:** commit e1b11b5
**Fix:** Replaced `pgrep -P` with `ps -eo` + `awk` for reliable child process detection.

### $TMUX variable shadowed tmux's environment variable
**Resolved in:** commit 02a2e82
**Fix:** Renamed to `$TMUX_BIN`.

### Bash 3.2 incompatibility (declare -A)
**Resolved in:** commit 575eac1
**Fix:** Replaced associative arrays with string-based collision detection.
