# Adding a New Category

Wallzy automatically discovers categories from the `wallpapers/` directory.
There are **3 ways** to add a new one.

---

## Method 1 — One Command (Recommended)

```bash
make add-category ID="cars-bikes" NAME="Cars & Bikes" ICON="🏎️" DESC="Sports cars and motorcycles"
```

Or without `make`:

```
bash scripts/add-category.sh cars-bikes "Cars & Bikes" "🏎️" "Sports cars and motorcycles"
```

That's it. The script:

- Creates `wallpapers/cars-bikes/`
- Registers it in `categories.json`
- Prints next steps

Now just copy your wallpapers in and push.

---

## Method 2 — Just Create a Folder

The index generator is **dynamic**. Simply create a folder:

```
mkdir -p wallpapers/cars-bikes
cp ~/Downloads/cars/*.jpg wallpapers/cars-bikes/
```

The next `make index` (or GitHub Action run) will auto-detect it as a category.

**Downside:** The category gets an auto-generated name (`Cars Bikes`) and a generic 📁 icon.

To fix that later, add an entry to `categories.json`:

```
{
  "cars-bikes": {
    "name": "Cars & Bikes",
    "icon": "🏎️",
    "description": "Sports cars and motorcycles"
  }
}
```

---

## Method 3 — Edit `categories.json` First

If you want full control before creating the folder:

1. Open `categories.json`
2. Add a new entry:

```
{
  "vintage-art": {
    "name": "Vintage Art",
    "icon": "🖼️",
    "description": "Retro and vintage artwork from the 1900s"
  }
}
```

3. Save the file
4. Create the folder: `mkdir -p wallpapers/vintage-art`
5. Copy wallpapers in
6. Run `make index`

The category will appear in the gallery even before you add wallpapers (with count 0).

---

## Icon Suggestions

Use these emojis for common categories:

| Category ↕▾ | Icon ↕▾ |
|---|---|
| −Linux / OS | 🐧 |
| Nature / Landscapes | 🌿 |
| Space / Astronomy | 🌌 |
| Anime / Manga | 🌸 |
| Minimal / Abstract | 🎨 |
| Dark / AMOLED | 🌑 |
| Movies / Films | 🎬 |
| Games / Gaming | 🎮 |
| Cars / Bikes | 🏎️ |
| Animals | 🐾 |
| City / Urban | 🏙️ |
| Islamic / Mosque | 🕌 |
| Flowers / Plants | 🌺 |
| Winter / Snow | ❄️ |
| Music | 🎵 |
| Food | 🍕 |
| Sports | ⚽ |
| Typography | 🔤 |
| Vintage / Retro | 🖼️ |
⚙

The auto-icon system also recognizes these keywords in the category ID.

---

## Removing a Category

Just delete the folder:

```
rm -rf wallpapers/cars-bikes
```

And remove its entry from `categories.json` (if present).

The next `make index` will drop it from `wallpapers.json`.

---

## Naming Rules for Category IDs

- **Lowercase** only
- Use **hyphens** (`-`) not spaces or underscores
- Only `a-z`, `0-9`, and `-`
- Keep it short and clear

✅ `cars-bikes`, `dark-amoled`, `4k-8k`, `vintage-art`
❌ `Cars_Bikes`, `Dark Amoled`, `4k 8k`, `VINTAGE ART`

