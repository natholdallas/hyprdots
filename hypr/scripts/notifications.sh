CONFIG="$HOME/.config/hypr/config/mako/config"

if [[ ! `pidof mako` ]]; then
	mako --config ${CONFIG}
fi
