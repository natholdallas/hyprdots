# AGENTS.md

Dotfiles repo for a Hyprland session layered on KDE Plasma (Arch). No build,
test, lint, or CI. "Verification" means loading the config in a live Hyprland
session.

## Install model (most important)

- The repo root `hypr/` is copied verbatim to `~/.config/hypr` by `./install.sh`.
- All runtime paths are absolute (`~/.config/hypr/...`), so **editing the repo
  alone changes nothing** until it is installed/copied. Never debug configs by
  reading only the repo path; the live copy is `~/.config/hypr`.
- A new `.conf` file is inert until it is added to the `source =` list at the
  bottom of `hypr/hyprland.conf`.
- `hyprlock.conf` is *not* sourced from `hyprland.conf`; Hyprland reads
  `~/.config/hypr/hyprlock.conf` implicitly.
- `install.sh` is destructive: it `mv`s the whole existing `~/.config/hypr` to
  `~/.local/share/hyprdots-backup`, wiping that backup dir first (`rm -r $backup/*`,
  which leaves dotfiles behind). No `set -e`, so failures are not fatal and the
  `cp` still runs. Test on a throwaway user/HOME, not a real desktop.
- `README.md` mentions an `uninstall.sh` that does not exist in the repo.

## Layout

- `hypr/{animations,keybindings,windowrules,themes}.conf` — `source`d fragments;
  `themes.conf` holds the `general`/`decoration`/`misc` blocks.
- `hypr/config/{waybar,mako,wofi}/` — configs live here, **not** in
  `~/.config/waybar` etc. They are passed explicitly with
  `--config`/`--style` by `hypr/scripts/{waybar,notifications,wofi}.sh`. Keeping
  them in one directory is intentional; do not "fix" them to XDG locations.
- `hypr/scripts/*.sh` — thin wrappers launched from binds and `exec-once`.
  `volume.sh` takes `i|d|mute|mic`; `brightness.sh` takes `i|d`;
  `screenshot.sh` takes `-region|-window|-monitor|-monitorclipboard`.
- Not in the repo, but required at runtime: `~/.local/share/backgrounds/wallpaper`
  (hyprpaper) and `wallpaper-lock` (hyprlock).

## Verifying changes

```sh
bash -n install.sh hypr/scripts/*.sh   # shell syntax
hyprctl reload                          # pick up .conf edits
hyprctl configerrors                    # check for parse errors
```

For a script change, re-run it directly (e.g. `hypr/scripts/brightness.sh i`)
rather than reloading.

## Gotchas

- `hypr/hyprlock.conf` references `$color0/$color6/$color7`, which are defined
  nowhere — Hyprland's colors are not available in hyprlock. Replace with real
  values when touching that file.
- Scripts assume Arch tooling: `amixer` (PulseAudio), `brightnessctl`,
  `fcitx5`, `hyprshot`, `kbuildsycoca6`. `initkde.sh` picks the `plasma-` or
  `arch-` menu prefix by probing `/etc/xdg/menus`.
- Package names in `README.md` are install hints only; nothing installs them.
- `keybindings.conf` defines `$meta = Super` and app/script variables at the
  top; binds reference those variables, so change a command once there rather
  than in each bind.
- Indentation is inconsistent: `scripts/*.sh` use tabs, `themes.conf` /
  `animations.conf` use 4 spaces, `hyprland.conf` / `keybindings.conf` none.
  Match the file you edit.
