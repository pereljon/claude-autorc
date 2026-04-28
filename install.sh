#!/bin/bash
# install.sh — claude-mux installer (binary placement + delegate to --install)

set -euo pipefail

if [[ "$(id -u)" -eq 0 ]]; then
    echo "ERROR: Do not run this installer as root or with sudo." >&2
    echo "claude-mux is a per-user tool — run as your normal user account." >&2
    exit 1
fi

# Check dependencies (warn, don't block — user may install them after)
if ! command -v tmux &>/dev/null; then
    echo "WARNING: tmux not found. Install with: brew install tmux" >&2
fi
if ! command -v claude &>/dev/null; then
    echo "WARNING: Claude Code CLI not found. Install with: brew install claude" >&2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR=""
INSTALL_ARGS=()

usage() {
    cat << EOF
install.sh — Install claude-mux

Usage: install.sh [OPTIONS]

Options:
  --bin-dir DIR             Directory to install claude-mux binary (default: ~/bin or ~/.local/bin)
  -h, --help                Show this help message

All other options (--base-dir, --launchagent-mode, --home-model, --no-launchagent,
--non-interactive, --permission-mode, --cross-session-control) are forwarded to
'claude-mux --install', which handles config and LaunchAgent setup.

Examples:
  ./install.sh
  ./install.sh --non-interactive
  ./install.sh --base-dir ~/work/claude --launchagent-mode none
  ./install.sh --no-launchagent
EOF
}

# ── Parse args ────────────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
    case "$1" in
        --bin-dir)
            [[ $# -lt 2 ]] && { echo "ERROR: --bin-dir requires a value" >&2; exit 1; }
            BIN_DIR="$2"; shift 2 ;;
        -h|--help)
            usage; exit 0 ;;
        *)
            # Forward everything else to claude-mux --install
            INSTALL_ARGS+=("$1"); shift ;;
    esac
done

# ── Find default bin dir ──────────────────────────────────────────────────────

find_bin_dir() {
    local candidates=("$HOME/bin" "$HOME/.local/bin")
    for dir in "${candidates[@]}"; do
        if [[ -d "$dir" && -w "$dir" ]]; then
            echo "$dir"; return
        fi
    done
    echo "$HOME/bin"
}

DEFAULT_BIN_DIR="$(find_bin_dir)"

if [[ -z "$BIN_DIR" ]]; then
    BIN_DIR="$DEFAULT_BIN_DIR"
fi

if [[ ! -d "$BIN_DIR" ]]; then
    echo "Creating $BIN_DIR..."
    mkdir -p "$BIN_DIR"
fi

if [[ ! -w "$BIN_DIR" ]]; then
    echo "ERROR: $BIN_DIR is not writable." >&2
    exit 1
fi

# ── Install binary ────────────────────────────────────────────────────────────

echo "Installing claude-mux to $BIN_DIR/claude-mux..."
cp "$SCRIPT_DIR/claude-mux" "$BIN_DIR/claude-mux"
chmod +x "$BIN_DIR/claude-mux"

# ── Add bin dir to PATH if needed ─────────────────────────────────────────────

PATH_UPDATED=""
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == */zsh ]]; then
        SHELL_PROFILE="$HOME/.zshrc"
    else
        SHELL_PROFILE="$HOME/.bashrc"
    fi

    if ! grep -q "# Added by claude-mux" "$SHELL_PROFILE" 2>/dev/null; then
        echo "Adding $BIN_DIR to PATH in $SHELL_PROFILE..."
        {
            printf '\n# Added by claude-mux\n'
            printf 'export PATH="$PATH:%s"\n' "$BIN_DIR"
            printf '# End of claude-mux section\n'
        } >> "$SHELL_PROFILE"
        PATH_UPDATED="$SHELL_PROFILE"
    fi
fi

# ── Delegate to claude-mux --install for config + LaunchAgent ─────────────────

echo ""
"$BIN_DIR/claude-mux" --install "${INSTALL_ARGS[@]+"${INSTALL_ARGS[@]}"}"

# ── Final PATH hint ───────────────────────────────────────────────────────────

if [[ -n "$PATH_UPDATED" ]]; then
    echo ""
    echo "┌──────────────────────────────────────────────────────────────────┐"
    echo "│  ACTION REQUIRED: Restart your terminal or run:                  │"
    echo "│                                                                  │"
    printf "│  %-64s│\n" "source $PATH_UPDATED"
    echo "│                                                                  │"
    echo "└──────────────────────────────────────────────────────────────────┘"
fi
