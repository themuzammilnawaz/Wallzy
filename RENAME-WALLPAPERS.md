# Renaming Wallpapers

If your wallpapers have random names like `IMG_1234.jpg`, `DSC_0056.png`, or
`wallpaper (1).jpg`, you can clean them up in one command.

Renaming is **optional** but **recommended** because:

- The gallery shows filenames as titles
- Search works better with descriptive names
- Users can tell what a wallpaper is before downloading
- It looks professional

---

## Quick Usage

```bash
# Preview what will happen (no changes)
bash scripts/rename-wallpapers.sh wallpapers/linux-distro ubuntu --dry-run

# Apply the rename
bash scripts/rename-wallpapers.sh wallpapers/linux-distro ubuntu
```

Or via `make`:

```
make rename DIR=wallpapers/linux-distro PREFIX=ubuntu
```

---

## What It Does

```
BEFORE                              AFTER
─────────────────────────────       ──────────────────────────
IMG_1234.jpg                    →   ubuntu-001.jpg
DSC_0056.png                    →   ubuntu-002.png
wallpaper (1).jpg               →   ubuntu-003.jpg
photo-2024-07-15.jpg            →   ubuntu-004.jpg
Screenshot from 2024-01-01.png  →   ubuntu-005.png
Screenshot_20240101_120000.png  →   ubuntu-006.png
```

Number of digits auto-adjusts:

- 1–999 files → `001`, `002`, ...
- 1000+ files → `0001`, `0002`, ...

---

## Examples per Category

```
# Linux distro wallpapers
bash scripts/rename-wallpapers.sh wallpapers/linux-distro ubuntu

# Nature
bash scripts/rename-wallpapers.sh wallpapers/nature-landscapes nature

# Anime
bash scripts/rename-wallpapers.sh wallpapers/anime-manga anime

# Minimal / abstract
bash scripts/rename-wallpapers.sh wallpapers/minimal-abstract minimal

# Dark / AMOLED
bash scripts/rename-wallpapers.sh wallpapers/dark-amoled dark

# Space
bash scripts/rename-wallpapers.sh wallpapers/space-astronomy space

# 4K / 8K
bash scripts/rename-wallpapers.sh wallpapers/4k-8k 4k

# Movies / Games
bash scripts/rename-wallpapers.sh wallpapers/movies-games movie
```

---

## Advanced — Custom Prefix

The second argument is the prefix used for renamed files:

```
# Prefix "fedora"
bash scripts/rename-wallpapers.sh wallpapers/linux-distro fedora
# → fedora-001.jpg, fedora-002.jpg, ...

# Prefix "wall"
bash scripts/rename-wallpapers.sh wallpapers/minimal-abstract wall
# → wall-001.jpg, wall-002.jpg, ...
```

If you don't pass a prefix, the folder name is used.

---

## Safety

- **Two-step rename** — avoids filename collisions (uses temp names internally)
- **`--dry-run` flag** — preview before applying
- **Skips already-correct names** — safe to re-run
- **Only touches image files** — `.gitkeep`, `.md`, and other files are ignored
- **Does not modify file contents** — only the filename

---

## Manual Renaming (Alternative)

If you prefer to rename manually before uploading:

1. Open the folder in your file manager
2. Select all files
3. Use bulk rename (Linux: `gprename`, Thunar bulk rename, KRename)
4. Follow the pattern `category-description-number.jpg`

Example:

```
ubuntu-noble-01.jpg
ubuntu-noble-02.jpg
ubuntu-noble-03.jpg
```

---

## After Renaming

Always regenerate the index:

```
make index
```

Or if you also changed thumbnails:

```
make index && make thumbs
```

---

## For Contributors

If you're submitting wallpapers via PR, please rename them using the script
before pushing. This keeps the archive clean and consistent.

See CONTRIBUTING.md for full guidelines.

