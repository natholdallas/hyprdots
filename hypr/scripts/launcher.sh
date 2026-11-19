#!/usr/bin/env bash
# Launcher wrapper around fuzzel.
#
# Usage: launcher.sh [dmenu]
#
# No argument: application launcher.
# dmenu:       read stdin, print the chosen line to stdout (used by the
#              clipboard history bind). Never toggles in that mode, because
#              the caller is consuming stdout through a pipe.

set -euo pipefail

config="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/config/fuzzel/fuzzel.ini"

if [[ "${1:-}" == "dmenu" ]]; then
    exec fuzzel --config "$config" --dmenu
fi

# fuzzel exits when it loses focus, but pressing the bind twice should close it.
if pgrep -x fuzzel >/dev/null 2>&1; then
    pkill -x fuzzel
    exit 0
fi

exec fuzzel --config "$config"
