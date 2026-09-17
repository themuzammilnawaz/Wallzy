#!/usr/bin/env bash
# =============================================================================
# Wallzy — Bulk Wallpaper Renamer
#
# Renames randomly-named wallpapers (IMG_1234.jpg, DSC_001.png, etc.)
# into clean, sequential, descriptive names.
#
# Usage:
#   bash scripts/rename-wallpapers.sh <category-folder> [prefix] [--dry-run]
#
# Examples:
#   bash scripts/rename-wallpapers.sh wallpapers/linux-distro ubuntu
#   bash scripts/rename-wallpapers.sh wallpapers/nature-landscapes nature --dry-run
#
# Curated & developed by Muzammil Nawaz
# =============================================================================

set -euo pipefail

# ─── Colors ──────────────────────────────────────────────────────────────────

if [ -t 1 ]; then
    GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'
    BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'
else
    GREEN=''; YELLOW=''; RED=''; BLUE=''; CYAN=''; BOLD=''; DIM=''; NC=''
fi

# ─── Args ────────────────────────────────────────────────────────────────────

CATEGORY_DIR=""
PREFIX=""
DRY_RUN=false

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --help|-h)
            echo "Usage: bash rename-wallpapers.sh <folder> [prefix] [--dry-run]"
            exit 0
            ;;
        *)
            if [ -z "$CATEGORY_DIR" ]; then
                CATEGORY_DIR="$arg"
            elif [ -z "$PREFIX" ]; then
                PREFIX="$arg"
            fi
            ;;
    esac
done

if [ -z "$CATEGORY_DIR" ]; then
    echo "Usage: bash rename-wallpapers.sh <folder> [prefix] [--dry-run]"
    echo "Example: bash rename-wallpapers.sh wallpapers/linux-distro ubuntu"
    exit 1
fi

if [ ! -d "$CATEGORY_DIR" ]; then
    echo -e "${RED}✗ Directory not found:${NC} $CATEGORY_DIR"
    exit 1
fi

# Default prefix = folder name
if [ -z "$PREFIX" ]; then
    PREFIX="$(basename "$CATEGORY_DIR")"
fi

# Sanitize prefix: lowercase, only a-z0-9 and hyphens
PREFIX="$(echo "$PREFIX" | tr '[:upper:]' '[:lower:]' | tr ' _' '--' | tr -cd 'a-z0-9-' | sed 's/-\+/-/g; s/^-//; s/-$//')"

# ─── Count ───────────────────────────────────────────────────────────────────

mapfile -t FILES < <(find "$CATEGORY_DIR" -maxdepth 1 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) \
    | sort)

TOTAL="${#FILES[@]}"

if [ "$TOTAL" -eq 0 ]; then
    echo -e "${YELLOW}▲${NC} No images found in $CATEGORY_DIR"
    exit 0
fi

# ─── Header ──────────────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}${CYAN}Wallzy — Bulk Renamer${NC}"
echo -e "${DIM}────────────────────────────────────${NC}"
echo -e "  Folder  : $CATEGORY_DIR"
echo -e "  Prefix  : $PREFIX"
echo -e "  Files   : $TOTAL"
if [ "$DRY_RUN" = true ]; then
    echo -e "  Mode    : ${YELLOW}DRY RUN (no changes)${NC}"
fi
echo ""

# ─── Rename ──────────────────────────────────────────────────────────────────

PAD="${#TOTAL}"   # number of digits needed
[ "$PAD" -lt 3 ] && PAD=3

COUNTER=1
RENAMED=0
SKIPPED=0

# Use temp names to avoid collisions
declare -a TMP_NAMES

for file in "${FILES[@]}"; do
    dir="$(dirname "$file")"
    ext="$(echo "${file##*.}" | tr '[:upper:]' '[:lower:]')"
    num=$(printf "%0${PAD}d" "$COUNTER")
    new_name="${PREFIX}-${num}.${ext}"
    new_path="$dir/$new_name"

    # Skip if already correctly named
    if [ "$(basename "$file")" = "$new_name" ]; then
        echo -e "  ${DIM}· $new_name (already correct)${NC}"
        COUNTER=$((COUNTER + 1))
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${DIM}→${NC} $(basename "$file") ${DIM}→${NC} $new_name"
    else
        # Two-step rename (temp) to avoid conflicts
        tmp="$dir/.wallzy-tmp-${COUNTER}-$$"
        mv "$file" "$tmp"
        mv "$tmp" "$new_path"
        echo -e "  ${GREEN}✓${NC} $(basename "$file") ${DIM}→${NC} $new_name"
    fi

    RENAMED=$((RENAMED + 1))
    COUNTER=$((COUNTER + 1))
done

# ─── Done ────────────────────────────────────────────────────────────────────

echo ""
echo -e "${DIM}────────────────────────────────────${NC}"

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}▲${NC} Dry run complete. ${BOLD}$RENAMED${NC} file(s) would be renamed."
    echo -e "   Run without ${CYAN}--dry-run${NC} to apply."
else
    echo -e "${GREEN}✓${NC} Renamed ${BOLD}$RENAMED${NC} file(s), skipped $SKIPPED."
    echo ""
    echo -e "${DIM}Next:${NC}  make index && make thumbs"
fi
echo ""
