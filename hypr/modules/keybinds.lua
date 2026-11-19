-- Keybindings.
--
-- This is a superset of the original keybindings.conf: every bind that existed
-- before is present here with the same combo, plus a few additions. App/script
-- variables live at the top so a command changes in one place.
--
-- NOTE: key names are case-insensitive, so a bind on "l" shadows "L". Anything
-- that differs only by letter case cannot coexist -- see the comments below.

local mod     = "SUPER"
local scripts = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/hypr/scripts"

local term     = "kitty"
local browser  = "google-chrome-stable"
local editor   = "neovide"
local files    = "yazi"
local pviewer  = "htop"
local monitor  = "nvtop"

local launcher = scripts .. "/launcher.sh"
local volume   = scripts .. "/volume.sh"
local bright   = scripts .. "/brightness.sh"
local shot     = scripts .. "/screenshot.sh"
local lock     = scripts .. "/lock.sh"
local bar      = scripts .. "/waybar.sh"

---------------------------
---- APPLICATIONS --------
---------------------------

hl.bind(mod .. " + Return", hl.dsp.exec_cmd(term),    { description = "terminal" })
hl.bind(mod .. " + B",      hl.dsp.exec_cmd(browser), { description = "browser" })
hl.bind(mod .. " + E",      hl.dsp.exec_cmd(term .. " " .. files), { description = "file manager" })
hl.bind(mod .. " + N",      hl.dsp.exec_cmd(editor),  { description = "editor" })

hl.bind("ALT + F2",         hl.dsp.exec_cmd(launcher), { description = "launcher" })
hl.bind(mod .. " + R",      hl.dsp.exec_cmd(launcher), { description = "launcher" })

hl.bind("CTRL + ALT + T",   hl.dsp.exec_cmd(term),     { description = "terminal" })
hl.bind("CTRL + SHIFT + escape", hl.dsp.exec_cmd(term .. " " .. pviewer), { description = "htop" })
hl.bind(mod .. " + Escape", hl.dsp.exec_cmd(term .. " " .. monitor), { description = "nvtop" })

-- Clipboard history through the launcher (dmenu mode).
hl.bind(mod .. " + V", hl.dsp.exec_cmd("cliphist list | " .. launcher .. " dmenu | cliphist decode | wl-copy"), { description = "clipboard history" })

---------------------------
---- WINDOW ACTIONS -------
---------------------------

hl.bind(mod .. " + Q",   hl.dsp.window.close(), { description = "close window" })
hl.bind("ALT + F4",      hl.dsp.window.close(), { description = "close window" })

hl.bind(mod .. " + F",      hl.dsp.window.fullscreen({ mode = 0 }), { description = "fullscreen" })
hl.bind("ALT + Return",     hl.dsp.window.fullscreen({ mode = 0 }), { description = "fullscreen" })

hl.bind(mod .. " + Space",  hl.dsp.window.float({ action = "toggle" }), { description = "toggle floating" })
hl.bind(mod .. " + J",      hl.dsp.layout("togglesplit"), { description = "toggle split" })
hl.bind(mod .. " + U",      hl.dsp.window.pseudo(),       { description = "pseudo tile" })
hl.bind(mod .. " + Tab",    hl.dsp.window.cycle_next(),   { description = "next window" })
hl.bind(mod .. " + grave",  hl.dsp.window.alter_zorder({ mode = "top" }), { description = "raise window" })

-- Mouse: drag and resize with Super held.
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mod .. " + Z",         hl.dsp.window.drag(),   { mouse = true, description = "drag window" })
hl.bind(mod .. " + X",         hl.dsp.window.resize(), { mouse = true, description = "resize window" })

-- Close the focused window (was: hyprctl dispatch killactive "")
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.kill(), { description = "kill window" })

---------------------------
---- SESSION --------------
---------------------------

hl.bind(mod .. " + L",      hl.dsp.exec_cmd(lock), { description = "lock screen" })
hl.bind(mod .. " + Delete", hl.dsp.exit(),         { description = "exit Hyprland" })
hl.bind("CTRL + ALT + W",   hl.dsp.exec_cmd(bar .. " --toggle"), { description = "toggle bar" })
hl.bind(mod .. " + Print",  hl.dsp.exec_cmd(scripts .. "/wallpaper.sh"), { description = "cycle wallpaper" })

-- Colour picker. This was Super+P in the old config; kept on the same key.
hl.bind(mod .. " + P",      hl.dsp.exec_cmd("hyprpicker -a"), { description = "pick colour" })

---------------------------
---- SCREENSHOTS ----------
---------------------------

hl.bind("Print",                hl.dsp.exec_cmd(shot .. " region"))
hl.bind("CTRL + Print",         hl.dsp.exec_cmd(shot .. " window"))
hl.bind("SHIFT + Print",        hl.dsp.exec_cmd(shot .. " output"))
hl.bind("CTRL + SHIFT + Print", hl.dsp.exec_cmd(shot .. " clipboard"))

---------------------------
---- FOCUS ----------------
---------------------------

hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- NOTE: vim-style `Super + hjkl` focus is not bound. Key names are
-- case-insensitive, so `Super + l` would shadow `Super + L` (lock) and
-- `Super + j` would shadow `Super + J` (toggle split).

---------------------------
---- MOVE / RESIZE --------
---------------------------

hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

hl.bind(mod .. " + CTRL + left",  hl.dsp.window.resize({ x = -20, y = 0, relative = true }))
hl.bind(mod .. " + CTRL + right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }))
hl.bind(mod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0, y = -20, relative = true }))
hl.bind(mod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0, y = 20, relative = true }))

-- Swap windows (was: not bound before, kept off "h/l" to avoid shadowing).
hl.bind(mod .. " + SHIFT + comma",  hl.dsp.window.swap({ direction = "left" }))
hl.bind(mod .. " + SHIFT + period", hl.dsp.window.swap({ direction = "right" }))

---------------------------
---- WORKSPACES -----------
---------------------------

for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Workspace cycling.
--
-- `e+1` / `e-1` walk outwards forever (11, 12, ...), which is not what the bar
-- shows and leaves orphan workspaces behind. Wrapping strictly inside 1..10
-- needs the current id at dispatch time, so this is a Lua function instead of a
-- static workspace selector. `hl.get_active_workspace()` returns nil very early
-- in startup, hence the fallback.
local LAST_WORKSPACE = 10

local function cycle_workspace(step)
    return function()
        local current = hl.get_active_workspace()
        local id = (current and current.id) or 1

        -- Special / negative workspaces have no place in the 1..10 ring.
        if id < 1 or id > LAST_WORKSPACE then
            id = 1
        end

        local target = ((id - 1 + step) % LAST_WORKSPACE) + 1
        hl.dispatch(hl.dsp.focus({ workspace = target }))
    end
end

hl.bind("ALT + bracketleft",  cycle_workspace(-1), { description = "previous workspace" })
hl.bind("ALT + bracketright", cycle_workspace(1),  { description = "next workspace" })

-- Mouse wheel on either modifier does the same thing. Super+wheel keeps the
-- outward behaviour it always had; Alt+wheel follows the 1..10 loop.
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind("ALT + mouse_down", cycle_workspace(1),  { mouse = true, description = "next workspace" })
hl.bind("ALT + mouse_up",   cycle_workspace(-1), { mouse = true, description = "previous workspace" })

-- Relative workspace switching (all four from the old config).
hl.bind("CTRL + ALT + Right", hl.dsp.focus({ workspace = "r+1" }))
hl.bind("CTRL + ALT + Left",  hl.dsp.focus({ workspace = "r-1" }))
hl.bind("CTRL + ALT + l",     hl.dsp.focus({ workspace = "r+1" }))
hl.bind("CTRL + ALT + h",     hl.dsp.focus({ workspace = "r-1" }))
hl.bind(mod .. " + code:35",  hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mod .. " + code:34",  hl.dsp.focus({ workspace = "r-1" }))

-- Move window to relative workspace.
hl.bind(mod .. " + CTRL + ALT + Right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mod .. " + CTRL + ALT + Left",  hl.dsp.window.move({ workspace = "r-1" }))

-- Scratchpad.
hl.bind(mod .. " + S",         hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratch" }))

---------------------------
---- MEDIA / HARDWARE -----
---------------------------

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(volume .. " up"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(volume .. " down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(volume .. " mute"), { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(volume .. " mic"),  { locked = true })

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(bright .. " up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(bright .. " down"), { locked = true, repeating = true })

hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

---------------------------
---- RESIZE SUBMAP --------
---------------------------

hl.define_submap("resize", "reset", function()
    hl.bind("left",   hl.dsp.window.resize({ x = -20, y = 0, relative = true }))
    hl.bind("right",  hl.dsp.window.resize({ x = 20, y = 0, relative = true }))
    hl.bind("up",     hl.dsp.window.resize({ x = 0, y = -20, relative = true }))
    hl.bind("down",   hl.dsp.window.resize({ x = 0, y = 20, relative = true }))
    hl.bind("escape", hl.dsp.submap("reset"))
end)
