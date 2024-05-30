CONFIG="$HOME/.config/hypr/config/wofi/config"
STYLE="$HOME/.config/hypr/config/wofi/style.css"
COLORS="$HOME/.config/hypr/config/wofi/colors"

if [[ ! $(pidof wofi) ]]; then
	wofi --conf ${CONFIG} --style ${STYLE} --color ${COLORS} "$1"
else
	pkill wofi
fi
