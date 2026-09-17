# Wallzy Scripts

Helper scripts for maintaining the Wallzy archive.

Curated & developed by [Muzammil Nawaz](https://github.com/themuzammilnawaz).

---

## `generate_index.py`

Scans `wallpapers/` and generates `wallpapers.json` used by the gallery.

**Dynamic** — every folder in `wallpapers/` becomes a category automatically.
Metadata (name, icon, description) is read from `categories.json` if present,
otherwise it's auto-generated.

```bash
python3 scripts/generate_index.py
```

---

## `generate-thumbnails.sh`

Generates 400px-wide WebP thumbnails for every wallpaper.

Requires ImageMagick.

```
bash scripts/generate-thumbnails.sh
```

Parallel processing. Skips thumbnails that are already up-to-date.

---

## `rename-wallpapers.sh`

Renames randomly-named wallpapers (`IMG_1234.jpg`, `DSC_001.png`, `wallpaper (1).jpg`)
into clean sequential names.

```
# Preview changes
bash scripts/rename-wallpapers.sh wallpapers/linux-distro ubuntu --dry-run

# Apply
bash scripts/rename-wallpapers.sh wallpapers/linux-distro ubuntu
```

Result:

```
IMG_1234.jpg        → ubuntu-001.jpg
DSC_0056.png        → ubuntu-002.png
wallpaper (1).jpg   → ubuntu-003.jpg
photo-2024.jpg      → ubuntu-004.jpg
```

---

## `add-category.sh`

Creates a new category folder and registers it in `categories.json`.

```
# Minimal — auto-fills name and icon
bash scripts/add-category.sh cars-bikes

# Full control
bash scripts/add-category.sh cars-bikes "Cars & Bikes" "🏎️" "Sports cars and motorcycles"
```

After running, just copy wallpapers into `wallpapers/cars-bikes/`.

---

## `wallzy.sh`

The CLI tool. Installed to `~/.local/bin/wallzy` by `install.sh`.

See [main README](https://../README.md#-cli-usage) for usage.

---

## Typical Workflow

```
# 1. Add a new category
bash scripts/add-category.sh vintage-art "Vintage Art" "🖼️" "Retro and vintage artwork"

# 2. Copy wallpapers
cp ~/Downloads/vintage/*.jpg wallpapers/vintage-art/

# 3. Clean up names
bash scripts/rename-wallpapers.sh wallpapers/vintage-art vintage

# 4. Rebuild everything
make index && make thumbs

# 5. Preview locally
make serve
```

---

## Requirements

| Script ↕▾ | Requires ↕▾ |
|---|---|
| −`generate_index.py` | Python 3.8+ |
| −`generate-thumbnails.sh` | ImageMagick, bash 4+ |
| −`rename-wallpapers.sh` | bash 4+ |
| −`add-category.sh` | bash 4+, Python 3 |
| `wallzy.sh` | bash 4+, jq |
⚙

