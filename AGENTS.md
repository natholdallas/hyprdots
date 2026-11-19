# AGENTS.md

Dotfiles repo for a Hyprland session on Arch. No build, test, lint or CI.
"Verification" means parsing the config and, ultimately, loading it in a live
Hyprland session.

## Version requirement (most important)

**Hyprland 0.57+ only.** hyprlang (`.conf`) config support was removed in 0.57.
The config is now `hypr/hyprland.lua` plus modules pulled in through Lua
`require()`. Do not reintroduce `.conf` fragments for Hyprland itself.

Two files are still hyprlang, because those tools have not moved to Lua:
`hyprlock.conf` and `hyprpaper.conf`. They are read implicitly from
`~/.config/hypr/` and are *not* required from `hyprland.lua`.

## Install model

- The repo root `hypr/` is copied verbatim to `~/.config/hypr` by
  `./install.sh install`.
- All runtime paths are absolute (`~/.config/hypr/...`), so **editing the repo
  alone changes nothing** until it is installed or linked. Never debug by
  reading only the repo path; the live copy is `~/.config/hypr`.
  - `./install.sh link` symlinks instead, so repo edits apply live.
- `install.sh` subcommands are deliberately decoupled: `backup`, `restore`,
  `list`, `packages`, `check`, `link`, `uninstall`. Adding a command means
  adding one `cmd_*` function plus one `case` branch.
- There is **no implicit default**: no argument (or an unknown command) prints
  the usage/examples block and exits without touching the system. `usage()` is
  the `heredoc` near the bottom of `install.sh`; keep the script header comment
  and it in sync.
- Backups land in `~/.local/share/hyprdots-backups/<timestamp>/` (a `latest`
  symlink points at the newest). The installer never deletes old backups.
- A new `.lua` module is inert until it is `require()`d from `hyprland.lua`.

## Layout

- `hypr/hyprland.lua` — entry point: monitors, `hl.env`, `require` list.
- `hypr/modules/theme.lua` — **the only place colours live**. `general`,
  `decoration`, `misc`, `input`, `cursor`, `gestures` blocks.
- `hypr/modules/animations.lua` — curves and `hl.animation` leaves.
- `hypr/modules/keybinds.lua` — app variables at the top plus all binds and the
  `resize` submap.
- `hypr/modules/rules.lua` — `hl.window_rule`, `hl.layer_rule`,
  `hl.workspace_rule`. Layer rules are what enable blur behind the bar,
  launcher and notifications.
- `hypr/modules/sessions.lua` — autostart via `hl.on("hyprland.start")`.
- `hypr/config/{waybar,fuzzel,mako,hypridle}/` — configs live here, **not** in
  `~/.config/waybar` etc. They are passed explicitly with `--config` /
  `--style` by `hypr/scripts/{waybar,notifications}.sh`. Keeping them in one
  directory is intentional; do not "fix" them to XDG locations.
- `hypr/config/systemd/mako.service.d/override.conf` — the one config that
  *must* leave `hypr/`. `install.sh` copies it to
  `~/.config/systemd/user/`; systemd does not read drop-ins from `~/.config/hypr`.
  It restricts mako to Hyprland so KDE Plasma keeps its own notification daemon.
- `hypr/scripts/*.sh` — `#!/usr/bin/env bash` + `set -euo pipefail` + argument
  validation, mode 755.
  - `volume.sh up|down|mute|mic` (wpctl)
  - `brightness.sh up|down` (brightnessctl -n2 -e4)
  - `screenshot.sh region|window|output|clipboard`
  - `waybar.sh [--toggle] [bar-id]`
  - `notifications.sh [--toggle]`
  - `launcher.sh [dmenu]`
  - `wallpaper.sh [next|prev]`
  - `lock.sh`

## Lua API gotchas (verified against 0.57.2)

- `hl.animation` **requires** `enabled = true` on every leaf, otherwise:
  `missing required field "enabled"`.
- `misc.vfr` no longer exists — VFR is `debug.vfr`.
- `hl.timer(...)` in the config segfaults `--verify-config`. Do not use timers
  in startup config.
- Modifier names are case-insensitive but the key must be a real keysym:
  `hl.bind("SUPER + Return", …)` works, `hl.bind(", Print", …)` does not —
  use `hl.bind("Print", …)` with no leading comma.
- `render.explicit_sync` and similar old keys are gone; check
  `/usr/share/hypr/stubs/hl.meta.lua` for the authoritative key list.
- `define_submap(name, reset, fn)` is the replacement for `submap =` blocks.

## Verifying changes

```sh
./install.sh check                    # hyprland --verify-config in a temp HOME
bash -n hypr/scripts/*.sh             # shell syntax
hyprctl reload                        # pick up edits
hyprctl configerrors                  # zero errors expected
```

`./install.sh check` prints `config ok` or the parse errors and exits non-zero.
It copies the repo into a temp `XDG_CONFIG_HOME`, so it never touches the live
config.

Nested test (does not disturb a running KDE/other session — Hyprland opens
itself in a window):

```sh
XDG_CONFIG_HOME=$PWD/.. hyprland
```

## Gotchas

- `hyprlock.conf` still uses hyprlang; Hyprland theme variables (`$color0`,
  `$color6`, …) are **not** available there. Use literal colours.
- Scripts assume Arch tooling: `wpctl` (PipeWire), `brightnessctl`, `fcitx5`,
  `hyprshot`, `fuzzel`, `mako`, `hyprpolkitagent`. The config degrades
  gracefully when one is missing, but binds will silently do nothing.
- `LIBVA_DRIVER_NAME` must stay unset on hybrid Intel+NVIDIA laptops, or Intel
  hardware video decode breaks. Use `prime-run` for the dGPU.
- Packages in `README.md` are install hints; `./install.sh packages` is the
  only thing that actually installs them.
- Indentation: `.lua` and `.sh` use 4 spaces, CSS uses 2, config files use 4.
  Match the file you edit.
