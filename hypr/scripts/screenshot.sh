time=`date +%Y-%m-%d-%H-%M-%S`
dir="`xdg-user-dir PICTURES`/Screenshots"
file="Screenshot-${time}-${RANDOM}.png"

if [[ ! -d "$dir" ]]; then
	mkdir -p "$dir"
fi

if [[ "$1" == "-region" ]]; then
	hyprshot -m region -c -o $dir -f $file
elif [[ "$1" == "-window" ]]; then
	hyprshot -m window -c -o $dir -f $file
elif [[ "$1" == "-monitor" ]]; then
	hyprshot -m output -c -o $dir -f $file
elif [[ "$1" == "-monitorclipboard" ]]; then
	hyprshot -m output -c --clipboard-only
fi

exit 0
