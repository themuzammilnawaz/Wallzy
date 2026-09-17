# Wallzy Makefile
# Curated & developed by Muzammil Nawaz
# https://github.com/themuzammilnawaz/Wallzy

.PHONY: help index thumbs serve install clean update check rename add-category

# Default target
help:
	@echo ""
	@echo "  🎨 Wallzy — Makefile Commands"
	@echo "  ─────────────────────────────────────"
	@echo "  make index         Generate wallpapers.json index"
	@echo "  make thumbs        Generate WebP thumbnails"
	@echo "  make serve         Serve gallery locally (port 8080)"
	@echo "  make install       Install Wallzy CLI to ~/.local/bin"
	@echo "  make update        Pull latest and regenerate index"
	@echo "  make check         Check for missing dependencies"
	@echo "  make clean         Remove generated files"
	@echo ""
	@echo "  Category / rename helpers:"
	@echo "  make add-category ID=\"cars-bikes\" NAME=\"Cars & Bikes\" ICON=\"🏎️\""
	@echo "  make rename DIR=wallpapers/linux-distro PREFIX=ubuntu"
	@echo ""

# Generate JSON index
index:
	@echo "📊 Generating wallpaper index..."
	@python3 scripts/generate_index.py

# Generate thumbnails
thumbs:
	@echo "🖼️  Generating thumbnails..."
	@bash scripts/generate-thumbnails.sh

# Serve gallery locally
serve:
	@echo "🌐 Serving gallery at http://localhost:8080"
	@python3 -m http.server 8080

# Install CLI tool
install:
	@echo "📦 Installing Wallzy CLI..."
	@install -Dm755 scripts/wallzy.sh ~/.local/bin/wallzy
	@echo "✓ Installed to ~/.local/bin/wallzy"
	@echo ""
	@echo "Make sure ~/.local/bin is in your PATH:"
	@echo '  export PATH="$$HOME/.local/bin:$$PATH"'

# Update everything
update:
	@git pull
	@$(MAKE) index
	@$(MAKE) thumbs
	@echo "✓ Updated"

# Check dependencies
check:
	@echo "🔍 Checking dependencies..."
	@command -v git     >/dev/null && echo "  ✓ git"     || echo "  ✗ git (required)"
	@command -v jq      >/dev/null && echo "  ✓ jq"      || echo "  ✗ jq (required for CLI)"
	@command -v python3 >/dev/null && echo "  ✓ python3" || echo "  ✗ python3 (required for index)"
	@command -v magick  >/dev/null && echo "  ✓ magick"  || (command -v convert >/dev/null && echo "  ✓ convert" || echo "  ✗ ImageMagick (required for thumbnails)")
	@echo ""

# Add a new category
add-category:
	@if [ -z "$(ID)" ]; then \
		echo "Usage: make add-category ID=\"cars-bikes\" NAME=\"Cars & Bikes\" ICON=\"🏎️\" DESC=\"...\""; \
		exit 1; \
	fi
	@bash scripts/add-category.sh "$(ID)" "$(NAME)" "$(ICON)" "$(DESC)"

# Rename wallpapers in a folder
rename:
	@if [ -z "$(DIR)" ]; then \
		echo "Usage: make rename DIR=wallpapers/linux-distro PREFIX=ubuntu"; \
		exit 1; \
	fi
	@bash scripts/rename-wallpapers.sh "$(DIR)" "$(PREFIX)"

# Clean generated files
clean:
	@echo "🧹 Cleaning generated files..."
	@rm -f wallpapers.json
	@rm -rf thumbnails/*
	@echo "✓ Cleaned"
