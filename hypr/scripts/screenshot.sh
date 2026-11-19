#!/usr/bin/env bash
# Screenshots via hyprshot.
#
# Usage: screenshot.sh region|window|output|clipboard
#
# region    drag a selection
# window    the focused window
# output    the focused monitor (saved)
# clipboard the focused monitor, clipboard only

set -euo pipefail

pictures="$(xdg-user-dir PICTURES 2>/dev/null || true)"
if [[ -z "${pictures:-}" || "$pictures" == "$HOME" ]]; then
    pictures="$HOME/Pictures"
fi

dir="$pictures/Screenshots"
stamp="$(date +%Y-%m-%d-%H-%M-%S)"
file="Screenshot-${stamp}-${RANDOM}.png"

mkdir -p "$dir"

case "${1:-}" in
    region)
        hyprshot -m region -m active -z -o "$dir" -f "$file"
        ;;
    window)
        hyprshot -m window -m active -z -o "$dir" -f "$file"
        ;;
    output)
        hyprshot -m output -m active -o "$dir" -f "$file"
        ;;
    clipboard)
        hyprshot -m output -m active --clipboard-only
        ;;
    *)
        echo "usage: ${0##*/} region|window|output|clipboard" >&2
        exit 2
        ;;
esac
