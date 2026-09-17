#!/usr/bin/env bash
# =============================================================================
# Wallzy — Universal Linux Wallpaper Installer
# Curated & developed by Muzammil Nawaz
# https://github.com/themuzammilnawaz/Wallzy
# =============================================================================

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────

VERSION="1.0.0"
REPO_URL="https://github.com/themuzammilnawaz/Wallzy.git"
RAW_URL="https://raw.githubusercontent.com/themuzammilnawaz/Wallzy/main"

WALLZY_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/wallzy"
REPO_DIR="$WALLZY_DIR/repo"
BIN_DIR="$HOME/.local/bin"
PICTURES_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Wallzy"

# ─── Colors ──────────────────────────────────────────────────────────────────

if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    DIM='\033[2m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' DIM='' NC=''
fi

# ─── Helpers ─────────────────────────────────────────────────────────────────

log()     { echo -e "${BLUE}◆${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warn()    { echo -e "${YELLOW}▲${NC} $*"; }
error()   { echo -e "${RED}✗${NC} $*" >&2; }
info()    { echo -e "${DIM}  $*${NC}"; }

banner() {
    echo ""
    echo -e "${CYAN}${BOLD}"
    cat << 'EOF'
 ██╗    ██╗ █████╗ ██╗     ██╗     ███████╗██╗   ██╗
 ██║    ██║██╔══██╗██║     ██║     ╚══███╔╝╚██╗ ██╔╝
 ██║ █╗ ██║███████║██║     ██║       ███╔╝  ╚████╔╝
 ██║███╗██║██╔══██║██║     ██║      ███╔╝    ╚██╔╝
 ╚███╔███╔╝██║  ██║███████╗███████╗███████╗   ██║
  ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝   ╚═╝
EOF
    echo -e "${NC}"
    echo -e "  ${BOLD}Universal Linux Wallpaper Installer${NC}  ${DIM}v${VERSION}${NC}"
    echo -e "  ${DIM}Curated & developed by Muzammil Nawaz${NC}"
    echo ""
}

# ─── Dependency Checks ───────────────────────────────────────────────────────

check_git() {
    if ! command -v git &>/dev/null; then
        error "git is not installed."
        info "Install it with your package manager:"
        info "  Debian/Ubuntu:  sudo apt install git"
        info "  Fedora:         sudo dnf install git"
        info "  Arch:           sudo pacman -S git"
        exit 1
    fi
}

# ─── Desktop Environment Detection ───────────────────────────────────────────

detect_de() {
    local de=""

    if [ -n "${XDG_CURRENT_DESKTOP:-}" ]; then
        de="$XDG_CURRENT_DESKTOP"
    elif [ -n "${DESKTOP_SESSION:-}" ]; then
        de="$DESKTOP_SESSION"
    elif [ -n "${WAYLAND_DISPLAY:-}" ]; then
        de="wayland"
    elif [ -n "${DISPLAY:-}" ]; then
        de="x11"
    fi

    # Normalize
    echo "$de" | tr '[:upper:]' '[:lower:]'
}

detect_hyprland() {
    [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && return 0
    return 1
}

detect_sway() {
    [ -n "${SWAYSOCK:-}" ] && return 0
    return 1
}

# ─── Wallpaper Setter ────────────────────────────────────────────────────────

set_wallpaper() {
    local image="$1"
    local de
    de="$(detect_de)"

    if [ ! -f "$image" ]; then
        warn "Wallpaper file not found: $image"
        return 1
    fi

    # Wayland compositors first
    if detect_hyprland; then
        if command -v hyprpaper &>/dev/null; then
            hyprctl hyprpaper preload "$image" &>/dev/null || true
            hyprctl hyprpaper wallpaper ",$image" &>/dev/null || true
            success "Wallpaper set via hyprpaper"
            return 0
        elif command -v swww &>/dev/null; then
            swww img "$image" &>/dev/null || true
            success "Wallpaper set via swww"
            return 0
        fi
    fi

    if detect_sway; then
        if command -v swaybg &>/dev/null; then
            pkill swaybg 2>/dev/null || true
            swaybg -i "$image" -m fill &>/dev/null &
            success "Wallpaper set via swaybg"
            return 0
        fi
    fi

    # Desktop environments
    case "$de" in
        *gnome*|*ubuntu*|*pop*|*unity*|*budgie*|*cinnamon*|*mate*)
            gsettings set org.gnome.desktop.background picture-uri "file://$image" 2>/dev/null || true
            gsettings set org.gnome.desktop.background picture-uri-dark "file://$image" 2>/dev/null || true
            success "Wallpaper set via gsettings"
            return 0
            ;;
        *kde*|*plasma*)
            if command -v plasma-apply-wallpaperimage &>/dev/null; then
                plasma-apply-wallpaperimage "$image" 2>/dev/null || true
            else
                qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript \
                    "var d = desktops(); for (i=0;i<d.length;i++) { d[i].wallpaperPlugin='org.kde.image'; d[i].currentConfigGroup=['Wallpaper','org.kde.image','General']; d[i].writeConfig('Image','file://$image'); }" &>/dev/null || true
            fi
            success "Wallpaper set via KDE Plasma"
            return 0
            ;;
        *xfce*)
            for prop in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep last-image); do
                xfconf-query -c xfce4-desktop -p "$prop" -s "$image" 2>/dev/null || true
            done
            xfdesktop --reload 2>/dev/null || true
            success "Wallpaper set via xfconf-query"
            return 0
            ;;
        *lxde*)
            pcmanfm --set-wallpaper="$image" 2>/dev/null || true
            success "Wallpaper set via pcmanfm"
            return 0
            ;;
        *lxqt*)
            pcmanfm-qt --set-wallpaper="$image" --wallpaper-mode=stretch 2>/dev/null || true
            success "Wallpaper set via pcmanfm-qt"
            return 0
            ;;
        *i3*|*bspwm*|*openbox*|*awesome*|*x11*|*wayland*|*unknown*|"")
            if command -v feh &>/dev/null; then
                feh --bg-fill "$image"
                success "Wallpaper set via feh"
                return 0
            elif command -v nitrogen &>/dev/null; then
                nitrogen --set-zoom-fill "$image" 2>/dev/null || true
                success "Wallpaper set via nitrogen"
                return 0
            fi
            ;;
    esac

    warn "Could not auto-detect desktop environment: $de"
    info "Wallpapers are installed at: $PICTURES_DIR"
    info "Set your wallpaper manually from there."
    return 1
}

# ─── Install Steps ───────────────────────────────────────────────────────────

install_repo() {
    log "Installing Wallzy archive..."

    if [ -d "$REPO_DIR/.git" ]; then
        info "Existing installation found. Updating..."
        git -C "$REPO_DIR" pull --ff-only 2>/dev/null || {
            warn "Update failed. Removing and re-cloning..."
            rm -rf "$REPO_DIR"
            git clone --depth 1 "$REPO_URL" "$REPO_DIR"
        }
        success "Archive updated"
    else
        mkdir -p "$WALLZY_DIR"
        git clone --depth 1 "$REPO_URL" "$REPO_DIR"
        success "Archive installed to $REPO_DIR"
    fi
}

install_cli() {
    log "Installing CLI tool..."

    if [ ! -f "$REPO_DIR/scripts/wallzy.sh" ]; then
        warn "CLI script not found in repo. Skipping."
        return
    fi

    mkdir -p "$BIN_DIR"
    install -m755 "$REPO_DIR/scripts/wallzy.sh" "$BIN_DIR/wallzy"
    success "CLI installed to $BIN_DIR/wallzy"

    # PATH check
    if ! echo "$PATH" | grep -q "$BIN_DIR"; then
        warn "$BIN_DIR is not in your PATH."
        info "Add this to your ~/.bashrc or ~/.zshrc:"
        info "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
}

install_wallpapers() {
    log "Linking wallpapers to Pictures..."

    mkdir -p "$(dirname "$PICTURES_DIR")"

    if [ -L "$PICTURES_DIR" ] || [ -d "$PICTURES_DIR" ]; then
        info "Existing wallpapers directory found at $PICTURES_DIR"
        if [ -L "$PICTURES_DIR" ]; then
            rm "$PICTURES_DIR"
        fi
    fi

    ln -sfn "$REPO_DIR/wallpapers" "$PICTURES_DIR"
    success "Wallpapers linked at $PICTURES_DIR"
}

install_jq() {
    if command -v jq &>/dev/null; then
        return
    fi

    warn "jq is not installed (required for CLI)."
    info "Install it with:"
    info "  Debian/Ubuntu:  sudo apt install jq"
    info "  Fedora:         sudo dnf install jq"
    info "  Arch:           sudo pacman -S jq"
}

demo_wallpaper() {
    log "Setting a demo wallpaper..."

    local first
    first="$(find "$REPO_DIR/wallpapers" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | head -n 1)"

    if [ -z "$first" ]; then
        info "No wallpapers found yet. Add some and re-run, or use the CLI later:"
        info "  wallzy random"
        return
    fi

    set_wallpaper "$first" || true
}

# ─── Main ────────────────────────────────────────────────────────────────────

main() {
    banner

    check_git

    echo -e "${BOLD}System Information${NC}"
    info "Desktop:  $(detect_de)"
    info "Shell:    ${SHELL:-unknown}"
    info "Install:  $WALLZY_DIR"
    echo ""

    install_repo
    install_cli
    install_wallpapers
    install_jq
    demo_wallpaper

    echo ""
    echo -e "${GREEN}${BOLD}  ✓ Wallzy installed successfully!${NC}"
    echo ""
    echo -e "  ${BOLD}Quick start:${NC}"
    echo -e "    ${CYAN}wallzy list${NC}              — list categories"
    echo -e "    ${CYAN}wallzy random${NC}            — set a random wallpaper"
    echo -e "    ${CYAN}wallzy search ubuntu${NC}     — search wallpapers"
    echo -e "    ${CYAN}wallzy help${NC}              — show all commands"
    echo ""
    echo -e "  ${BOLD}Gallery:${NC}  ${BLUE}https://themuzammilnawaz.github.io/Wallzy/${NC}"
    echo -e "  ${DIM}Curated & developed by Muzammil Nawaz${NC}"
    echo ""
}

main "$@"
