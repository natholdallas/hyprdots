#!/usr/bin/env bash
# Notification daemon launcher (mako).

set -euo pipefail

config="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/config/mako/config"

running() { pgrep -x mako >/dev/null 2>&1; }

if [[ "${1:-}" == "--toggle" ]]; then
    if running; then
        pkill -x mako
        exit 0
    fi
elif running; then
    exit 0
fi

setsid mako --config "$config" >/dev/null 2>&1 &
disown || true
