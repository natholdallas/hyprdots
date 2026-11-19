#!/usr/bin/env bash
#
# hyprdots installer
#
# Every command is independent: you can run `./install.sh backup` without
# touching the installed config, or `./install.sh packages` without installing
# anything at all.
#
#   ./install.sh              show the usage/examples (nothing is installed)
#   ./install.sh install      back up the current config, then copy this repo
#   ./install.sh backup       back up ~/.config/hypr only
#   ./install.sh restore [d]  restore the most recent backup (or the directory d)
#   ./install.sh list         list available backups
#   ./install.sh packages     install required packages (paru -> yay -> pacman)
#   ./install.sh check        verify the config parses (no side effects)
#   ./install.sh link         symlink the repo instead of copying it
#   ./install.sh uninstall    remove the config and restore the last backup
#
# Running with no argument, or with an unknown command, prints the usage text.
#
# All paths respect XDG_CONFIG_HOME / XDG_DATA_HOME, so a throwaway HOME can be
# used to test the script safely.

set -euo pipefail

readonly REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SRC_DIR="$REPO_DIR/hypr"
readonly CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
readonly BACKUP_ROOT="$DATA_DIR/hyprdots-backups"
readonly TARGET="$CONF_DIR/hypr"
readonly SYSTEMD_DIR="$CONF_DIR/systemd/user/mako.service.d"
readonly STAMP="$(date +%Y%m%d-%H%M%S)"

readonly PACKAGES=(
    hyprland
    hyprlock
    hypridle
    hyprpaper
    hyprpicker
    hyprshot
    hyprpolkitagent
    xdg-desktop-portal-hyprland
    waybar
    fuzzel
    mako
    cliphist
    wl-clipboard
    brightnessctl
    playerctl
    grim
    slurp
    jq
    libnotify
    inter-font
)

# ---------------------------------------------------------------------------
# output helpers
# ---------------------------------------------------------------------------

if [[ -t 1 ]]; then
    c_reset=$'\033[0m'; c_dim=$'\033[2m'; c_red=$'\033[31m'
    c_green=$'\033[32m'; c_yellow=$'\033[33m'; c_blue=$'\033[34m'
else
    c_reset=""; c_dim=""; c_red=""; c_green=""; c_yellow=""; c_blue=""
fi

info()  { printf '%s==>%s %s\n' "$c_blue"  "$c_reset" "$*"; }
ok()    { printf '%s ok %s %s\n' "$c_green" "$c_reset" "$*"; }
warn()  { printf '%swarn%s %s\n' "$c_yellow" "$c_reset" "$*" >&2; }
die()   { printf '%sfail%s %s\n' "$c_red"   "$c_reset" "$*" >&2; exit 1; }
note()  { printf '%s     %s%s\n' "$c_dim" "$*" "$c_reset"; }

# ---------------------------------------------------------------------------
# preconditions
# ---------------------------------------------------------------------------

require_repo() {
    [[ -d "$SRC_DIR" ]] || die "config directory not found: $SRC_DIR"
    [[ -f "$SRC_DIR/hyprland.lua" ]] || die "hyprland.lua missing from $SRC_DIR"
}

require_hyprland() {
    command -v hyprland >/dev/null 2>&1 || die "hyprland is not installed (try: $0 packages)"
}

# mako ships a system-wide D-Bus service that claims
# org.freedesktop.Notifications, and its vendor unit only checks
# $WAYLAND_DISPLAY -- which is also set in a KDE Plasma Wayland session. The
# drop-in in hypr/config/systemd/ restricts it to Hyprland so Plasma keeps its
# own notification daemon. It lives outside ~/.config/hypr, hence this copy.
install_systemd_dropins() {
    local src="$SRC_DIR/config/systemd"
    [[ -d "$src" ]] || return 0

    mkdir -p "$SYSTEMD_DIR"
    cp -a "$src/." "$CONF_DIR/systemd/user/"
    systemctl --user daemon-reload >/dev/null 2>&1 || true
    ok "installed systemd drop-ins into $CONF_DIR/systemd/user"
}

remove_systemd_dropins() {
    local f="$SYSTEMD_DIR/override.conf"
    [[ -f "$f" ]] || return 0
    rm -f "$f"
    rmdir "$SYSTEMD_DIR" 2>/dev/null || true
    systemctl --user daemon-reload >/dev/null 2>&1 || true
    ok "removed $f"
}

# ---------------------------------------------------------------------------
# commands
# ---------------------------------------------------------------------------

cmd_packages() {
    require_repo
    local missing=()
    for pkg in "${PACKAGES[@]}"; do
        pacman -Qq "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
    done

    if (( ${#missing[@]} == 0 )); then
        ok "all packages already installed"
        return 0
    fi

    info "missing packages: ${missing[*]}"
    if command -v paru >/dev/null 2>&1; then
        note "using paru"
        paru -S --needed --noconfirm "${missing[@]}"
    elif command -v yay >/dev/null 2>&1; then
        note "using yay"
        yay -S --needed --noconfirm "${missing[@]}"
    else
        note "using sudo pacman"
        sudo pacman -S --needed --noconfirm "${missing[@]}"
    fi
    ok "packages installed"
}

cmd_backup() {
    [[ -d "$TARGET" ]] || { warn "nothing to back up: $TARGET does not exist"; return 0; }

    mkdir -p "$BACKUP_ROOT"

    # Two installs in the same second would otherwise collide and nest.
    local dest="$BACKUP_ROOT/$STAMP"
    local n=1
    while [[ -e "$dest" ]]; do
        dest="$BACKUP_ROOT/$STAMP-$n"
        n=$(( n + 1 ))
    done

    cp -a "$TARGET" "$dest"
    ln -sfn "$dest" "$BACKUP_ROOT/latest"
    ok "backed up $TARGET -> $dest"
}

cmd_list() {
    if [[ ! -d "$BACKUP_ROOT" ]] || [[ -z "$(ls -A "$BACKUP_ROOT" 2>/dev/null | grep -v '^latest$')" ]]; then
        info "no backups in $BACKUP_ROOT"
        return 0
    fi
    info "backups in $BACKUP_ROOT:"
    local d
    for d in "$BACKUP_ROOT"/*; do
        [[ "$(basename "$d")" == "latest" ]] && continue
        note "$(basename "$d")"
    done
}

cmd_install() {
    require_repo
    mkdir -p "$CONF_DIR"

    if [[ -d "$TARGET" ]]; then
        cmd_backup
    fi

    info "copying $SRC_DIR -> $TARGET"
    rm -rf "$TARGET"
    cp -a "$SRC_DIR" "$TARGET"
    chmod 755 "$TARGET/scripts/"*.sh
    install_systemd_dropins

    ok "installed to $TARGET"
    cmd_check || true

    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
        info "reloading the running session"
        hyprctl reload >/dev/null 2>&1 && ok "config reloaded" || warn "hyprctl reload failed"
    else
        note "log out and back in (or start Hyprland) to apply"
    fi
}

cmd_link() {
    require_repo
    mkdir -p "$CONF_DIR"

    if [[ -d "$TARGET" ]] && [[ ! -L "$TARGET" ]]; then
        cmd_backup
        rm -rf "$TARGET"
    fi

    ln -sfn "$SRC_DIR" "$TARGET"
    ok "$TARGET -> $SRC_DIR"
    install_systemd_dropins
    note "edits in the repo now apply directly; 'git pull' is enough to update"
}

cmd_restore() {
    local src="${1:-}"
    if [[ -z "$src" ]]; then
        [[ -L "$BACKUP_ROOT/latest" ]] || die "no backup found (run: $0 list)"
        src="$(readlink -f "$BACKUP_ROOT/latest")"
    else
        [[ -d "$src" ]] || die "not a backup directory: $src"
    fi

    info "restoring $src -> $TARGET"
    rm -rf "$TARGET"
    cp -a "$src" "$TARGET"
    ok "restored"
    note "run 'hyprctl reload' if Hyprland is running"
}

cmd_check() {
    require_repo
    if ! command -v hyprland >/dev/null 2>&1; then
        warn "hyprland not installed, skipping parse check"
        return 0
    fi

    info "verifying config with hyprland --verify-config"
    local tmp
    tmp="$(mktemp -d)"

    mkdir -p "$tmp/hypr"
    cp -a "$SRC_DIR/." "$tmp/hypr/"

    local status=0
    if XDG_CONFIG_HOME="$tmp" hyprland --verify-config >"$tmp/log" 2>&1; then
        grep -q "config ok" "$tmp/log" || status=1
    else
        status=1
    fi

    if (( status == 0 )); then
        rm -rf "$tmp"
        ok "config parses cleanly"
        return 0
    fi

    grep -vE "DEBUG|Socket2" "$tmp/log" >&2 || true
    rm -rf "$tmp"
    die "config has errors"
}

cmd_uninstall() {
    if [[ ! -e "$TARGET" ]]; then
        warn "$TARGET does not exist, nothing to do"
        return 0
    fi

    local src=""
    if [[ -L "$BACKUP_ROOT/latest" ]] && [[ -d "$(readlink -f "$BACKUP_ROOT/latest")" ]]; then
        src="$(readlink -f "$BACKUP_ROOT/latest")"
    fi

    if [[ -n "$src" ]]; then
        info "removing $TARGET and restoring $src"
        rm -rf "$TARGET"
        cp -a "$src" "$TARGET"
        ok "uninstalled, previous config restored"
    else
        warn "no backup available; removing $TARGET without restoring"
        rm -rf "$TARGET"
        ok "uninstalled"
    fi

    remove_systemd_dropins
}

usage() {
    cat <<'EOF'
hyprdots installer

Every command is independent: you can run `./install.sh backup` without
touching the installed config, or `./install.sh packages` without installing
anything at all.

usage: ./install.sh <command> [args]

  install      back up the current config, then copy this repo
  backup       back up ~/.config/hypr only
  restore [d]  restore the most recent backup (or the directory d)
  list         list available backups
  packages     install required packages (paru -> yay -> sudo pacman)
  check        verify the config parses (no side effects)
  link         symlink the repo instead of copying it
  uninstall    remove the config and restore the last backup
  help         show this message

examples:
  ./install.sh packages     # install dependencies
  ./install.sh install      # back up, then install this repo
  ./install.sh check        # parse the config without touching anything
  ./install.sh backup       # snapshot ~/.config/hypr
  ./install.sh restore      # roll back to the last snapshot

All paths respect XDG_CONFIG_HOME / XDG_DATA_HOME, so a throwaway HOME can be
used to test the script safely:

  HOME=/tmp/testhome ./install.sh install

Nothing is installed unless you name a command.
EOF
}

# ---------------------------------------------------------------------------
# dispatch
# ---------------------------------------------------------------------------

cmd="${1:-}"

# No argument, or an unknown command: show the examples and stop. Installing is
# never implicit -- you must name the command you want.
if [[ -z "$cmd" ]]; then
    usage
    exit 0
fi

shift || true

case "$cmd" in
    install)   cmd_install ;;
    backup)    cmd_backup ;;
    restore)   cmd_restore "${1:-}" ;;
    packages)  cmd_packages ;;
    check)     cmd_check ;;
    list|ls)   cmd_list ;;
    link)      cmd_link ;;
    uninstall) cmd_uninstall ;;
    -h|--help|help) usage ;;
    *)
        printf '%sfail%s unknown command: %s\n\n' "$c_red" "$c_reset" "$cmd" >&2
        usage >&2
        exit 2
        ;;
esac
