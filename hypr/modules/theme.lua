-- Visual theme: the single place to change colours, gaps and effects.
--
-- Palette is the shadcn/ui "zinc" scale on a dark surface:
--   zinc-950 #09090b   zinc-900 #18181b   zinc-800 #27272a
--   zinc-400 #a1a1aa   zinc-100 #f4f4f5   white    #ffffff
--
-- Look: square windows with no border at all. Focus is signalled by dimming the
-- unfocused windows instead of drawing an outline, which is what modern UIs do
-- (Windows 11 / GNOME 46+). Layer surfaces keep their own rounding: a glass
-- capsule looks wrong with hard corners, so bar / launcher / notifications stay
-- soft while real windows stay sharp. Blur is applied to layer surfaces only,
-- never to regular windows -- that is what would cost frames.

hl.config({
    general = {
        gaps_in     = 6,
        gaps_out    = 10,
        border_size = 0,

        layout              = "dwindle",
        resize_on_border    = true,
        allow_tearing       = false,

        -- With no border there is nothing to grab, so the resize hot zone has to
        -- be widened explicitly or dragging a window edge stops working.
        extend_border_grab_area = 12,

        snap = {
            enabled      = true,
            window_gap   = 8,
            monitor_gap  = 10,
            respect_gaps = true,
        },

        -- border_size is 0, so none of these ever render. They stay as fully
        -- transparent values rather than being removed, because the keys are
        -- still required by the schema.
        col = {
            active_border   = "rgba(00000000)",
            inactive_border = "rgba(00000000)",
            nogroup_border  = "rgba(00000000)",
        },
    },

    decoration = {
        rounding       = 0,
        rounding_power = 2,

        active_opacity     = 1.0,
        inactive_opacity   = 1.0,
        fullscreen_opacity = 1.0,

        -- The only remaining focus cue now that windows have no border.
        --
        -- IMPORTANT: this value is the *amount of dimming*, not the brightness
        -- that survives. 1.0 dims an unfocused window to fully black; 0.88
        -- (the previous value) left the desktop looking broken -- an unfocused
        -- browser went down to ~8/255 mean brightness, i.e. effectively
        -- invisible. Measured on this panel: 0.88 -> 8.49, 0.30 -> 118, 0.20 ->
        -- 136, 0.10 -> 152 (focused window is ~155).
        --
        -- 0.15 is a light "recede" -- enough to tell which window has focus,
        -- not enough to make the other one unreadable.
        dim_inactive          = true,
        dim_strength          = 0.15,
        border_part_of_window = true,

        blur = {
            enabled = true,

            -- `size` is the blur distance in pixels and `passes` the number of
            -- extra samples. Cost scales with size^2 * passes, so these two are
            -- the first thing to lower on a high-resolution or high-Hz panel.
            size   = 3,
            passes = 2,

            -- xray / ignore_opacity make the blur *ignore* per-window opacity.
            -- That is required for the glass look on layers, and it is also the
            -- cheaper path, because the blur result only has to be computed
            -- once instead of being re-blended per window opacity.
            xray           = true,
            ignore_opacity = true,

            noise             = 0,
            new_optimizations = true,

            -- Only blur popups that are explicitly requested by layer rules.
            popups = false,
        },

        shadow = {
            enabled      = true,

            -- range/render_power drive a per-window shadow texture. Tiled
            -- windows turn shadows off in modules/rules.lua, so this only ever
            -- costs anything for floating windows.
            range        = 12,
            render_power = 3,

            color  = "rgba(00000066)",
            offset = { 0, 3 },
        },

        glow = { enabled = false },
    },

    -- workspace_wraparound lets the slide animation carry on past the last
    -- workspace instead of snapping back, which is what makes the 1..10 loop
    -- in modules/keybinds.lua feel continuous.
    animations = {
        enabled              = true,
        workspace_wraparound = true,
    },


    misc = {
        disable_hyprland_logo    = true,
        force_default_wallpaper  = -1,
        disable_splash_rendering = true,
        focus_on_activate        = true,
        mouse_move_enables_dpms  = true,
        key_press_enables_dpms   = true,

        -- Windows that are not focused still redraw at this rate. The default
        -- is unlimited, which on a 240Hz panel means two full-rate redraw
        -- schedules. Capping it frees GPU time for the focused window without
        -- a visible difference (video playback keeps working).
        render_unfocused_fps = 60,
    },

    -- Variable refresh rate. In 0.57 the old `misc:vfr` moved to debug.vfr.
    -- See modules/monitors.lua for per-output vrr overrides.
    debug = { vfr = true },

    -- Direct scanout lets a single fullscreen window be handed straight to the
    -- display plane, skipping a compositing pass. Big win for fullscreen video
    -- and games.
    render = { direct_scanout = true },

    binds = {
        workspace_back_and_forth = false,
        allow_workspace_cycles   = true,
        drag_threshold           = 6,
    },

    dwindle = {
        preserve_split = true,
        smart_split    = false,
        smart_resizing = true,
    },

    master = { new_status = "master" },

    ecosystem = {
        no_donation_nag = true,
        no_update_news  = true,
    },

    input = {
        kb_layout          = "us",
        follow_mouse       = 1,
        sensitivity        = 0,
        repeat_rate        = 40,
        repeat_delay       = 250,
        numlock_by_default = false,

        touchpad = {
            natural_scroll       = true,
            tap_to_click         = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            scroll_factor        = 1.0,
        },
    },

    cursor = {
        inactive_timeout    = 5,
        no_hardware_cursors = false,
        enable_hyprcursor   = true,
    },

    -- Swipe / scroll workspace switching. `use_r` walks workspaces in numeric
    -- order (1..10) instead of visit history, so a swipe always lands on the
    -- neighbour the bar shows. `create_new = false` stops an extra workspace
    -- from being spawned when you swipe past the last one.
    gestures = {
        workspace_swipe_distance       = 300,
        workspace_swipe_cancel_ratio   = 0.15,
        workspace_swipe_use_r          = true,
        workspace_swipe_create_new     = false,
        workspace_swipe_forever        = true,
        workspace_swipe_direction_lock = false,
    },
})
