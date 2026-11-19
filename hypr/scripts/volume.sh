#!/usr/bin/env bash
# Volume control through PipeWire (wpctl).
#
# Usage: volume.sh up|down|mute|mic
#
# Replaces the old amixer script: this machine runs pipewire-pulse, and wpctl
# needs no fragile parsing of `amixer get` output.

set -euo pipefail

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -a "volume" -h "string:x-canonical-private-synchronous:volume" -t 1200 "$1"
    fi
}

sink_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{ printf "%d", ($2 * 100) + 0.5 }'
}

sink_muted() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED
}

case "${1:-}" in
    up)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
        wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
        notify "Volume $(sink_volume)%"
        ;;
    down)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        notify "Volume $(sink_volume)%"
        ;;
    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        if sink_muted; then
            notify "Muted"
        else
            notify "Volume $(sink_volume)%"
        fi
        ;;
    mic)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
            notify "Microphone muted"
        else
            notify "Microphone on"
        fi
        ;;
    *)
        echo "usage: ${0##*/} up|down|mute|mic" >&2
        exit 2
        ;;
esac
