#!/usr/bin/env bash
# =============================================================================
# Wallzy — WebP Thumbnail Generator
# Generates 400px-wide WebP thumbnails for all wallpapers.
#
# Requires: ImageMagick (magick or convert)
#
# Curated & developed by Muzammil Nawaz
# https://github.com/themuzammilnawaz/Wallzy
# =============================================================================

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────

THUMB_WIDTH="${THUMB_WIDTH:-400}"
QUALITY="${QUALITY:-80}"
INPUT_DIR="${1:-wallpapers}"
OUTPUT_DIR="${2:-thumbnails}"
PARALLEL="${PARALLEL:-$(nproc 2>/dev/null || echo 4)}"

# ─── Colors ──────────────────────────────────────────────────────────────────

if [ -t 1 ]; then
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    BLUE='\033[0;34m'
    DIM='\033[2m'
    NC='\033[0m'
else
    GREEN='' YELLOW='' RED='' BLUE='' DIM='' NC=''
fi

# ─── Find ImageMagick ────────────────────────────────────────────────────────

if command -v magick &>/dev/null; then
    MAGICK="magick"
elif command -v convert &>/dev/null; then
    MAGICK="convert"
else
    echo -e "${RED}✗ ImageMagick is not installed.${NC}"
    echo "  Install it with:"
    echo "    Debian/Ubuntu:  sudo apt install imagemagick"
    echo "    Fedora:         sudo dnf install ImageMagick"
    echo "    Arch:           sudo pacman -S imagemagick"
    exit 1
fi

echo -e "${BLUE}◆${NC} Wallzy — Thumbnail Generator"
echo -e "${DIM}  ImageMagick: $MAGICK${NC}"
echo -e "${DIM}  Width: ${THUMB_WIDTH}px · Quality: ${QUALITY} · Parallel: ${PARALLEL}${NC}"
echo ""

# ─── Count ───────────────────────────────────────────────────────────────────

TOTAL=$(find "$INPUT_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" -o -iname "*.tiff" \) 2>/dev/null | wc -l)

if [ "$TOTAL" -eq 0 ]; then
    echo -e "${YELLOW}▲${NC} No wallpapers found in $INPUT_DIR"
    exit 0
fi

echo -e "${DIM}  Found $TOTAL images${NC}"
echo ""

# ─── Generate ────────────────────────────────────────────────────────────────

export MAGICK THUMB_WIDTH QUALITY INPUT_DIR OUTPUT_DIR

generate_one() {
    local img="$1"
    local rel="${img#$INPUT_DIR/}"
    local out="$OUTPUT_DIR/${rel%.*}.webp"

    mkdir -p "$(dirname "$out")"

    # Skip if thumbnail is newer than source
    if [ -f "$out" ] && [ "$out" -nt "$img" ]; then
        return 0
    fi

    if $MAGICK "$img" -resize "${THUMB_WIDTH}x" -quality "$QUALITY" -strip "$out" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $rel"
    else
        echo -e "  ${RED}✗${NC} $rel ${DIM}(failed)${NC}"
    fi
}

export -f generate_one

find "$INPUT_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" -o -iname "*.tiff" \) -print0 \
    | xargs -0 -P "$PARALLEL" -I {} bash -c 'generate_one "$@"' _ {}

echo ""
echo -e "${GREEN}✓${NC} Thumbnails generated in $OUTPUT_DIR/"
