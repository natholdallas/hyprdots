-- Window / layer / workspace rules.
--
-- Layer rules are what make the "glass" look work: Hyprland only blurs layer
-- surfaces (bar, launcher, notifications). Regular windows never get blurred,
-- which keeps the frame cost at zero for actual work.
--
-- The namespace names must match what the apps report; check with
--   hyprctl layers

-----------------------------
---- LAYER RULES ------------
-----------------------------

hl.layer_rule({
    name  = "blur-waybar",
    match = { namespace = "^(waybar)$" },
    blur  = true,
    ignore_alpha = 0.2,
})

-- fuzzel defaults to the "launcher" namespace, but config/fuzzel/fuzzel.ini
-- sets `namespace=fuzzel`. Match both so the blur survives either value --
-- previously only "fuzzel" was matched while fuzzel reported "launcher", so
-- the launcher was never blurred at all.
hl.layer_rule({
    name  = "blur-fuzzel",
    match = { namespace = "^(fuzzel|launcher)$" },
    blur  = true,
    ignore_alpha = 0.2,
})

hl.layer_rule({
    name  = "blur-notifications",
    match = { namespace = "^(notifications)$" },
    blur  = true,
    ignore_alpha = 0.2,
})

hl.layer_rule({
    name  = "blur-hyprlock",
    match = { namespace = "^(hyprlock)$" },
    blur  = true,
})

-----------------------------
---- WINDOW RULES -----------
-----------------------------

-- Tiled windows do not need a drop shadow; it only costs GPU time.
hl.window_rule({
    name  = "no-shadow-tiled",
    match = { float = false },
    no_shadow = true,
})

-- Ignore maximize requests: a tiling WM has its own semantics and apps that
-- force themselves maximized fight with the layout.
hl.window_rule({
    name  = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Polkit authentication prompt.
hl.window_rule({
    name  = "float-polkit",
    match = { class = "^(hyprpolkitagent|org\\.kde\\.polkit-kde-authentication-agent-1)$" },
    float  = true,
    center = true,
})

-- Common dialogs that behave badly when tiled.
for _, cls in ipairs({
    "^(xdg-desktop-portal-gtk|xdg-desktop-portal-gnome)$",
    "^(nm-connection-editor)$",
    "^(blueman-manager)$",
    "^(pavucontrol|org\\.pulseaudio\\.pavucontrol)$",
    "^(nwg-look)$",
    "^(file-roller|org\\.gnome\\.FileRoller)$",
}) do
    hl.window_rule({ name = "float-" .. cls, match = { class = cls }, float = true, size = "900 620", center = true })
end

-- Games keep an explicit zero rounding even though the global default is
-- already 0; gamescope can override decoration per-window, so this pins it.
hl.window_rule({
    name  = "no-rounding-games",
    match = { class = "^(steam_app_.*|gamescope)$" },
    rounding = 0,
})

-----------------------------
---- WORKSPACE RULES --------
-----------------------------

hl.workspace_rule({
    workspace = "special:scratch",
    gaps_out  = 24,
    gaps_in   = 8,
})
