-- Hyprland 0.57+ Lua configuration
-- https://wiki.hypr.land/configuring/
--
-- The old hyprlang (.conf) format was removed in 0.57. This file is the only
-- entry point Hyprland reads; everything else lives in modules/ and is pulled
-- in with require().

--------------------
---- MONITORS ------
--------------------

require("modules.monitors")

-----------------------
---- ENVIRONMENT ------
-----------------------

-- Cursor
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "24")

-- Qt / GTK on Wayland
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "0")
hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")

-- Browsers / Electron
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Session identity
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_MENU_PREFIX", "arch-")

-- NOTE: LIBVA_DRIVER_NAME / __GLX_VENDOR_LIBRARY_NAME are intentionally not
-- set. This machine is a hybrid Intel + NVIDIA laptop; hardcoding nvidia
-- breaks Intel hardware video decode. Use `prime-run <app>` for the dGPU.

----------------
---- LOOK ------
----------------

require("modules.theme")
require("modules.animations")

-------------------
---- KEYBINDS -----
-------------------

require("modules.keybinds")

----------------
---- RULES -----
----------------

require("modules.rules")

--------------------
---- AUTOSTART -----
--------------------

require("modules.sessions")
