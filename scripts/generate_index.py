#!/usr/bin/env python3
"""
Wallzy — Wallpaper Index Generator

SOURCE OF TRUTH: wallpapers/ folder structure
  - Every first-level folder inside wallpapers/ = one category
  - New folder   → new category appears automatically
  - Deleted folder → category disappears automatically
  - Nested subfolders inside a category are scanned recursively

categories.json is ONLY for optional metadata (name, icon, description).
If categories.json has entries without a matching folder, they are ignored.
If a folder exists without a categories.json entry, metadata is auto-generated.

Curated & developed by Muzammil Nawaz
"""

import json
import struct
import sys
from datetime import datetime, timezone
from pathlib import Path

# ─── Config ──────────────────────────────────────────────────────────────────

WALLPAPERS_DIR = Path("wallpapers")
THUMBNAILS_DIR = Path("thumbnails")
CATEGORIES_FILE = Path("categories.json")
OUTPUT_FILE = Path("wallpapers.json")

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".bmp", ".tiff", ".tif"}

ICON_HINTS = {
    "linux": "🐧", "ubuntu": "🐧", "fedora": "🐧", "arch": "🐧", "mint": "🐧",
    "zorin": "🐧", "debian": "🐧", "manjaro": "🐧", "pop": "🐧",
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
    lower = cat_id.lower()
    for keyword, icon in ICON_HINTS.items():
        if keyword in lower:
            return icon
    return "📁"

def auto_name(cat_id):
    return cat_id.replace("-", " ").replace("_", " ").title()

def load_category_metadata():
    """Load categories.json — used ONLY for optional metadata overrides."""
    if not CATEGORIES_FILE.exists():
        return {}
    try:
        data = json.loads(CATEGORIES_FILE.read_text(encoding="utf-8"))
        return {k: v for k, v in data.items() if isinstance(v, dict)}
    except Exception as e:
        print(f"⚠  categories.json unreadable: {e}")
        return {}

def discover_categories():
    """
    Scan wallpapers/ for first-level folders.
    Folder structure is the SOURCE OF TRUTH.
    categories.json only provides optional metadata for folders that exist.
    """
    metadata = load_category_metadata()
    categories = {}

    if not WALLPAPERS_DIR.exists():
        return categories

    for folder in sorted(WALLPAPERS_DIR.iterdir()):
        if not folder.is_dir():
            continue
        if folder.name.startswith("."):
            continue

        cat_id = folder.name
        meta = metadata.get(cat_id, {})

        categories[cat_id] = {
            "id": cat_id,
            "name": meta.get("name") or auto_name(cat_id),
            "icon": meta.get("icon") or auto_icon(cat_id),
            "description": meta.get("description", ""),
            "count": 0,
            "wallpapers": [],
        }

    return categories

# ─── Image dimensions (robust) ───────────────────────────────────────────────

def read_dimensions(path):
    try:
        with open(path, "rb") as f:
            header = f.read(32)
            if not header:
                return None, None

            if header[:8] == b"\x89PNG\r\n\x1a\n":
                f.seek(16)
                w = struct.unpack(">I", f.read(4))[0]
                h = struct.unpack(">I", f.read(4))[0]
                return w, h

            if header[:2] == b"\xff\xd8":
                return _read_jpeg_dimensions(f)

            if header[:4] == b"RIFF" and header[8:12] == b"WEBP":
                return _read_webp_dimensions(f)

            if header[:6] in (b"GIF87a", b"GIF89a"):
                w = struct.unpack("<H", header[6:8])[0]
                h = struct.unpack("<H", header[8:10])[0]
                return w, h

            if header[:2] == b"BM":
                f.seek(18)
                w = struct.unpack("<i", f.read(4))[0]
                h = struct.unpack("<i", f.read(4))[0]
                return abs(w), abs(h)
    except Exception:
        pass
    return None, None

def _read_jpeg_dimensions(f):
    try:
        f.seek(0)
        if f.read(2) != b"\xff\xd8":
            return None, None

        SOF = {0xC0, 0xC1, 0xC2, 0xC3, 0xC5, 0xC6, 0xC7,
               0xC9, 0xCA, 0xCB, 0xCD, 0xCE, 0xCF}

        while True:
            b = f.read(1)
            if not b:
                return None, None
            if b != b"\xff":
                continue
            m = f.read(1)
            while m == b"\xff":
                m = f.read(1)
            if not m:
                return None, None
            mb = m[0]
            if 0xD0 <= mb <= 0xD9 or mb == 0x01:
                continue
            lb = f.read(2)
            if len(lb) < 2:
                return None, None
            length = struct.unpack(">H", lb)[0]
            if mb in SOF:
                f.read(1)
                h = struct.unpack(">H", f.read(2))[0]
                w = struct.unpack(">H", f.read(2))[0]
                return (w, h) if w and h else (None, None)
            f.seek(length - 2, 1)
    except Exception:
        return None, None

def _read_webp_dimensions(f):
    try:
        f.seek(12)
        chunk = f.read(4)
        if chunk == b"VP8 ":
            f.read(6)
            w = struct.unpack("<H", f.read(2))[0] & 0x3FFF
            h = struct.unpack("<H", f.read(2))[0] & 0x3FFF
            return w, h
        if chunk == b"VP8L":
            f.read(1)
            b = f.read(4)
            if len(b) < 4:
                return None, None
            w = ((b[1] & 0x3F) << 8 | b[0]) + 1
            h = ((b[3] & 0x0F) << 10 | b[2] << 2 | (b[1] & 0xC0) >> 6) + 1
            return w, h
        if chunk == b"VP8X":
            f.read(4)
            w = int.from_bytes(f.read(3), "little") + 1
            h = int.from_bytes(f.read(3), "little") + 1
            return w, h
    except Exception:
        pass
    return None, None

def human_size(n):
    for unit in ("B", "KB", "MB", "GB"):
        if n < 1024:
            return f"{n:.1f} {unit}" if unit != "B" else f"{n} {unit}"
        n /= 1024
    return f"{n:.1f} TB"

def pretty_name(stem):
    return " ".join(
        w.capitalize() for w in stem.replace("-", " ").replace("_", " ").split()
    )

# ─── Main ────────────────────────────────────────────────────────────────────

def main():
    print("📊 Wallzy — Index Generator")
    print("────────────────────────────────────")

    if not WALLPAPERS_DIR.exists():
        print(f"✗ {WALLPAPERS_DIR} not found.")
        print("  Create it with at least one category folder:")
        print("    mkdir -p wallpapers/nature-landscapes")
        sys.exit(1)

    categories = discover_categories()

    if not categories:
        print("⚠  No category folders found inside wallpapers/")
        print("   Create at least one: mkdir -p wallpapers/nature-landscapes")

    total = 0
    total_size = 0
    missing_dims = 0
    non_empty_categories = []

    for cat_id, cat in categories.items():
        cat_dir = WALLPAPERS_DIR / cat_id
        wallpapers = []

        try:
            all_files = sorted(cat_dir.rglob("*"))
        except Exception as e:
            print(f"  ⚠ Cannot read {cat_dir}: {e}")
            all_files = []

        for img in all_files:
            try:
                if not img.is_file():
                    continue
                if img.suffix.lower() not in IMAGE_EXTENSIONS:
                    continue

                rel = img.relative_to(cat_dir)
                subfolders = list(rel.parts[:-1])

                base = pretty_name(img.stem)
                if subfolders:
                    prefix = " / ".join(
                        s.replace("-", " ").replace("_", " ").title()
                        for s in subfolders
                    )
                    display_name = f"{prefix} — {base}"
                else:
                    display_name = base

                thumb_rel = rel.with_suffix(".webp")
                thumb_path = (THUMBNAILS_DIR / cat_id / thumb_rel).as_posix()

                wp_id = f"{cat_id}::{'/'.join(rel.parts)}"

                w, h = read_dimensions(img)
                size = img.stat().st_size
                dims = f"{w}×{h}" if w and h else "—"
                if not (w and h):
                    missing_dims += 1

                wallpapers.append({
                    "id": wp_id,
                    "file": img.as_posix(),
                    "name": display_name,
                    "thumbnail": thumb_path,
                    "subfolder": subfolders[0] if subfolders else None,
                    "subfolders": subfolders,
                    "size": size,
                    "sizeHuman": human_size(size),
                    "dimensions": dims,
                    "width": w,
                    "height": h,
                })
                total += 1
                total_size += size
            except Exception as e:
                print(f"  ⚠ Skipped {img.name}: {e}")

        cat["count"] = len(wallpapers)
        cat["wallpapers"] = wallpapers
        if wallpapers:
            non_empty_categories.append(cat_id)

        status = f"{len(wallpapers):>5} wallpapers" if wallpapers else "  (empty)"
        print(f"  {cat['icon']} {cat['name']:<24} {status}")

    index = {
        "version": "1.0.0",
        "generated": datetime.now(timezone.utc).isoformat(),
        "total": total,
        "totalSize": total_size,
        "totalSizeHuman": human_size(total_size),
        "categoryCount": len(categories),
        "emptyCategories": len(categories) - len(non_empty_categories),
        "curated_by": "Muzammil Nawaz",
        "repository": "https://github.com/themuzammilnawaz/Wallzy",
        "gallery": "https://themuzammilnawaz.github.io/Wallzy/",
        "categories": categories,
    }

    OUTPUT_FILE.write_text(
        json.dumps(index, indent=2, ensure_ascii=False), encoding="utf-8"
    )

    print("────────────────────────────────────")
    print(f"  Categories (from folders): {len(categories)}")
    print(f"  Total:                     {total} wallpapers ({human_size(total_size)})")
    if missing_dims:
        print(f"  ⚠ Unknown dimensions:      {missing_dims}")
    print(f"  Written:                   {OUTPUT_FILE}")
    print("✓ Done.")

if __name__ == "__main__":
    main()
  
