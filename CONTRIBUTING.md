# Contributing to Wallzy

First off, thank you for considering contributing to Wallzy! It's people like you that make this archive a great resource for the Linux community.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Submitting Wallpapers](#submitting-wallpapers)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Features](#suggesting-features)
  - [Improving Documentation](#improving-documentation)
- [Wallpaper Guidelines](#wallpaper-guidelines)
- [Pull Request Process](#pull-request-process)
- [Style Guide](#style-guide)
- [Credits](#credits)

---

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

---

## How Can I Contribute?

### Submitting Wallpapers

1. **Fork** the repository
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Wallzy.git
   cd Wallzy
```

3. **Add** your wallpapers to the appropriate category folder:

```
wallpapers/linux-distro/
wallpapers/minimal-abstract/
wallpapers/nature-landscapes/
wallpapers/anime-manga/
wallpapers/space-astronomy/
wallpapers/dark-amoled/
wallpapers/4k-8k/
wallpapers/movies-games/
```
4. **Name** your files descriptively using lowercase and hyphens:

```
ubuntu-2404-noble-numbat.jpg
fedora-40-workstation.png
minimal-dark-geometric.jpg
```
5. **Test** locally:

```
make index
make thumbs
make serve
```
6. **Commit** your changes:

```
git add wallpapers/
git commit -m "feat: add Ubuntu 24.04 Noble Numbat wallpapers"
```
7. **Push** and open a **Pull Request**

### Reporting Bugs

Before creating a bug report, please check the [existing issues](https://github.com/themuzammilnawaz/Wallzy/issues) to see if the problem has already been reported.

When creating a bug report, include:

- **Descriptive title**
- **Steps to reproduce**
- **Expected behavior**
- **Actual behavior**
- **Screenshots** (if applicable)
- **Your environment** (OS, desktop environment, shell)

### Suggesting Features

Feature suggestions are welcome! Open an issue with the `enhancement` label and describe:

- The problem you're trying to solve
- Your proposed solution
- Any alternatives you've considered

### Improving Documentation

Documentation improvements are always appreciated. This includes:

- Fixing typos
- Clarifying confusing sections
- Adding examples
- Translating (future)

---

## Wallpaper Guidelines

### Technical Requirements

| Requirement ↕▾ | Specification ↕▾ |
|---|---|
| −**Minimum resolution** | 1920×1080 |
| −**Recommended resolution** | 3840×2160 (4K) |
| −**Aspect ratio** | 16:9 or wider |
| −**File format** | JPG (preferred) or PNG |
| −**Maximum file size** | 15 MB |
| −**Color profile** | sRGB |
⚙

### Quality Standards

- ✅ **Sharp** — no blur, no compression artifacts
- ✅ **Clean** — no watermarks, no text overlays (unless part of the design)
- ✅ **Properly named** — descriptive, lowercase, hyphens
- ✅ **Relevant** — fits the category

### Content Restrictions

- ❌ **No NSFW** content
- ❌ **No copyrighted** material without explicit permission
- ❌ **No AI-generated** images without disclosure in the PR description
- ❌ **No low-effort** or low-quality images
- ❌ **No images with visible logos** of non-relevant brands

### Attribution

If you're submitting wallpapers created by someone else:

1. Ensure you have permission
2. Include the original source URL in the PR description
3. Include the artist's name and license

---

## Pull Request Process

1. **Update the README** if you're adding a new category (rare)
2. **Test locally** — run `make index && make thumbs`
3. **One category per PR** — don't mix categories
4. **Descriptive title** — e.g., `feat: add 12 Ubuntu 24.04 wallpapers`
5. **Fill out the PR template** completely
6. **Wait for review** — maintainers will review within 7 days

### PR Title Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

| Prefix ↕▾ | Use ↕▾ |
|---|---|
| −`feat:` | New wallpapers or features |
| −`fix:` | Bug fixes |
| −`docs:` | Documentation changes |
| −`chore:` | Maintenance tasks |
| −`refactor:` | Code refactoring |
⚙

---

## Style Guide

### File Naming

```
✅ ubuntu-2404-noble-numbat.jpg
✅ minimal-dark-waves.png
✅ nature-mountain-sunset.jpg
❌ IMG_20240101_123456.jpg
❌ wallpaper (1).jpg
❌ random image final FINAL.jpg
```

### Commit Messages

```
✅ feat: add 15 Fedora 40 wallpapers
✅ fix: correct thumbnail generation for WebP files
✅ docs: update installation instructions for Arch Linux
❌ added stuff
❌ fix
❌ asdfgh
```

### Code Style (for scripts)

- Shell: [ShellCheck](https://www.shellcheck.net/) compliant
- Python: [PEP 8](https://peps.python.org/pep-0008/)
- JavaScript: 2-space indent, semicolons

---

## Credits

### Core Team

- **[Muzammil Nawaz](https://github.com/themuzammilnawaz)** — Creator & Maintainer

### Contributors

All contributors are listed in the [GitHub contributors graph](https://github.com/themuzammilnawaz/Wallzy/graphs/contributors).

### Social

| Platform ↕▾ | Link ↕▾ |
|---|---|
| −WhatsApp | [wa.me/+923057954200](https://wa.me/+923057954200/) |
| −Facebook | [themuzammilnawaz](https://www.facebook.com/themuzammilnawaz/) |
| −Instagram | [@themuzammilnawaz](https://www.instagram.com/themuzammilnawaz/) |
| −X | [@themuzammilnawaz](https://x.com/themuzammilnawaz/) |
| −GitHub | [@themuzammilnawaz](https://github.com/themuzammilnawaz/) |
⚙

---

Thank you for contributing to Wallzy! 🎨

