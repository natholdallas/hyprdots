if [[ -f "/etc/xdg/menus/plasma-applications.menu" ]]; then
  XDG_MENU_PREFIX=plasma- kbuildsycoca6
elif [[ -f "/etc/xdg/menus/arch-applications.menu" ]]; then
  XDG_MENU_PREFIX=arch- kbuildsycoca6
fi
