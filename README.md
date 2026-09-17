<div align="center">

```

██╗    ██╗ █████╗ ██╗     ██╗     ███████╗██╗   ██╗
██║    ██║██╔══██╗██║     ██║     ╚══███╔╝╚██╗ ██╔╝
██║ █╗ ██║███████║██║     ██║       ███╔╝  ╚████╔╝
██║███╗██║██╔══██║██║     ██║      ███╔╝    ╚██╔╝
╚███╔███╔╝██║  ██║███████╗███████╗███████╗   ██║
╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝   ╚═╝

```

**A curated, open-source wallpaper archive for Linux and beyond.**

[![Wallpapers](https://img.shields.io/badge/wallpapers-2000%2B-4d6bfe?style=for-the-badge)](https://themuzammilnawaz.github.io/Wallzy/)
[![License](https://img.shields.io/badge/license-MIT-4d6bfe?style=for-the-badge)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-4d6bfe?style=for-the-badge)](CONTRIBUTING.md)

[**🌐 Gallery**](https://themuzammilnawaz.github.io/Wallzy/) · [**📥 Install**](#-installation) · [**⌨️ CLI**](#-cli-usage) · [**🤝 Contribute**](CONTRIBUTING.md)

<sub>Curated & developed by **[Muzammil Nawaz](https://github.com/themuzammilnawaz)**</sub>

</div>

---

## 📖 About

**Wallzy** is a curated, open-source wallpaper archive containing **2000+ high-quality wallpapers** across **8 categories**. Built for Linux users first — works everywhere.

Install once, browse forever.

---

## 🗂️ Categories

| Category | Folder | Description |
|----------|--------|-------------|
| 🐧 **Linux Distro Stock** | `wallpapers/linux-distro/` | Official wallpapers from Ubuntu, Fedora, Arch, Mint, Pop!_OS |
| 🎨 **Minimal / Abstract** | `wallpapers/minimal-abstract/` | Clean, geometric, and abstract designs |
| 🌿 **Nature / Landscapes** | `wallpapers/nature-landscapes/` | Mountains, forests, oceans, and skies |
| 🌸 **Anime / Manga** | `wallpapers/anime-manga/` | Anime-style art and manga illustrations |
| 🌌 **Space / Astronomy** | `wallpapers/space-astronomy/` | Nebulae, galaxies, planets, and stars |
| 🌑 **Dark / AMOLED** | `wallpapers/dark-amoled/` | True-black wallpapers for OLED displays |
| 🖥️ **4K / 8K High-Res** | `wallpapers/4k-8k/` | Ultra-high-resolution wallpapers |
| 🎬 **Movies / Games** | `wallpapers/movies-games/` | Wallpapers from films and video games |

> All wallpapers are provided under their original licenses. Wallzy does not claim ownership of any artwork.

---

## 🚀 Installation

### One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/themuzammilnawaz/Wallzy/main/install.sh | bash
```

This will:

- Clone the archive to `~/.local/share/wallzy/`
- Install the `wallzy` CLI tool to `~/.local/bin/wallzy`
- Symlink wallpapers to `~/Pictures/Wallzy/`
- Auto-detect your desktop environment (GNOME, KDE, XFCE, Hyprland, Sway, i3)
- Set a random wallpaper as a demo

### Manual Install

```
git clone https://github.com/themuzammilnawaz/Wallzy.git
cd Wallzy
make install
```

### Requirements

- **Linux** (any distribution)
- `git` — for cloning
- `jq` — for the CLI tool
- Optional: `feh`, `nitrogen`, `swaybg`, `hyprpaper` for window managers

---

## ⌨️ CLI Usage

```
wallzy list                      # List all categories
wallzy list linux-distro         # List wallpapers in a category
wallzy search ubuntu             # Search by name
wallzy random                    # Set a random wallpaper
wallzy random nature-landscapes  # Random from a category
wallzy set "ubuntu 2404"         # Set by name
wallzy preview "fedora 40"       # Preview
wallzy info                      # Archive statistics
wallzy update                    # Update the archive
wallzy help                      # Show all commands
```

### Auto-Rotation

Change wallpaper every hour:

```
(crontab -l 2>/dev/null; echo "0 * * * * wallzy random") | crontab -
```

---

## 🤝 Contributing

We welcome wallpaper submissions! Read CONTRIBUTING.md for full guidelines.

**Quick start:**

1. **Fork** the repository
2. **Add** wallpapers to the appropriate category folder
3. **Name** files descriptively (`ubuntu-2404-noble.jpg`)
4. **Minimum** resolution: 1920×1080
5. **Submit** a pull request

### Guidelines

- ✅ High quality — no compression artifacts, no watermarks
- ✅ Minimum 1920×1080, JPG or PNG
- ✅ Under 15 MB per image
- ❌ No NSFW content
- ❌ No copyrighted material without permission

---

## 🛠️ Development

```
make index    # Generate wallpapers.json
make thumbs   # Generate WebP thumbnails
make serve    # Serve gallery locally (localhost:8080)
make install  # Install the CLI tool
make clean    # Remove generated files
```

---

## 📄 License

| Component ↕▾ | License ↕▾ |
|---|---|
| −**Code** (scripts, gallery, CLI) | [MIT](https://license/) |
| −**Wallpapers** | Original licenses / CC0 where applicable |
⚙

Wallzy does not claim ownership of any wallpaper. If you are a copyright holder and believe your work has been included without permission, please [open an issue](https://github.com/themuzammilnawaz/Wallzy/issues) and we will remove it promptly.

---
<div align="center">
### Connect with Muzammil Nawaz

[[https://img.shields.io/badge/WhatsApp-25D366?style=for-the-badge&logo=whatsapp&logoColor=white](https://img.shields.io/badge/WhatsApp-25D366?style=for-the-badge&logo=whatsapp&logoColor=white)](https://wa.me/+923057954200/)
[[https://img.shields.io/badge/Facebook-1877F2?style=for-the-badge&logo=facebook&logoColor=white](https://img.shields.io/badge/Facebook-1877F2?style=for-the-badge&logo=facebook&logoColor=white)](https://www.facebook.com/themuzammilnawaz/)
[[https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white](https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/themuzammilnawaz/)
[[https://img.shields.io/badge/X-000000?style=for-the-badge&logo=x&logoColor=white](https://img.shields.io/badge/X-000000?style=for-the-badge&logo=x&logoColor=white)](https://x.com/themuzammilnawaz/)
[[https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://www.github.com/themuzammilnawaz/)

**⬆ Back to Top** · **[🌐 Gallery](https://themuzammilnawaz.github.io/Wallzy/)** · **📥 Install**

<sub>Made with ❤️ by <a href="https://github.com/themuzammilnawaz">Muzammil Nawaz</a></sub>
</div>
