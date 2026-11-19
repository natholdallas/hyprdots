# hyprdots

A minimal, high-performance Hyprland desktop with a shadcn-style interface.

Neutral zinc palette, hairline borders, 12px radii and spring-driven motion —
no drop shadows on tiled windows, no blur on regular windows. The blur budget is
spent only where it reads as depth: the bar, the launcher and notifications.

> Requires **Hyprland 0.57 or newer**. The old hyprlang (`.conf`) config format
> was removed in 0.57; this repo is pure Lua.

## Shell

`install.sh` is a single script with independent subcommands. Nothing runs
implicitly — each command does exactly one thing.

| command | description |
| --- | --- |
| `./install.sh` | show usage and examples (nothing is installed) |
| `./install.sh install` | back up the current config, then copy this repo |
| `./install.sh backup` | back up `~/.config/hypr` only |
| `./install.sh restore [dir]` | restore the most recent backup, or the given one |
| `./install.sh list` | list available backups |
| `./install.sh packages` | install required packages (paru → yay → sudo pacman) |
| `./install.sh check` | parse the config with `hyprland --verify-config` |
| `./install.sh link` | symlink the repo instead of copying (edits apply live) |
| `./install.sh uninstall` | remove the config and restore the last backup |

Installation is never implicit: running the script with no command, or with a
mistyped one, prints the usage text and exits without touching anything.

Backups go to `~/.local/share/hyprdots-backups/<timestamp>/` with a `latest`
symlink. All paths honour `XDG_CONFIG_HOME` / `XDG_DATA_HOME`, so you can test
against a throwaway `HOME`:

```sh
HOME=/tmp/testhome ./install.sh install
HOME=/tmp/testhome ./install.sh restore
```

## Packages

```sh
./install.sh packages
```

Installs: hyprland, hyprlock, hypridle, hyprpaper, hyprpicker, hyprshot,
hyprpolkitagent, xdg-desktop-portal-hyprland, waybar, fuzzel, mako, cliphist,
wl-clipboard, brightnessctl, playerctl, grim, slurp, jq, libnotify, inter-font.

Deliberately **not** installed — the config degrades gracefully without them:
`fcitx5` (input method), `kitty` / `neovide` / `google-chrome-stable` /
`yazi` / `nvtop` (referenced by keybinds), `hyprsunset`.

## Layout

```
hypr/
├── hyprland.lua          entry point: monitors, env, requires
├── modules/
│   ├── theme.lua         colours, gaps, rounding, blur, shadow, input
│   ├── animations.lua    spring curves + per-leaf animation
│   ├── keybinds.lua      app variables + every bind and the resize submap
│   ├── rules.lua         window / layer / workspace rules
│   └── sessions.lua      autostart, portals, idle, clipboard watchers
├── scripts/              volume, brightness, screenshot, launcher, lock, …
├── config/
│   ├── waybar/           config.jsonc + style.css
│   ├── fuzzel/           fuzzel.ini
│   ├── mako/             config
│   ├── systemd/          mako.service.d/ — keep mako out of KDE sessions
│   └── hypridle/         hypridle.conf
├── hyprlock.conf         lock screen (still hyprlang — hyprlock has no Lua yet)
└── hyprpaper.conf        wallpaper daemon
```

`theme.lua` is the only place to change colours. Palette used throughout:

| token | value |
| --- | --- |
| background | `#09090b` zinc-950 |
| surface | `#18181b` zinc-900 |
| surface-hover | `#27272a` zinc-800 |
| foreground | `#f4f4f5` zinc-100 |
| muted | `#a1a1aa` zinc-400 |
| border | `rgba(255,255,255,0.10)` |
| danger | `#fca5a5` |
| radius | 10px windows / 12px overlays |

## Monitors and refresh rate

`hypr/modules/monitors.lua` uses `mode = "highrr"` (highest refresh rate), **not**
`"preferred"`.

This matters: `preferred` takes the EDID's *first* preferred timing. On the
panels this repo was tuned for, that entry is `1920x1080@60` and the 200Hz /
240Hz timings sit further down the descriptor list (DTD 3 / DTD 4). Using
`preferred` therefore pins the whole desktop to 60Hz and looks like "low fps"
on high-refresh hardware.

Check what you actually got:

```sh
hyprctl monitors | grep -E '^Monitor|Hz|mode'
```

Each line should show the highest rate the panel advertises.

### Mixed refresh rates

Two panels at 200Hz and 240Hz are **not** in a harmonic ratio (200/240 =
0.833). Hyprland composites all outputs from a single render thread, so a
mismatched pair cannot both hit their native rate — the faster output gets
paced to the slower cadence and motion looks uneven. Options, in order of
effectiveness:

1. **Pick a harmonic pair** — e.g. 120Hz + 240Hz (both divide evenly). This is
   the only setting where both panels are genuinely smooth.
2. **Leave VRR off** (`vrr = 0`, the default here). VRR across mismatched
   outputs makes the stutter more visible, not less.
3. **Accept the pacing** — 240Hz and 200Hz still look far better than 60Hz,
   they just are not perfectly in phase with each other.

Also relevant, and already set in `modules/theme.lua`:

- `misc.render_unfocused_fps = 60` — unfocused windows stop redrawing at full
  rate. The default is unlimited, which means two full-rate schedules.
- `render.direct_scanout = true` — fullscreen windows skip a compositing pass.
- `debug.vfr = true` — variable refresh rate (`misc.vfr` no longer exists).
- Blur `size = 3, passes = 2` and `popups = false` — cost scales with
  `size² × passes`; these are the knobs to lower first.

## Keybinds

`$mod` is **Super**.

| key | action |
| --- | --- |
| `Super + Return` | terminal (kitty) |
| `Ctrl + Alt + T` | terminal (kitty) |
| `Super + R`, `Alt + F2` | launcher (fuzzel) |
| `Super + Q`, `Alt + F4` | close window |
| `Super + Shift + Q` | force-kill window |
| `Super + F`, `Alt + Return` | fullscreen |
| `Super + Space` | toggle floating |
| `Super + J` | toggle split |
| `Super + U` | pseudo tile |
| `Super + Tab` | cycle to next window |
| `Super + V` | clipboard history |
| `Super + E` | yazi |
| `Super + B` / `N` | browser / editor |
| `Super + Escape` | nvtop |
| `Ctrl + Shift + Escape` | htop |
| `Super + P` | colour picker |
| `Super + Z` / `X` | drag / resize with mouse |
| `Super + arrow keys` | focus |
| `Super + Shift + arrows` | move window |
| `Super + Ctrl + arrows` | resize window |
| `Super + 1..0` | switch workspace |
| `Super + Shift + 1..0` | move window to workspace |
| `Ctrl + Alt + h/l`, `Ctrl + Alt + ←/→` | previous / next workspace |
| `Super + Ctrl + Alt + ←/→` | move window to prev/next workspace |
| `Super + S` / `Shift + S` | scratchpad toggle / send |
| `Super + L` | lock |
| `Super + Delete` | exit Hyprland |
| `Ctrl + Alt + W` | toggle bar |
| `Super + Print` | cycle wallpaper |
| `Print` / `Ctrl+Print` / `Shift+Print` / `Ctrl+Shift+Print` | region / window / monitor / clipboard screenshot |
| media & brightness keys | volume / backlight / playback |

## Fonts

`inter-font` is used for the bar, launcher, notifications and lock screen.
Nerd Fonts for icons — install any of:

```sh
paru -S ttf-monaco-nerd-font-git
paru -S ttf-firacode-nerd
paru -S ttf-mononoki-nerd
```

## Requirements outside this repo

Not created by the installer; supply them yourself:

- `~/.local/share/backgrounds/wallpaper` — hyprpaper
- `~/.local/share/backgrounds/wallpaper-lock` — hyprlock

## Verifying changes

```sh
./install.sh check                    # parses the Lua config, no side effects
bash -n hypr/scripts/*.sh             # shell syntax
hyprctl reload && hyprctl configerrors
```

To try the config without leaving your current desktop, run Hyprland nested in a
window (it detects the existing Wayland session and opens a regular window):

```sh
XDG_CONFIG_HOME=$PWD/.. hyprland
```

## Notes

- `hyprlock.conf` and `hyprpaper.conf` remain hyprlang: those tools have not
  moved to Lua.
- The `scripts/*` wrappers keep all configs under `hypr/config/` instead of
  `~/.config/waybar` etc. They are passed explicitly with `--config` / `--style`.
- `LIBVA_DRIVER_NAME` is intentionally unset so Intel hardware decode keeps
  working on hybrid graphics; use `prime-run <app>` for the discrete GPU.

## mako versus KDE Plasma

Installing `mako` on an Arch box that also has Plasma is a trap. The package
ships `/usr/share/dbus-1/services/fr.emersion.mako.service`, which claims
`org.freedesktop.Notifications` via D-Bus activation, and its vendor systemd
unit only guards with `ExecCondition=[ -n "$WAYLAND_DISPLAY" ]`. Plasma Wayland
sets that variable too, so mako wins the D-Bus name before plasmashell can claim
it. plasmashell then logs `Failed to register Notification service on DBus` and
KDE notifications silently come from mako — even though Hyprland is not running.

`hypr/config/systemd/mako.service.d/override.conf` replaces that `ExecCondition`
with a Hyprland check. `./install.sh install` / `link` copies it to
`~/.config/systemd/user/mako.service.d/` and runs `systemctl --user daemon-reload`;
`./install.sh uninstall` removes it. The drop-in cannot live under `hypr/` because
systemd does not read that path.

After installing, restore Plasma's daemon in the current session with:

```sh
systemctl --user stop mako
systemctl --user restart plasma-plasmashell
```

To confirm the notification owner:

```sh
busctl --user list | grep '^org.freedesktop.Notifications'
```

It should show `plasmashell` under KDE and `mako` under Hyprland.

