time=`date +%Y-%m-%d-%H-%M-%S`
dir="`xdg-user-dir PICTURES`/Screenshots"
file="Screenshot-${time}-${RANDOM}.png"

if [[ ! -d "$dir" ]]; then
	mkdir -p "$dir"
fi

if [[ "$1" == "-region" ]]; then
	hyprshot -m region -m active -o $dir -f $file
elif [[ "$1" == "-window" ]]; then
	hyprshot -m window -m active -o $dir -f $file
elif [[ "$1" == "-monitor" ]]; then
	hyprshot -m output -m active -o $dir -f $file
elif [[ "$1" == "-monitorclipboard" ]]; then
	hyprshot -m output -m active --clipboard-only
fi
