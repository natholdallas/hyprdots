# Get Volume
get_volume() {
	volume=`amixer get Master | tail -n1 | awk -F ' ' '{print $5}' | tr -d '[]'`
	echo "$volume"
}

# Notify
notify_user() {
	notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "Volume : $(get_volume)"
}

# Increase Volume
inc_volume() {
	amixer -Mq set Master,0 5%+ unmute && notify_user
}

# Decrease Volume
dec_volume() {
	amixer -Mq set Master,0 5%- unmute && notify_user
}

# Toggle Mute
toggle_mute() {
	amixer get Master | grep '\[on\]' &>/dev/null
	if [[ "$?" == 0 ]]; then
		amixer set Master toggle && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "Mute"
	else
		amixer set Master toggle && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "Unmute"
	fi
}

# Toggle Mic
toggle_mic() {
	amixer get Capture | grep '\[on\]' &>/dev/null
	if [[ "$?" == 0 ]]; then
		amixer -D pulse sset Capture toggle && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "Microphone Switched OFF"
	else
		amixer -D pulse sset Capture toggle && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "Microphone Switched ON"
	fi
}

# Execute accordingly
if [[ "$1" == "--get" ]]; then
	get_volume
elif [[ "$1" == "--inc" ]]; then
	inc_volume
elif [[ "$1" == "--dec" ]]; then
	dec_volume
elif [[ "$1" == "--toggle" ]]; then
	toggle_mute
elif [[ "$1" == "--toggle-mic" ]]; then
	toggle_mic
else
	get_volume
fi
