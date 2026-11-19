-- Session: autostart, idle handling and lock integration.
--
-- Everything that runs once when Hyprland comes up lives here, so
-- hyprland.lua stays a pure entry point. Processes are started through
-- hl.exec_cmd in the "hyprland.start" handler, which is the Lua equivalent of
-- the old `exec-once` lines.

local home    = os.getenv("HOME")
local config  = (os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")) .. "/hypr"
local scripts = config .. "/scripts"

hl.on("hyprland.start", function()
    -- Export the Wayland environment into systemd / dbus. Without this,
    -- portals, screensharing and notification daemons can end up without a
    -- valid WAYLAND_DISPLAY.
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP")

    -- Portals and authentication
    hl.exec_cmd("/usr/lib/xdg-desktop-portal-hyprland")
    hl.exec_cmd("hyprpolkitagent")

    -- Backgrounds and idle handling
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle -c " .. config .. "/config/hypridle/hypridle.conf")

    -- Input method
    hl.exec_cmd("fcitx5 -d")

    -- Clipboard history, text and images
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Shell
    hl.exec_cmd(scripts .. "/waybar.sh")
    hl.exec_cmd(scripts .. "/notifications.sh")
end)
