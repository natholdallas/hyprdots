#!/usr/bin/env bash
# Rotate the wallpaper through every image in ~/.local/share/backgrounds.
#
# Usage: wallpaper.sh [next|prev]
#
# hyprpaper is controlled over its IPC socket. The wallpaper list is whatever
# `backgrounds` contains, so adding a file is enough to include it.

set -euo pipefail

dir="${XDG_DATA_HOME:-$HOME/.local/share}/backgrounds"
state="${XDG_RUNTIME_DIR:-/tmp}/hypr-wallpaper.idx"

[[ -d "$dir" ]] || { echo "no wallpaper directory: $dir" >&2; exit 1; }

mapfile -t walls < <(find "$dir" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | sort)
(( ${#walls[@]} )) || { echo "no wallpapers in $dir" >&2; exit 1; }

idx=0
[[ -f "$state" ]] && idx="$(cat "$state" 2>/dev/null || echo 0)"

case "${1:-next}" in
    next) idx=$(( (idx + 1) % ${#walls[@]} )) ;;
    prev) idx=$(( (idx - 1 + ${#walls[@]}) % ${#walls[@]} )) ;;
    *) echo "usage: ${0##*/} [next|prev]" >&2; exit 2 ;;
esac

echo "$idx" > "$state"
wall="${walls[$idx]}"

if ! pgrep -x hyprpaper >/dev/null 2>&1; then
    setsid hyprpaper >/dev/null 2>&1 &
    sleep 0.3
fi

hyprctl hyprpaper unload all >/dev/null
hyprctl hyprpaper preload "$wall" >/dev/null
hyprctl hyprpaper wallpaper ",$wall" >/dev/null
