.PHONY: install setup-age check-prerequisites install-packages init-chezmoi help

# Detect OS
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	OS := macos
	PKG_INSTALL_CMD := brew install
else ifeq ($(UNAME_S),Linux)
	OS := linux
	PKG_INSTALL_CMD := sudo pacman -S
else
	OS := unknown
	PKG_INSTALL_CMD := echo "Unknown OS, please install manually:"
endif

help:
	@echo "Chezmoi dotfiles setup (detected: $(OS))"
	@echo ""
	@echo "Usage:"
	@echo "  make install              - Full setup (age key + apply dotfiles)"
	@echo "  make init-chezmoi         - Initialize chezmoi with this repo as source"
	@echo "  make setup-age            - Setup age encryption only"
	@echo "  make install-packages     - Install all packages"
	@echo "  make check-prerequisites  - Check if required tools are installed"
	@echo ""

check-prerequisites:
	@echo "Checking prerequisites ($(OS))..."
	@command -v chezmoi >/dev/null 2>&1 || { \
		echo "✗ chezmoi not found."; \
		echo "  Install: $(PKG_INSTALL_CMD) chezmoi"; \
		exit 1; \
	}
	@echo "✓ chezmoi found"
	@command -v age >/dev/null 2>&1 || { \
		echo "✗ age not found."; \
		echo "  Install: $(PKG_INSTALL_CMD) age"; \
		exit 1; \
	}
	@echo "✓ age found"
	@echo "✓ All prerequisites met"

setup-age: check-prerequisites
	@echo "Setting up age encryption..."
	@mkdir -p ~/.config/age
	@if [ ! -f ~/.config/age/key.txt ]; then \
		echo "Please paste your age private key (from 1Password):"; \
		echo "(It should start with AGE-SECRET-KEY-)"; \
		read -r key; \
		echo "$$key" > ~/.config/age/key.txt; \
		chmod 600 ~/.config/age/key.txt; \
		echo "✓ Age key saved to ~/.config/age/key.txt"; \
	else \
		echo "✓ Age key already exists at ~/.config/age/key.txt"; \
	fi

install: check-prerequisites setup-age
	@echo ""
	@echo "Applying dotfiles with chezmoi..."
	@chezmoi apply -v
	@echo ""
	@echo "✓ Setup complete! Restart your shell or run: source ~/.zshrc"

init-chezmoi:
	@echo "Initializing chezmoi with this repo as source..."
	@if [ -e ~/.local/share/chezmoi ] && [ ! -L ~/.local/share/chezmoi ]; then \
		echo "⚠ ~/.local/share/chezmoi already exists and is not a symlink"; \
		echo "Remove it first with: rm -rf ~/.local/share/chezmoi"; \
		exit 1; \
	fi
	@rm -f ~/.local/share/chezmoi
	@mkdir -p ~/.local/share
	@ln -sf "$$(pwd)" ~/.local/share/chezmoi
	@echo "✓ Chezmoi initialized with source: $$(pwd)"
	@echo "  ~/.local/share/chezmoi -> $$(pwd)"
	@echo "  Run 'make install' to apply dotfiles"

install-packages:
ifeq ($(OS),linux)
	@echo "Installing packages from pkglist.txt..."
	@if [ ! -f ~/.config/pkglist.txt ]; then \
		echo "✗ ~/.config/pkglist.txt not found"; \
		echo "  Run 'chezmoi apply' or 'make install' first"; \
		exit 1; \
	fi
	@echo ""
	@echo "This will install $$(wc -l < ~/.config/pkglist.txt) packages using pacman."
	@echo -n "Continue? [y/N] " && read ans && [ "$${ans}" = "y" ] || (echo "Cancelled." && exit 1)
	@echo ""
	@sudo pacman -S --needed - < ~/.config/pkglist.txt
	@echo ""
	@echo "✓ Packages installed"
else ifeq ($(OS),macos)
	@echo "Installing packages from Brewfile..."
	@if [ ! -f Brewfile ]; then \
		echo "✗ Brewfile not found in repository"; \
		echo "  Create a Brewfile with your desired packages"; \
		echo "  Example: brew bundle dump --describe"; \
		exit 1; \
	fi
	@echo ""
	@echo "This will install packages listed in Brewfile using Homebrew."
	@echo -n "Continue? [y/N] " && read ans && [ "$${ans}" = "y" ] || (echo "Cancelled." && exit 1)
	@echo ""
	@brew bundle install
	@echo ""
	@echo "✓ Packages installed"
else
	@echo "✗ Unsupported OS: $(UNAME_S)"
	@echo "  Package installation only supported on macOS and Linux"
	@exit 1
endif
