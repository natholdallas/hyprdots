#!/usr/bin/env bash
# Waybar launcher.
#
# Usage: waybar.sh [--toggle] [bar-id]
#
# Without arguments: start the bar if it is not already running.
# With --toggle:     stop it if running, start it otherwise.

set -euo pipefail

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/config/waybar"
config="$config_dir/config.jsonc"
style="$config_dir/style.css"

toggle=0
bar=""
for arg in "$@"; do
    case "$arg" in
        --toggle|-t) toggle=1 ;;
        -*) echo "usage: ${0##*/} [--toggle] [bar-id]" >&2; exit 2 ;;
        *)  bar="$arg" ;;
    esac
done

running() { pgrep -x waybar >/dev/null 2>&1; }

if (( toggle )) && running; then
    pkill -x waybar
    exit 0
fi

running && exit 0

args=(--config "$config" --style "$style")
[[ -n "$bar" ]] && args+=(--bar "$bar")

# Detach so the caller (exec-once / a keybind) can return immediately and the
# bar keeps running after Hyprland's exec helper exits.
setsid waybar "${args[@]}" >/dev/null 2>&1 &
disown || true
