CONFIG="$HOME/.config/hypr/config/wofi/config"
STYLE="$HOME/.config/hypr/config/wofi/style.css"

if [[ ! $(pidof wofi) ]]; then
	wofi --conf "${CONFIG}" --style "${STYLE}" "$1"
else
	pkill wofi
fi
