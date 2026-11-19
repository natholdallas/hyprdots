#!/usr/bin/env bash
# Lock the session.
#
# Prefers logind so the lock is visible to systemd (suspend integration,
# hypridle's lock_cmd). Falls back to hyprlock when logind is unavailable.

set -euo pipefail

if command -v loginctl >/dev/null 2>&1 && loginctl lock-session 2>/dev/null; then
    exit 0
fi

exec hyprlock
