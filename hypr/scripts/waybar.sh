CONFIG="$HOME/.config/hypr/config/waybar/config.json"
STYLE="$HOME/.config/hypr/config/waybar/style.css"

if [[ ! $(pidof waybar) ]]; then
	waybar --config "${CONFIG}" --style "${STYLE}"
fi
