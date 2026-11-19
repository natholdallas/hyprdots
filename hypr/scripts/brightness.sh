#!/usr/bin/env bash
# Screen brightness via brightnessctl.
#
# Usage: brightness.sh up|down
#
# -n2 = minimum value 2 (never black out the screen)
# -e4 = exponential curve, which feels linear to the eye
# set 5%+ / 5%- is a relative step, so no `grep` parsing is needed at all.

set -euo pipefail

step() {
    brightnessctl -q -n2 -e4 set "$1"
}

percent() {
    brightnessctl -m | awk -F, '{ gsub(/%/, "", $4); printf "%d", $4 }'
}

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -a "brightness" -h "string:x-canonical-private-synchronous:brightness" -t 1200 "$1"
    fi
}

case "${1:-}" in
    up)
        step "5%+"
        notify "Brightness $(percent)%"
        ;;
    down)
        step "5%-"
        notify "Brightness $(percent)%"
        ;;
    *)
        echo "usage: ${0##*/} up|down" >&2
        exit 2
        ;;
esac
