-- Animations.
--
-- Two spring curves do the heavy lifting: `snappy` for windows (a card that
-- pops into place) and `smooth` for anything that should feel softer. Beziers
-- stay for layers, where a short fade reads better than a spring and is much
-- cheaper than sliding a full-screen surface.
--
-- Workspaces use `slide` rather than `fade`: the desktop physically moves
-- sideways, which matches the Alt+[ / Alt+] loop and makes the wrap at 10 -> 1
-- legible.
--
-- speed is in deciseconds (100ms each), so 5.0 = 500ms. 3.0 (300ms) read as a
-- flick on a 144Hz panel. The easeOut bezier does most of the travel early, so
-- 500ms feels deliberate without being sluggish.
--
-- `enabled = true` is required on every hl.animation call in 0.57.

hl.curve("smooth",  { type = "spring", mass = 1, stiffness = 200, damping = 26 })
hl.curve("snappy",  { type = "spring", mass = 1, stiffness = 320, damping = 30 })
hl.curve("easeOut", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1 } } })
hl.curve("linear",  { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

hl.animation({ leaf = "windows",    enabled = true, speed = 4.5, spring = "snappy",  style = "popin 95%" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4.0, spring = "snappy",  style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.5, bezier = "easeOut", style = "popin 95%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4.0, spring = "smooth" })

hl.animation({ leaf = "layers",     enabled = true, speed = 4.0, bezier = "easeOut" })
hl.animation({ leaf = "layersIn",   enabled = true, speed = 4.0, bezier = "easeOut", style = "fade" })
hl.animation({ leaf = "layersOut",  enabled = true, speed = 2.0, bezier = "easeOut", style = "fade" })

hl.animation({ leaf = "workspaces", enabled = true, speed = 5.0, bezier = "easeOut", style = "slide" })
hl.animation({ leaf = "border",     enabled = true, speed = 4.0, bezier = "easeOut" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3.5, bezier = "easeOut" })
hl.animation({ leaf = "fadeIn",     enabled = true, speed = 3.5, bezier = "easeOut" })
hl.animation({ leaf = "fadeOut",    enabled = true, speed = 2.5, bezier = "easeOut" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 3.0, bezier = "easeOut" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 6.0, bezier = "easeOut" })
