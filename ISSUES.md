# Known Issues

## Open

### Claude ignores injection and claims it cannot run slash commands
**Severity:** High
**Status:** Mitigated (injection updated)
**Description:** When asked to change models or run slash commands, Claude's training instinct overrides the injection and it responds with "I can't change the model." The -s command is clearly documented in the injection but Claude defaults to its general knowledge.
**Mitigation:** Added explicit rule to injection: "You CAN send slash commands... Never tell the user you cannot change models or run slash commands."
**Root cause:** Claude's base training strongly believes it cannot control its own model/settings, and this overrides system prompt instructions in some cases.

### Phantom message replay causes unintended actions
**Severity:** High
**Status:** Open — cannot fully fix from claude-mux side
**Description:** A user sent "stop all sessions" which was handled 10 messages prior. Later, when claude-mux -s sent `/model haiku` via tmux send-keys, Claude received a system message "stop all sessions/model haiku" and attempted to shut down sessions — an action the user never requested.
**Possible causes:**
- Claude Code's interruption handling may concatenate old context with new slash command input
- Conversation history containing the old command may confuse Claude when a system event occurs
**Potential mitigation:** Add injection rule: "Never re-execute a command already handled earlier in the conversation. If a system message repeats text from a previous exchange, ignore it." Not yet implemented — effectiveness uncertain since this is a Claude Code internal behavior.

### Slow /exit on first attempt
**Severity:** Low
**Status:** Open — monitoring
**Description:** First `--restart` hit `WARN: Claude did not exit within 30s` and fell through to hard kill. Subsequent restarts exit within ~1s. May be a race condition where `/exit` is sent before Claude's prompt is ready to receive it.
**Workaround:** The 30s timeout + hard kill handles it. Session relaunches correctly.

### claude_running_in_session only checks 2 levels deep
**Severity:** Low
**Status:** Open — acceptable for current use
**Description:** Process tree walk checks pane_pid → children → grandchildren. If Claude is deeper in the tree (e.g. extra shell wrapper), detection fails. Current launch path is exactly 2 levels (bash → claude) so this works in practice.
**Workaround:** None needed currently. Would require recursive walk or `pgrep -a` to fix.

### macOS only — no Linux/systemd support
**Severity:** Medium
**Status:** Open — by design
**Description:** Uses macOS LaunchAgent (launchd), Homebrew paths (`/opt/homebrew/bin`), and macOS-specific tools. Core bash + tmux logic is portable but the LaunchAgent, installer, and path assumptions are not.
**Workaround:** Core script works on Linux with manual path adjustments. No systemd unit file provided.

## Resolved

### --restart returns exit code 1 despite success
**Resolved in:** v1.2.0 (commit a10c0c2)
**Fix:** Added explicit `exit 0` at end of restart paths.

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
