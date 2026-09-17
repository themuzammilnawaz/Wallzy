#!/usr/bin/env python3
"""
Wallzy — Wallpaper Index Generator (dynamic, robust)

Scans wallpapers/ and generates wallpapers.json.
- Any folder in wallpapers/ becomes a category
- Metadata read from categories.json (optional)
- Missing metadata auto-generated
- Never crashes on bad images
- Robust dimension reader (handles WhatsApp / WeChat / Telegram compressed JPEGs)

Curated & developed by Muzammil Nawaz
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
    lower = cat_id.lower()
    for keyword, icon in ICON_HINTS.items():
        if keyword in lower:
            return icon
    return "📁"

def auto_name(cat_id):
    return cat_id.replace("-", " ").replace("_", " ").title()

def load_defined_categories():
    if not CATEGORIES_FILE.exists():
        return {}
    try:
        return json.loads(CATEGORIES_FILE.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        print(f"⚠  categories.json is invalid: {e}")
        return {}
    except Exception as e:
        print(f"⚠  Could not read categories.json: {e}")
        return {}

def discover_categories():
    defined = load_defined_categories()
    categories = {}

    for cat_id, meta in defined.items():
        if not isinstance(meta, dict):
            continue
        categories[cat_id] = {
            "id": cat_id,
            "name": meta.get("name") or auto_name(cat_id),
            "icon": meta.get("icon") or auto_icon(cat_id),
            "description": meta.get("description", ""),
            "count": 0,
            "wallpapers": [],
        }

    if WALLPAPERS_DIR.exists():
        for folder in sorted(WALLPAPERS_DIR.iterdir()):
            if not folder.is_dir():
                continue
            if folder.name.startswith("."):
                continue
            if folder.name in categories:
                continue

            categories[folder.name] = {
                "id": folder.name,
                "name": auto_name(folder.name),
                "icon": auto_icon(folder.name),
                "description": "",
                "count": 0,
                "wallpapers": [],
                "_auto": True,
            }

    return categories

# ─── Robust dimension reader ─────────────────────────────────────────────────
# Handles:
#  - PNG
#  - JPEG (baseline, progressive, all SOF markers, with padding, restart markers)
#  - WebP (VP8, VP8L, VP8X)
#  - GIF (bonus)
#  - BMP (bonus)
# ─────────────────────────────────────────────────────────────────────────────

def read_dimensions(path):
    """Read image dimensions from file header. Returns (w, h) or (None, None)."""
    try:
        with open(path, "rb") as f:
            header = f.read(32)
            if not header:
                return None, None

            # ── PNG ────────────────────────────────────────────────────────
            if header[:8] == b"\x89PNG\r\n\x1a\n":
                if len(header) >= 24:
                    w = struct.unpack(">I", header[16:20])[0]
                    h = struct.unpack(">I", header[20:24])[0]
                    if w > 0 and h > 0:
                        return w, h
                # Fallback: read IHDR chunk properly
                f.seek(16)
                w = struct.unpack(">I", f.read(4))[0]
                h = struct.unpack(">I", f.read(4))[0]
                return w, h

            # ── JPEG ───────────────────────────────────────────────────────
            if header[:2] == b"\xff\xd8":
                return _read_jpeg_dimensions(f)

            # ── WebP ───────────────────────────────────────────────────────
            if header[:4] == b"RIFF" and header[8:12] == b"WEBP":
                return _read_webp_dimensions(f)

            # ── GIF (bonus) ────────────────────────────────────────────────
            if header[:6] in (b"GIF87a", b"GIF89a"):
                if len(header) >= 10:
                    w = struct.unpack("<H", header[6:8])[0]
                    h = struct.unpack("<H", header[8:10])[0]
                    return w, h

            # ── BMP (bonus) ────────────────────────────────────────────────
            if header[:2] == b"BM":
                f.seek(18)
                w = struct.unpack("<i", f.read(4))[0]
                h = struct.unpack("<i", f.read(4))[0]
                return abs(w), abs(h)

    except Exception:
        pass
    return None, None

def _read_jpeg_dimensions(f):
    """
    Scan JPEG markers to find SOF (Start of Frame) marker.
    Robust against:
      - padding bytes between markers
      - restart markers (0xFFD0–0xFFD7)
      - multiple scans
      - progressive JPEGs
    """
    try:
        f.seek(0)

        # Must start with SOI
        if f.read(2) != b"\xff\xd8":
            return None, None

        SOF_MARKERS = {
            0xC0, 0xC1, 0xC2, 0xC3,   # baseline, extended, progressive, lossless
            0xC5, 0xC6, 0xC7,          # differential
            0xC9, 0xCA, 0xCB,          # arithmetic
            0xCD, 0xCE, 0xCF,
        }

        while True:
            # Find next marker
            byte = f.read(1)
            if not byte:
                return None, None

            # Skip padding — wait until we hit 0xFF
            if byte != b"\xff":
                continue

            # Skip additional 0xFF bytes (padding)
            marker = f.read(1)
            while marker == b"\xff":
                marker = f.read(1)

            if not marker:
                return None, None

            marker_byte = marker[0]

            # Restart markers (0xD0–0xD7) and SOI/EOI have no payload
            if 0xD0 <= marker_byte <= 0xD9:
                continue

            # Standalone markers
            if marker_byte == 0x01:
                continue

            # Read segment length (2 bytes, big-endian, includes the 2 length bytes)
            length_bytes = f.read(2)
            if len(length_bytes) < 2:
                return None, None
            length = struct.unpack(">H", length_bytes)[0]

            # SOF marker found — read dimensions
            if marker_byte in SOF_MARKERS:
                # Segment layout: length(2) precision(1) height(2) width(2) ...
                # We've already consumed length(2), so read: precision(1), height(2), width(2)
                f.read(1)  # precision
                h = struct.unpack(">H", f.read(2))[0]
                w = struct.unpack(">H", f.read(2))[0]
                if w > 0 and h > 0:
                    return w, h
                return None, None

            # Skip to next marker
            f.seek(length - 2, 1)

    except Exception:
        return None, None

def _read_webp_dimensions(f):
    """Read WebP dimensions (VP8, VP8L, VP8X)."""
    try:
        f.seek(12)
        chunk = f.read(4)

        if chunk == b"VP8 ":
            # Lossy WebP
            f.read(6)  # skip 3 bytes frame tag + 3 bytes start code
            w_bytes = f.read(2)
            h_bytes = f.read(2)
            w = struct.unpack("<H", w_bytes)[0] & 0x3FFF
            h = struct.unpack("<H", h_bytes)[0] & 0x3FFF
            return w, h

        if chunk == b"VP8L":
            # Lossless WebP
            f.read(1)  # signature byte 0x2F
            b = f.read(4)
            if len(b) < 4:
                return None, None
            w = ((b[1] & 0x3F) << 8 | b[0]) + 1
            h = ((b[3] & 0x0F) << 10 | b[2] << 2 | (b[1] & 0xC0) >> 6) + 1
            return w, h

        if chunk == b"VP8X":
            # Extended WebP
            f.read(4)  # skip flags + reserved
            w = int.from_bytes(f.read(3), "little") + 1
            h = int.from_bytes(f.read(3), "little") + 1
            return w, h

    except Exception:
        pass
    return None, None

def derive_name(stem):
    return " ".join(word.capitalize() for word in stem.replace("-", " ").replace("_", " ").split())

def human_size(num_bytes):
    for unit in ("B", "KB", "MB", "GB"):
        if num_bytes < 1024:
            return f"{num_bytes:.1f} {unit}" if unit != "B" else f"{num_bytes} {unit}"
        num_bytes /= 1024
    return f"{num_bytes:.1f} TB"

# ─── Main ────────────────────────────────────────────────────────────────────

def main():
    print("📊 Wallzy — Index Generator")
    print("────────────────────────────────────")

    if not WALLPAPERS_DIR.exists():
        print(f"✗ Wallpapers directory not found: {WALLPAPERS_DIR}")
        print("  Create it: mkdir -p wallpapers/linux-distro")
        sys.exit(1)

    categories = discover_categories()

    if not categories:
        print("⚠  No categories found.")
        print("   Create at least one: mkdir -p wallpapers/nature-landscapes")

    total = 0
    total_size = 0
    missing_dims = 0
    auto_detected = []

    for cat_id, cat in categories.items():
        cat_dir = WALLPAPERS_DIR / cat_id
        wallpapers = []

        if cat_dir.exists() and cat_dir.is_dir():
            try:
                entries = sorted(cat_dir.iterdir())
            except Exception as e:
                print(f"  ⚠ Could not read {cat_dir}: {e}")
                entries = []

            for img_path in entries:
                try:
                    if not img_path.is_file():
                        continue
                    if img_path.suffix.lower() not in IMAGE_EXTENSIONS:
                        continue

                    w, h = read_dimensions(img_path)
                    rel_path = img_path.as_posix()
                    thumb_path = (THUMBNAILS_DIR / cat_id / f"{img_path.stem}.webp").as_posix()
                    size = img_path.stat().st_size

                    # Determine dimensions string
                    if w and h:
                        dims_str = f"{w}×{h}"
                    else:
                        dims_str = "—"
                        missing_dims += 1

                    wallpapers.append({
                        "id": f"{cat_id}::{img_path.stem}",
                        "file": rel_path,
                        "name": derive_name(img_path.stem),
                        "thumbnail": thumb_path,
                        "size": size,
                        "sizeHuman": human_size(size),
                        "dimensions": dims_str,
                        "width": w,
                        "height": h,
                    })
                    total += 1
                    total_size += size
                except Exception as e:
                    print(f"  ⚠ Skipped {img_path.name}: {e}")
                    continue

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
    if missing_dims:
        print(f"  ⚠ Could not read dimensions for {missing_dims} image(s)")
    print(f"  Written:    {OUTPUT_FILE}")

    if auto_detected:
        print("")
        print("  💡 Auto-detected (add to categories.json for custom icon):")
        for cid in auto_detected:
            print(f"     - {cid}")

    print("✓ Done.")

if __name__ == "__main__":
    main()
