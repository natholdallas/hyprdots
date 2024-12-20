get_brightness() {
	brightnessctl -m | grep -o '[0-9]\+%' | head -c-2
}

case $1 in
i)
	if [[ $(get_brightness) -lt 10 ]]; then
		# increase the backlight by 1% if less than 10%
		brightnessctl set +1%
	else
		# increase the backlight by 5% otherwise
		brightnessctl set +5%
	fi
	;;
d)
	if [[ $(get_brightness) -le 1 ]]; then
		# avoid 0% brightness
		brightnessctl set 1%
	elif [[ $(get_brightness) -le 10 ]]; then
		# decrease the backlight by 1% if less than 10%
		brightnessctl set 1%-
	else
		# decrease the backlight by 5% otherwise
		brightnessctl set 5%-
	fi
	;;
esac
