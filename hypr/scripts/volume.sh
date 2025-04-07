get_volume() {
	volume=$(amixer get Master | tail -n1 | awk -F ' ' '{print $5}' | tr -d '[]')
	echo "$volume"
}

case $1 in
i)
	amixer -Mq set Master,0 5%+ unmute
	;;
d)
	amixer -Mq set Master,0 5%- unmute
	;;
mute)
	amixer get Master | grep '\[on\]' &>/dev/null
	if [[ "$?" == 0 ]]; then
		amixer set Master toggle && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "Mute"
	else
		amixer set Master toggle && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "Unmute"
	fi
	;;
mic)
	amixer get Capture | grep '\[on\]' &>/dev/null
	if [[ "$?" == 0 ]]; then
		amixer -D pulse sset Capture toggle && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "Microphone Switched OFF"
	else
		amixer -D pulse sset Capture toggle && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "Microphone Switched ON"
	fi
	;;
esac
