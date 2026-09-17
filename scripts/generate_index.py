#!/usr/bin/env python3
"""
Wallzy — Wallpaper Index Generator (Dynamic)

Automatically discovers categories from the wallpapers/ directory.
Reads optional metadata from categories.json.

- Any folder in wallpapers/ becomes a category
- Missing metadata is auto-generated (name, icon, description)
- Adding a new category = just create a folder + push

Curated & developed by Muzammil Nawaz
https://github.com/themuzammilnawaz/Wallzy
"""

import json
import struct
import sys
from datetime import datetime, timezone
from pathlib import Path

# ─── Configuration ───────────────────────────────────────────────────────────

WALLPAPERS_DIR = Path("wallpapers")
THUMBNAILS_DIR = Path("thumbnails")
CATEGORIES_FILE = Path("categories.json")
OUTPUT_FILE = Path("wallpapers.json")

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".bmp", ".tiff", ".tif"}

# Keyword → emoji mapping for auto-generating icons
ICON_HINTS = {
    "linux": "🐧", "ubuntu": "🐧", "fedora": "🐧", "arch": "🐧", "mint": "🐧",
    "debian": "🐧", "manjaro": "🐧", "pop": "🐧",
    "nature": "🌿", "landscape": "🌿", "forest": "🌲", "mountain": "⛰️",
    "ocean": "🌊", "sea": "🌊", "beach": "🏖️", "sky": "☁️",
    "space": "🌌", "galaxy": "🌌", "star": "⭐", "planet": "🪐",
    "dark": "🌑", "black": "🌑", "amoled": "🌑", "night": "🌙",
    "anime": "🌸", "manga": "🌸", "waifu": "🌸",
    "minimal": "🎨", "abstract": "🎨", "geometric": "📐",
    "4k": "🖥️", "8k": "🖥️", "hd": "🖥️", "highres": "🖥️",
    "movie": "🎬", "film": "🎬", "game": "🎮", "gaming": "🎮",
    "car": "🏎️", "bike": "🏍️", "motorcycle": "🏍️",
    "islamic": "🕌", "mosque": "🕌", "quran": "📖", "urdu": "✒️",
    "animal": "🐾", "cat": "🐱", "dog": "🐶", "bird": "🐦",
    "city": "🏙️", "urban": "🏙️", "building": "🏢",
    "food": "🍕", "coffee": "☕",
    "sport": "⚽", "football": "⚽",
    "music": "🎵", "art": "🎨",
    "text": "🔤", "typography": "🔤", "quote": "💬",
    "flower": "🌺", "plant": "🌱",
    "winter": "❄️", "snow": "❄️", "autumn": "🍂",
    "sunset": "🌅", "sunrise": "🌅",
    "water": "💧", "rain": "🌧️",
}

# ─── Helpers ─────────────────────────────────────────────────────────────────

def auto_icon(cat_id):
    """Pick a fitting emoji based on category id keywords."""
    lower = cat_id.lower()
    for keyword, icon in ICON_HINTS.items():
        if keyword in lower:
            return icon
    return "📁"

def auto_name(cat_id):
    """Turn 'cars-bikes' into 'Cars Bikes'."""
    return cat_id.replace("-", " ").replace("_", " ").title()

def load_defined_categories():
    """Load category metadata from categories.json (if present)."""
    if not CATEGORIES_FILE.exists():
        return {}
    try:
        return json.loads(CATEGORIES_FILE.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        print(f"⚠  categories.json is invalid: {e}")
        print("   Continuing with auto-detection only.")
        return {}

def discover_categories():
    """
    Build the full category list:
    1. Start with categories.json entries (even if folder is empty)
    2. Add any folder found in wallpapers/ that isn't already defined
    3. Skip hidden folders (starting with .)
    """
    defined = load_defined_categories()
    categories = {}

    # 1. Pre-populate from categories.json
    for cat_id, meta in defined.items():
        categories[cat_id] = {
            "id": cat_id,
            "name": meta.get("name") or auto_name(cat_id),
            "icon": meta.get("icon") or auto_icon(cat_id),
            "description": meta.get("description", ""),
            "count": 0,
            "wallpapers": [],
        }

    # 2. Scan wallpapers/ for folders
    if WALLPAPERS_DIR.exists():
        for folder in sorted(WALLPAPERS_DIR.iterdir()):
            if not folder.is_dir():
                continue
            if folder.name.startswith("."):
                continue
            if folder.name in categories:
                continue  # already defined

            # New folder — auto-generate metadata
            categories[folder.name] = {
                "id": folder.name,
                "name": auto_name(folder.name),
                "icon": auto_icon(folder.name),
                "description": "",
                "count": 0,
                "wallpapers": [],
                "_auto": True,  # mark as auto-detected
            }

    return categories

def read_dimensions(path):
    """Read image dimensions from header (no external deps)."""
    try:
        with open(path, "rb") as f:
            header = f.read(32)

            # PNG
            if header[:8] == b"\x89PNG\r\n\x1a\n":
                w = struct.unpack(">I", header[16:20])[0]
                h = struct.unpack(">I", header[20:24])[0]
                return w, h

            # JPEG
            if header[:2] == b"\xff\xd8":
                f.seek(0)
                while True:
                    marker = f.read(2)
                    if not marker or len(marker) < 2 or marker[0] != 0xFF:
                        break
                    if marker[1] in (0xC0, 0xC1, 0xC2, 0xC3):
                        f.read(3)
                        h = struct.unpack(">H", f.read(2))[0]
                        w = struct.unpack(">H", f.read(2))[0]
                        return w, h
                    length = struct.unpack(">H", f.read(2))[0]
                    f.seek(length - 2, 1)

            # WebP
            if header[:4] == b"RIFF" and header[8:12] == b"WEBP":
                f.seek(12)
                chunk = f.read(4)
                if chunk == b"VP8 ":
                    f.read(6)
                    w = struct.unpack("<H", f.read(2))[0] & 0x3FFF
                    h = struct.unpack("<H", f.read(2))[0] & 0x3FFF
                    return w, h
                elif chunk == b"VP8L":
                    f.read(1)
                    b = f.read(4)
                    w = ((b[1] & 0x3F) << 8 | b[0]) + 1
                    h = ((b[3] & 0x0F) << 10 | b[2] << 2 | (b[1] & 0xC0) >> 6) + 1
                    return w, h
                elif chunk == b"VP8X":
                    f.read(4)
                    w = int.from_bytes(f.read(3), "little") + 1
                    h = int.from_bytes(f.read(3), "little") + 1
                    return w, h
    except Exception:
        pass
    return None, None

def derive_name(stem):
    """Convert 'ubuntu-001' → 'Ubuntu 001'."""
    return " ".join(word.capitalize() for word in stem.replace("-", " ").replace("_", " ").split())

def human_size(num_bytes):
    for unit in ("B", "KB", "MB", "GB"):
        if num_bytes < 1024:
            return f"{num_bytes:.1f} {unit}" if unit != "B" else f"{num_bytes} {unit}"
        num_bytes /= 1024
    return f"{num_bytes:.1f} TB"

# ─── Main ────────────────────────────────────────────────────────────────────

def main():
    print("📊 Wallzy — Index Generator (dynamic)")
    print("────────────────────────────────────")

    if not WALLPAPERS_DIR.exists():
        print(f"✗ Wallpapers directory not found: {WALLPAPERS_DIR}")
        sys.exit(1)

    categories = discover_categories()

    if not categories:
        print("⚠  No categories found. Create at least one folder in wallpapers/")
        print("   Example: mkdir -p wallpapers/nature-landscapes")

    total = 0
    total_size = 0
    auto_detected = []

    for cat_id, cat in categories.items():
        cat_dir = WALLPAPERS_DIR / cat_id
        wallpapers = []

        if cat_dir.exists():
            for img_path in sorted(cat_dir.iterdir()):
                if not img_path.is_file():
                    continue
                if img_path.suffix.lower() not in IMAGE_EXTENSIONS:
                    continue

                w, h = read_dimensions(img_path)
                rel_path = img_path.as_posix()
                thumb_path = (THUMBNAILS_DIR / cat_id / f"{img_path.stem}.webp").as_posix()
                size = img_path.stat().st_size

                wallpapers.append({
                    "id": f"{cat_id}::{img_path.stem}",
                    "file": rel_path,
                    "name": derive_name(img_path.stem),
                    "thumbnail": thumb_path,
                    "size": size,
                    "sizeHuman": human_size(size),
                    "dimensions": f"{w}×{h}" if w and h else "unknown",
                    "width": w,
                    "height": h,
                })
                total += 1
                total_size += size

        cat["count"] = len(wallpapers)
        cat["wallpapers"] = wallpapers

        if cat.pop("_auto", False):
            auto_detected.append(cat_id)

        status = f"{len(wallpapers):>5} wallpapers" if wallpapers else "  (empty)"
        print(f"  {cat['icon']} {cat['name']:<24} {status}")

    index = {
        "version": "1.0.0",
        "generated": datetime.now(timezone.utc).isoformat(),
        "total": total,
        "totalSize": total_size,
        "totalSizeHuman": human_size(total_size),
        "categoryCount": len(categories),
        "curated_by": "Muzammil Nawaz",
        "repository": "https://github.com/themuzammilnawaz/Wallzy",
        "gallery": "https://themuzammilnawaz.github.io/Wallzy/",
        "categories": categories,
    }

    OUTPUT_FILE.write_text(json.dumps(index, indent=2, ensure_ascii=False), encoding="utf-8")

    print("────────────────────────────────────")
    print(f"  Categories: {len(categories)}")
    print(f"  Total:      {total} wallpapers ({human_size(total_size)})")
    print(f"  Written:    {OUTPUT_FILE}")

    if auto_detected:
        print("")
        print("  💡 Auto-detected categories (add to categories.json for custom icon/description):")
        for cat_id in auto_detected:
            print(f"     - {cat_id}")

    print("✓ Done.")

if __name__ == "__main__":
    main()
