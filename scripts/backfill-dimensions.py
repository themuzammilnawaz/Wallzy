#!/usr/bin/env python3
"""
Wallzy — Backfill Dimensions in wallpapers.json

Re-scans all wallpaper files and updates dimensions in wallpapers.json
without regenerating the entire index. Useful when the index was created
with an older version of generate_index.py.

Usage:
    python3 scripts/backfill-dimensions.py
"""

import json
import sys
from pathlib import Path

# Import the robust reader from generate_index
sys.path.insert(0, str(Path(__file__).parent))
try:
    from generate_index import read_dimensions
except ImportError:
    print("✗ Could not import read_dimensions from generate_index.py")
    print("  Make sure scripts/generate_index.py exists.")
    sys.exit(1)

INDEX_FILE = Path("wallpapers.json")

def main():
    if not INDEX_FILE.exists():
        print(f"✗ {INDEX_FILE} not found.")
        sys.exit(1)

    data = json.loads(INDEX_FILE.read_text(encoding="utf-8"))

    fixed = 0
    still_broken = 0
    total = 0

    for cat_id, cat in data.get("categories", {}).items():
        for wp in cat.get("wallpapers", []):
            total += 1
            file_path = Path(wp.get("file", ""))

            if not file_path.exists():
                continue

            w, h = read_dimensions(file_path)

            if w and h:
                if wp.get("dimensions") in ("unknown", "—", None) or wp.get("width") is None:
                    wp["width"] = w
                    wp["height"] = h
                    wp["dimensions"] = f"{w}×{h}"
                    fixed += 1
                    print(f"  ✓ {file_path.name} → {w}×{h}")
            else:
                still_broken += 1
                print(f"  ⚠ {file_path.name} → still unknown")

    INDEX_FILE.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")

    print("")
    print(f"  Total wallpapers: {total}")
    print(f"  Fixed:            {fixed}")
    print(f"  Still unknown:    {still_broken}")
    print(f"  Written:          {INDEX_FILE}")

if __name__ == "__main__":
    main()
