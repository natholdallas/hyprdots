-- Monitors.
--
-- IMPORTANT: `mode = "preferred"` uses the EDID's *first* preferred timing.
-- On these panels that first entry is 1920x1080@60, and the 200Hz / 240Hz
-- timings sit further down the descriptor list (DTD 3 / DTD 4). So "preferred"
-- silently pins the whole desktop to 60Hz -- which is exactly what "frames feel
-- low" looks like on a 200Hz + 240Hz setup.
--
-- `highrr` picks the highest refresh rate the output advertises. Verify with:
--   hyprctl monitors | grep -E 'Hz|mode'
--
-- Keep this as a single catch-all so docking, undocking and adding a monitor
-- all just work. Add a per-output entry only when you need a fixed layout.

hl.monitor({
    output   = "",
    mode     = "highrr",
    position = "auto",
    scale    = "auto",
})

-- Per-output overrides: uncomment and edit when you want a pinned layout.
--
-- hl.monitor({ output = "DP-1",  mode = "highrr", position = "0x0",    scale = 1 })
-- hl.monitor({ output = "DP-2",  mode = "highrr", position = "1920x0", scale = 1 })
-- hl.monitor({ output = "eDP-1", mode = "highrr", position = "auto",   scale = 1 })
