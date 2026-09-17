<div align="center">

```

██████╗ ██╗    ██╗ █████╗ ██╗     ██╗     ███████╗██╗   ██╗
██╔══██╗██║    ██║██╔══██╗██║     ██║     ╚══███╔╝╚██╗ ██╔╝
██████╔╝██║ █╗ ██║███████║██║     ██║       ███╔╝  ╚████╔╝
██╔══██╗██║███╗██║██╔══██║██║     ██║      ███╔╝    ╚██╔╝
██████╔╝╚███╔███╔╝██║  ██║███████╗███████╗███████╗   ██║
╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝   ╚═╝

```

**A curated, open-source wallpaper archive for Linux and beyond.**

[![GitHub Stars](https://img.shields.io/github/stars/themuzammilnawaz/Wallzy?style=flat-square&color=4d6bfe&label=Stars)](https://github.com/themuzammilnawaz/Wallzy/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/themuzammilnawaz/Wallzy?style=flat-square&color=4d6bfe&label=Forks)](https://github.com/themuzammilnawaz/Wallzy/network/members)
[![GitHub Issues](https://img.shields.io/github/issues/themuzammilnawaz/Wallzy?style=flat-square&color=4d6bfe&label=Issues)](https://github.com/themuzammilnawaz/Wallzy/issues)
[![License: MIT](https://img.shields.io/badge/License-MIT-4d6bfe?style=flat-square)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-4d6bfe?style=flat-square)](CONTRIBUTING.md)
[![Wallpapers](https://img.shields.io/badge/Wallpapers-2000%2B-4d6bfe?style=flat-square)](https://themuzammilnawaz.github.io/Wallzy/)

[**🌐 Gallery**](https://themuzammilnawaz.github.io/Wallzy/) · [**📥 Install**](#-installation) · [**⌨️ CLI**](#-cli-usage) · [**🤝 Contributing**](#-contributing) · [**❤️ Credits**](#-credits)

---

*Curated & developed by **[Muzammil Nawaz](https://github.com/themuzammilnawaz)***

</div>

---

## 📖 About

**Wallzy** is a meticulously curated, open-source wallpaper archive containing **2000+ high-quality wallpapers** across **8 categories**. Built for Linux users first, it works on any platform.

Whether you want Ubuntu's latest stock wallpapers, minimal abstract art, or 4K nature photography — Wallzy has you covered. Install once, browse forever.

### Why Wallzy?

| Feature | Description |
|---------|-------------|
| 🖥️ **Universal Linux Support** | Auto-detects GNOME, KDE, XFCE, Hyprland, Sway, i3, and more |
| 🌐 **Interactive Gallery** | Browse, search, and preview wallpapers at [themuzammilnawaz.github.io/Wallzy](https://themuzammilnawaz.github.io/Wallzy/) |
| ⌨️ **CLI Tool** | Set wallpapers from the terminal with a single command |
| 📦 **One-Line Install** | `curl -fsSL ... | bash` — done in 10 seconds |
| 🔄 **Auto-Rotation** | Optional cron job to change wallpaper periodically |
| 🎨 **8 Categories** | Linux Distro, Minimal, Nature, Anime, Space, Dark/AMOLED, 4K/8K, Movies/Games |
| 🤝 **Community Driven** | Submit your own wallpapers via PR |
| ⚡ **Lightweight** | WebP thumbnails, lazy loading, no bloat |

---

## 🗂️ Categories

| Category | Folder | Description |
|----------|--------|-------------|
| 🐧 **Linux Distro Stock** | `wallpapers/linux-distro/` | Official wallpapers from Ubuntu, Fedora, Arch, Mint, Pop!_OS, and more |
| 🎨 **Minimal / Abstract** | `wallpapers/minimal-abstract/` | Clean, geometric, and abstract designs |
| 🌿 **Nature / Landscapes** | `wallpapers/nature-landscapes/` | Mountains, forests, oceans, and skies |
| 🌸 **Anime / Manga** | `wallpapers/anime-manga/` | Anime-style art and manga illustrations |
| 🌌 **Space / Astronomy** | `wallpapers/space-astronomy/` | Nebulae, galaxies, planets, and stars |
| 🌑 **Dark / AMOLED** | `wallpapers/dark-amoled/` | True-black and low-light wallpapers for OLED displays |
| 🖥️ **4K / 8K High-Res** | `wallpapers/4k-8k/` | Ultra-high-resolution wallpapers |
| 🎬 **Movies / Games** | `wallpapers/movies-games/` | Wallpapers from films, TV shows, and video games |

> **Note:** All wallpapers are provided under their original licenses. Wallzy does not claim ownership of any artwork.

---

## 🚀 Installation

### One-Line Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/themuzammilnawaz/Wallzy/main/install.sh | bash
```

This will:

1. Clone the Wallzy archive to `~/.local/share/wallzy/`
2. Install the `wallzy` CLI tool to `~/.local/bin/wallzy`
3. Symlink wallpapers to `~/Pictures/Wallzy/`
4. Auto-detect your desktop environment
5. Set a random wallpaper as a demo

### Manual Install

```
# Clone the repository
git clone https://github.com/themuzammilnawaz/Wallzy.git
cd Wallzy

# Install CLI tool
make install

# Or copy manually
install -Dm755 scripts/wallzy.sh ~/.local/bin/wallzy
```

### Requirements

- **Linux** (any distribution)
- `git` (for cloning)
- `jq` (for CLI JSON parsing — auto-installed by install script if missing)
- Optional: `feh`, `nitrogen`, `swaybg`, `hyprpaper` (for window managers)

---

## ⌨️ CLI Usage

Once installed, use the `wallzy` command:

```
# List all categories
wallzy list

# List wallpapers in a category
wallzy list linux-distro

# Search for a wallpaper
wallzy search ubuntu

# Set a random wallpaper
wallzy random

# Set a random wallpaper from a specific category
wallzy random nature-landscapes

# Set a specific wallpaper by name
wallzy set "ubuntu 2404"

# Show archive statistics
wallzy info

# Update the archive
wallzy update

# Preview a wallpaper (requires feh or nsxiv)
wallzy preview "fedora 40"

# Show help
wallzy help
```

### Auto-Rotation (Optional)

Change your wallpaper every hour:

```
# Add to crontab
(crontab -l 2>/dev/null; echo "0 * * * * wallzy random") | crontab -
```

---

## 🌐 Gallery

The interactive gallery is automatically deployed to GitHub Pages:

**[https://themuzammilnawaz.github.io/Wallzy/](https://themuzammilnawaz.github.io/Wallzy/)**

Features:

- 🔍 Search by name, category, or tag
- 🌙 Dark / Light mode
- 📱 Mobile-first responsive design
- 🖼️ Lightbox with full-size preview
- ⬇️ Download buttons
- 🏷️ Category filtering

---

## 🤝 Contributing

We welcome wallpaper submissions! See CONTRIBUTING.md for full guidelines.

### Quick Start for Contributors

1. **Fork** the repository
2. **Add** your wallpapers to the appropriate category folder
3. **Name** files descriptively (e.g., `ubuntu-2404-noble-numbat.jpg`)
4. **Ensure** images are at least **1920×1080** (16:9 or wider)
5. **Submit** a pull request

### Guidelines

- ✅ Wallpapers must be **high quality** (no compression artifacts, no watermarks)
- ✅ Minimum resolution: **1920×1080**
- ✅ File size: **under 15 MB** per image
- ✅ Format: **JPG** or **PNG** (JPG preferred)
- ❌ No NSFW content
- ❌ No copyrighted material without permission
- ❌ No AI-generated images without disclosure

---

## 📁 Repository Structure

```
Wallzy/
├── .github/
│   ├── workflows/
│   │   ├── generate-index.yml    # Auto-generates wallpapers.json
│   │   └── deploy-pages.yml      # Deploys gallery to GitHub Pages
│   ├── ISSUE_TEMPLATE/
│   └── PULL_REQUEST_TEMPLATE.md
├── wallpapers/
│   ├── linux-distro/
│   ├── minimal-abstract/
│   ├── nature-landscapes/
│   ├── anime-manga/
│   ├── space-astronomy/
│   ├── dark-amoled/
│   ├── 4k-8k/
│   └── movies-games/
├── scripts/
│   ├── generate_index.py         # JSON index generator
│   ├── generate-thumbnails.sh    # WebP thumbnail generator
│   └── wallzy.sh                 # CLI tool
├── thumbnails/                   # Auto-generated WebP previews
├── index.html                    # Gallery UI
├── styles.css                    # Gallery styles
├── app.js                        # Gallery logic
├── wallpapers.json               # Auto-generated index
├── install.sh                    # One-line installer
├── Makefile                      # Build commands
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
├── CHANGELOG.md
├── LICENSE
└── README.md
```

---

## 🛠️ Development

```
# Generate JSON index
make index

# Generate WebP thumbnails
make thumbs

# Serve gallery locally
make serve

# Install CLI tool
make install

# Clean generated files
make clean
```

---

## ❤️ Credits

**Wallzy** is curated and developed by **[Muzammil Nawaz](https://github.com/themuzammilnawaz)**.

| Platform | Link |
|---|---|
| 🌐 GitHub | [@themuzammilnawaz](https://github.com/themuzammilnawaz) |
| 💬 WhatsApp | [+92 305 7954200](https://wa.me/+923057954200/) |
| 📘 Facebook | [themuzammilnawaz](https://www.facebook.com/themuzammilnawaz/) |
| 📸 Instagram | [@themuzammilnawaz](https://www.instagram.com/themuzammilnawaz/) |
| 🐦 X (Twitter) | [@themuzammilnawaz](https://x.com/themuzammilnawaz/) |

### Contributors

Thanks to everyone who has contributed wallpapers to this archive. See the [contributors list](https://github.com/themuzammilnawaz/Wallzy/graphs/contributors).

---

## 📄 License

| Component ↕▾ | License ↕▾ |
|---|---|
| −**Code** (scripts, gallery, CLI) | [MIT](https://license/) |
| −**Wallpapers** | Original licenses / CC0 where applicable |
⚙

Wallzy does not claim ownership of any wallpaper. If you are a copyright holder and believe your work has been included without permission, please [open an issue](https://github.com/themuzammilnawaz/Wallzy/issues/new?template=bug_report.md) and we will remove it promptly.

---
<div align="center">
**⬆ Back to Top** · **[🌐 Gallery](https://themuzammilnawaz.github.io/Wallzy/)** · **📥 Install**

Made with ❤️ by **[Muzammil Nawaz](https://github.com/themuzammilnawaz)**
</div>
