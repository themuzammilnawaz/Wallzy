#!/usr/bin/env bash
# =============================================================================
# Wallzy CLI — Browse, search, and set wallpapers from the terminal
#
# Curated & developed by Muzammil Nawaz
# https://github.com/themuzammilnawaz/Wallzy
# =============================================================================

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────

VERSION="1.0.0"
WALLZY_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/wallzy"
REPO_DIR="$WALLZY_DIR/repo"
INDEX="$REPO_DIR/wallpapers.json"
WALLPAPERS_DIR="$REPO_DIR/wallpapers"

# ─── Colors ──────────────────────────────────────────────────────────────────

if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    MAGENTA='\033[0;35m'
    BOLD='\033[1m'
    DIM='\033[2m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' MAGENTA='' BOLD='' DIM='' NC=''
fi

# ─── Helpers ─────────────────────────────────────────────────────────────────

die()  { echo -e "${RED}✗${NC} $*" >&2; exit 1; }
info() { echo -e "${DIM}$*${NC}"; }

require_jq() {
    if ! command -v jq &>/dev/null; then
        die "jq is required but not installed. Install it with your package manager."
    fi
}

require_index() {
    if [ ! -f "$INDEX" ]; then
        die "Wallpapers index not found. Run 'wallzy update' first."
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
    echo "$de" | tr '[:upper:]' '[:lower:]'
}

# ─── Wallpaper Setter ────────────────────────────────────────────────────────

set_wallpaper() {
    local image="$1"
    local de
    de="$(detect_de)"

    [ -f "$image" ] || die "Wallpaper not found: $image"

    if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        if command -v hyprpaper &>/dev/null; then
            hyprctl hyprpaper preload "$image" &>/dev/null || true
            hyprctl hyprpaper wallpaper ",$image" &>/dev/null || true
            echo -e "${GREEN}✓${NC} Wallpaper set via hyprpaper"
            return 0
        fi
    fi

    if [ -n "${SWAYSOCK:-}" ] && command -v swaybg &>/dev/null; then
        pkill swaybg 2>/dev/null || true
        swaybg -i "$image" -m fill &>/dev/null &
        echo -e "${GREEN}✓${NC} Wallpaper set via swaybg"
        return 0
    fi

    case "$de" in
        *gnome*|*ubuntu*|*pop*|*unity*|*budgie*|*cinnamon*|*mate*)
            gsettings set org.gnome.desktop.background picture-uri "file://$image" 2>/dev/null || true
            gsettings set org.gnome.desktop.background picture-uri-dark "file://$image" 2>/dev/null || true
            echo -e "${GREEN}✓${NC} Wallpaper set via gsettings"
            ;;
        *kde*|*plasma*)
            if command -v plasma-apply-wallpaperimage &>/dev/null; then
                plasma-apply-wallpaperimage "$image" 2>/dev/null || true
            else
                qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript \
                    "var d = desktops(); for (i=0;i<d.length;i++) { d[i].wallpaperPlugin='org.kde.image'; d[i].currentConfigGroup=['Wallpaper','org.kde.image','General']; d[i].writeConfig('Image','file://$image'); }" &>/dev/null || true
            fi
            echo -e "${GREEN}✓${NC} Wallpaper set via KDE Plasma"
            ;;
        *xfce*)
            for prop in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep last-image); do
                xfconf-query -c xfce4-desktop -p "$prop" -s "$image" 2>/dev/null || true
            done
            xfdesktop --reload 2>/dev/null || true
            echo -e "${GREEN}✓${NC} Wallpaper set via xfconf-query"
            ;;
        *)
            if command -v feh &>/dev/null; then
                feh --bg-fill "$image"
                echo -e "${GREEN}✓${NC} Wallpaper set via feh"
            elif command -v nitrogen &>/dev/null; then
                nitrogen --set-zoom-fill "$image" 2>/dev/null || true
                echo -e "${GREEN}✓${NC} Wallpaper set via nitrogen"
            else
                die "No supported wallpaper setter found. Install feh or nitrogen."
            fi
            ;;
    esac
}

# ─── Commands ────────────────────────────────────────────────────────────────

cmd_list() {
    require_jq; require_index

    local category="${1:-}"

    if [ -z "$category" ]; then
        echo ""
        echo -e "${BOLD}Wallzy Categories${NC}"
        echo -e "${DIM}────────────────────────────────────${NC}"
        jq -r '.categories[] | "\(.icon) \(.name)\t\(.count) wallpapers\t\(.id)"' "$INDEX" | \
            while IFS=$'\t' read -r name count id; do
                printf "  %-32s %-18s ${DIM}%s${NC}\n" "$name" "$count" "$id"
            done
        echo ""
        info "Usage: wallzy list <category-id>"
        echo ""
        return
    fi

    local cat_data
    cat_data="$(jq -r --arg id "$category" '.categories[$id] // empty' "$INDEX")"
    [ -n "$cat_data" ] || die "Category not found: $category"

    echo ""
    echo -e "${BOLD}$(echo "$cat_data" | jq -r '.icon + " " + .name')${NC}"
    echo -e "${DIM}────────────────────────────────────${NC}"

    echo "$cat_data" | jq -r '.wallpapers[] | "\(.name)\t\(.dimensions)\t\(.sizeHuman)"' | \
        while IFS=$'\t' read -r name dims size; do
            printf "  %-38s ${DIM}%s  %s${NC}\n" "$name" "$dims" "$size"
        done
    echo ""
    echo -e "${DIM}$(echo "$cat_data" | jq -r '.count') wallpapers${NC}"
    echo ""
}

cmd_search() {
    require_jq; require_index

    [ $# -gt 0 ] || die "Usage: wallzy search <query>"
    local query="$*"

    echo ""
    echo -e "${BOLD}Search: ${CYAN}$query${NC}"
    echo -e "${DIM}────────────────────────────────────${NC}"

    local results
    results="$(jq -r --arg q "$(echo "$query" | tr '[:upper:]' '[:lower:]')" '
        [.categories[].wallpapers[] | select(.name | ascii_downcase | contains($q))] |
        sort_by(.name) | .[] |
        "\(.category // "unknown")\t\(.name)\t\(.file)"
    ' "$INDEX" 2>/dev/null || true)"

    # Fallback: search across all categories with category context
    results="$(jq -r --arg q "$(echo "$query" | tr '[:upper:]' '[:lower:]')" '
        .categories | to_entries[] |
        .key as $cat |
        .value.wallpapers[] |
        select(.name | ascii_downcase | contains($q)) |
        "\($cat)\t\(.name)\t\(.file)"
    ' "$INDEX" 2>/dev/null || true)"

    if [ -z "$results" ]; then
        warn "No wallpapers found for: $query"
        return
    fi

    local count=0
    while IFS=$'\t' read -r cat name file; do
        printf "  ${CYAN}%-18s${NC} %-38s ${DIM}%s${NC}\n" "$cat" "$name" "$file"
        count=$((count + 1))
    done <<< "$results"

    echo ""
    echo -e "${DIM}$count result(s)${NC}"
    echo ""
}

warn() { echo -e "${YELLOW}▲${NC} $*"; }

cmd_random() {
    require_jq; require_index

    local category="${1:-}"
    local file

    if [ -n "$category" ]; then
        file="$(jq -r --arg id "$category" '.categories[$id].wallpapers[].file' "$INDEX" | shuf -n 1)"
    else
        file="$(jq -r '.categories[].wallpapers[].file' "$INDEX" | shuf -n 1)"
    fi

    [ -n "$file" ] || die "No wallpapers found${category:+ in category: $category}"

    local full_path="$REPO_DIR/$file"
    local name
    name="$(jq -r --arg f "$file" '[.categories[].wallpapers[] | select(.file == $f)][0].name' "$INDEX")"

    echo -e "${DIM}Setting:${NC} ${BOLD}$name${NC}"
    set_wallpaper "$full_path"
}

cmd_set() {
    require_jq; require_index

    [ $# -gt 0 ] || die "Usage: wallzy set <name>"
    local query="$*"

    local file
    file="$(jq -r --arg q "$(echo "$query" | tr '[:upper:]' '[:lower:]')" '
        [.categories[].wallpapers[] | select(.name | ascii_downcase | contains($q))][0].file // empty
    ' "$INDEX")"

    [ -n "$file" ] || die "Wallpaper not found: $query"

    local name
    name="$(jq -r --arg f "$file" '[.categories[].wallpapers[] | select(.file == $f)][0].name' "$INDEX")"

    echo -e "${DIM}Setting:${NC} ${BOLD}$name${NC}"
    set_wallpaper "$REPO_DIR/$file"
}

cmd_info() {
    require_jq; require_index

    local total generated size
    total="$(jq -r '.total' "$INDEX")"
    generated="$(jq -r '.generated' "$INDEX")"
    size="$(jq -r '.totalSizeHuman' "$INDEX")"

    echo ""
    echo -e "${BOLD}${CYAN}Wallzy Archive${NC}"
    echo -e "${DIM}────────────────────────────────────${NC}"
    echo -e "  Total wallpapers : ${BOLD}$total${NC}"
    echo -e "  Total size       : ${BOLD}$size${NC}"
    echo -e "  Categories       : ${BOLD}$(jq -r '.categories | length' "$INDEX")${NC}"
    echo -e "  Generated        : ${DIM}$generated${NC}"
    echo -e "  Repository       : ${BLUE}https://github.com/themuzammilnawaz/Wallzy${NC}"
    echo -e "  Gallery          : ${BLUE}https://themuzammilnawaz.github.io/Wallzy/${NC}"
    echo ""
    echo -e "  ${DIM}Curated & developed by Muzammil Nawaz${NC}"
    echo ""
}

cmd_update() {
    if [ ! -d "$REPO_DIR/.git" ]; then
        die "Wallzy archive not found. Run the installer first."
    fi

    echo -e "${BLUE}◆${NC} Updating Wallzy archive..."
    git -C "$REPO_DIR" pull --ff-only 2>/dev/null || warn "Update failed (offline?)"
    echo -e "${GREEN}✓${NC} Archive updated"
}

cmd_preview() {
    require_jq; require_index

    [ $# -gt 0 ] || die "Usage: wallzy preview <name>"
    local query="$*"

    local file
    file="$(jq -r --arg q "$(echo "$query" | tr '[:upper:]' '[:lower:]')" '
        [.categories[].wallpapers[] | select(.name | ascii_downcase | contains($q))][0].file // empty
    ' "$INDEX")"

    [ -n "$file" ] || die "Wallpaper not found: $query"

    local full_path="$REPO_DIR/$file"

    if command -v nsxiv &>/dev/null; then
        nsxiv "$full_path"
    elif command -v feh &>/dev/null; then
        feh --bg-fill "$full_path"
    elif command -v xdg-open &>/dev/null; then
        xdg-open "$full_path"
    else
        die "No image viewer found. Install feh, nsxiv, or xdg-utils."
    fi
}

cmd_help() {
    echo ""
    echo -e "${BOLD}${CYAN}Wallzy${NC} ${DIM}v${VERSION}${NC}"
    echo -e "${DIM}Curated & developed by Muzammil Nawaz${NC}"
    echo ""
    echo -e "${BOLD}Usage:${NC}  wallzy <command> [options]"
    echo ""
    echo -e "${BOLD}Commands:${NC}"
    echo -e "  ${CYAN}list${NC} [category]      List categories or wallpapers in a category"
    echo -e "  ${CYAN}search${NC} <query>       Search wallpapers by name"
    echo -e "  ${CYAN}random${NC} [category]    Set a random wallpaper"
    echo -e "  ${CYAN}set${NC} <name>           Set a specific wallpaper by name"
    echo -e "  ${CYAN}preview${NC} <name>       Preview a wallpaper"
    echo -e "  ${CYAN}info${NC}                 Show archive statistics"
    echo -e "  ${CYAN}update${NC}               Update the wallpaper archive"
    echo -e "  ${CYAN}help${NC}                 Show this help message"
    echo ""
    echo -e "${BOLD}Examples:${NC}"
    echo -e "  ${DIM}wallzy list${NC}"
    echo -e "  ${DIM}wallzy list nature-landscapes${NC}"
    echo -e "  ${DIM}wallzy search ubuntu${NC}"
    echo -e "  ${DIM}wallzy random dark-amoled${NC}"
    echo -e "  ${DIM}wallzy set \"fedora 40\"${NC}"
    echo ""
    echo -e "  ${BLUE}https://github.com/themuzammilnawaz/Wallzy${NC}"
    echo ""
}

# ─── Main Dispatch ───────────────────────────────────────────────────────────

main() {
    local cmd="${1:-help}"
    shift || true

    case "$cmd" in
        list|ls)      cmd_list "$@" ;;
        search|find)  cmd_search "$@" ;;
        random|rand)  cmd_random "$@" ;;
        set)          cmd_set "$@" ;;
        preview)      cmd_preview "$@" ;;
        info|stats)   cmd_info "$@" ;;
        update)       cmd_update "$@" ;;
        version|-v|--version)
            echo "wallzy v$VERSION"
            ;;
        help|-h|--help|"")
            cmd_help
            ;;
        *)
            die "Unknown command: $cmd (run 'wallzy help')"
            ;;
    esac
}

main "$@"
