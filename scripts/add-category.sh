#!/usr/bin/env bash
# =============================================================================
# Wallzy — Add New Category
#
# Creates a new wallpaper category folder and registers it in categories.json.
#
# Usage:
#   bash scripts/add-category.sh <category-id> [display-name] [emoji] [description]
#
# Examples:
#   bash scripts/add-category.sh cars-bikes
#   bash scripts/add-category.sh cars-bikes "Cars & Bikes" "🏎️" "Sports cars and motorcycles"
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

CAT_ID="${1:-}"
CAT_NAME="${2:-}"
CAT_ICON="${3:-}"
CAT_DESC="${4:-}"

if [ -z "$CAT_ID" ]; then
    echo ""
    echo -e "${BOLD}${CYAN}Wallzy — Add Category${NC}"
    echo -e "${DIM}────────────────────────────────────${NC}"
    echo "Usage: bash scripts/add-category.sh <category-id> [name] [icon] [description]"
    echo ""
    echo "Examples:"
    echo "  bash scripts/add-category.sh cars-bikes"
    echo "  bash scripts/add-category.sh cars-bikes \"Cars & Bikes\" \"🏎️\" \"Sports cars and motorcycles\""
    echo ""
    exit 1
fi

# Sanitize category id
CAT_ID="$(echo "$CAT_ID" | tr '[:upper:]' '[:lower:]' | tr ' _' '--' | tr -cd 'a-z0-9-' | sed 's/-\+/-/g; s/^-//; s/-$//')"

if [ -z "$CAT_ID" ]; then
    echo -e "${RED}✗ Invalid category id.${NC}"
    exit 1
fi

# Auto-fill missing metadata
if [ -z "$CAT_NAME" ]; then
    CAT_NAME="$(echo "$CAT_ID" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')"
fi

if [ -z "$CAT_ICON" ]; then
    # Auto-pick based on keywords
    case "$CAT_ID" in
        *linux*|*ubuntu*|*fedora*|*arch*|*mint*|*debian*) ICON="🐧" ;;
        *car*|*bike*|*motor*) ICON="🏎️" ;;
        *animal*|*cat*|*dog*) ICON="🐾" ;;
        *city*|*urban*) ICON="🏙️" ;;
        *flower*|*plant*) ICON="🌺" ;;
        *winter*|*snow*) ICON="❄️" ;;
        *islam*|*mosque*) ICON="🕌" ;;
        *music*) ICON="🎵" ;;
        *food*) ICON="🍕" ;;
        *sport*) ICON="⚽" ;;
        *) ICON="📁" ;;
    esac
    CAT_ICON="$ICON"
fi

# ─── Paths ───────────────────────────────────────────────────────────────────

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CATEGORIES_FILE="$REPO_ROOT/categories.json"
CATEGORY_DIR="$REPO_ROOT/wallpapers/$CAT_ID"

# ─── Create folder ───────────────────────────────────────────────────────────

if [ -d "$CATEGORY_DIR" ]; then
    echo -e "${YELLOW}▲${NC} Folder already exists: $CATEGORY_DIR"
else
    mkdir -p "$CATEGORY_DIR"
    touch "$CATEGORY_DIR/.gitkeep"
    echo -e "${GREEN}✓${NC} Created folder: wallpapers/$CAT_ID/"
fi

# ─── Update categories.json ──────────────────────────────────────────────────

if [ ! -f "$CATEGORIES_FILE" ]; then
    echo -e "${YELLOW}▲${NC} categories.json not found. Creating..."
    echo "{}" > "$CATEGORIES_FILE"
fi

# Use Python to safely merge JSON
python3 - "$CATEGORIES_FILE" "$CAT_ID" "$CAT_NAME" "$CAT_ICON" "$CAT_DESC" <<'PYEOF'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
cat_id, cat_name, cat_icon, cat_desc = sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]

data = json.loads(path.read_text(encoding="utf-8")) if path.exists() else {}

if cat_id in data:
    print(f"  (existing entry updated)")
else:
    print(f"  (new entry added)")

data[cat_id] = {
    "name": cat_name,
    "icon": cat_icon,
    "description": cat_desc,
}

# Sort keys alphabetically for cleanliness
data = dict(sorted(data.items()))

path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
PYEOF

# ─── Done ────────────────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}Category registered:${NC}"
echo -e "  ID    : ${CYAN}$CAT_ID${NC}"
echo -e "  Name  : $CAT_NAME"
echo -e "  Icon  : $CAT_ICON"
[ -n "$CAT_DESC" ] && echo -e "  Desc  : $CAT_DESC"
echo ""
echo -e "Folder: ${DIM}$CATEGORY_DIR${NC}"
echo ""
echo -e "${DIM}Next:${NC}"
echo -e "  1. Copy wallpapers to: ${CYAN}wallpapers/$CAT_ID/${NC}"
echo -e "  2. Rename (optional):  ${CYAN}bash scripts/rename-wallpapers.sh wallpapers/$CAT_ID${NC}"
echo -e "  3. Rebuild index:      ${CYAN}make index${NC}"
echo ""
