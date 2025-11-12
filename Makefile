.PHONY: install setup-age check-prerequisites install-packages init-chezmoi install-tmux-plugins restart-walker setup-keyd setup-fingerprint help

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
	@echo "  make setup-keyd           - Setup keyd for macOS-style shortcuts (requires sudo)"
	@echo "  make setup-fingerprint    - Setup fingerprint reader (ThinkPad T480s)"
	@echo "  make install-packages     - Install all packages"
	@echo "  make install-tmux-plugins - Install tmux plugins via TPM"
	@echo "  make restart-walker       - Restart walker app launcher service"
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

install-tmux-plugins:
	@echo "Installing tmux plugins..."
	@if ! command -v tmux >/dev/null 2>&1; then \
		echo "⚠ tmux not installed, skipping plugin installation"; \
		echo "  Install tmux first with: make install-packages"; \
		echo "  Then run: make install-tmux-plugins"; \
	else \
		mkdir -p ~/.tmux/plugins; \
		if [ ! -d ~/.tmux/plugins/tpm ]; then \
			echo "Installing TPM (Tmux Plugin Manager)..."; \
			git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm; \
		else \
			echo "✓ TPM already installed"; \
		fi; \
		echo "Installing tmux plugins via TPM..."; \
		~/.tmux/plugins/tpm/bin/install_plugins; \
		echo "✓ Tmux plugins installed"; \
	fi

restart-walker:
	@echo "Restarting walker app launcher service..."
	@pkill walker || true
	@pkill elephant || true
	@echo "✓ Walker services stopped. They will restart automatically on next use (Super+Space)."

setup-keyd:
ifeq ($(OS),linux)
	@echo "Setting up keyd for macOS-style keyboard shortcuts..."
	@if ! command -v keyd >/dev/null 2>&1; then \
		echo "✗ keyd not installed. Install with: sudo pacman -S keyd"; \
		exit 1; \
	fi
	@echo "Installing keyd configuration..."
	@chezmoi execute-template < ~/.local/share/chezmoi/etc/keyd/default.conf.tmpl | sudo tee /etc/keyd/default.conf > /dev/null
	@sudo chmod 644 /etc/keyd/default.conf
	@echo "Enabling and starting keyd service..."
	@sudo systemctl enable --now keyd
	@echo "✓ keyd is now active!"
	@echo "  Super+T opens new tab, Super+W closes tab (remapped to Ctrl+T/W at kernel level)"
else
	@echo "⚠ keyd setup is only needed on Linux (macOS doesn't need it)"
endif

setup-fingerprint:
ifeq ($(OS),linux)
	@echo "Fingerprint Reader Setup (ThinkPad T480s - Synaptics Metallica 06cb:009a)"
	@echo ""
	@echo "This requires manual steps due to AUR package installation."
	@echo "See: .agent/sop/system-files.md#fingerprint-reader-setup"
	@echo ""
	@echo "Quick setup:"
	@echo "  1. yay -S python-validity"
	@echo "  2. sudo systemctl mask fprintd"
	@echo "  3. sudo systemctl enable --now python3-validity open-fprintd"
	@echo "  4. fprintd-enroll $$USER"
	@echo "  5. sudo sed -i '1i auth    sufficient pam_fprintd.so' /etc/pam.d/sudo"
	@echo "  6. sudo sed -i '1i auth      sufficient pam_fprintd.so' /etc/pam.d/polkit-1"
else
	@echo "⚠ Fingerprint setup is only for Linux"
endif

install: check-prerequisites setup-age install-packages
	@echo ""
	@# Ensure chezmoi is initialized (symlink exists)
	@if [ ! -e ~/.local/share/chezmoi ]; then \
		echo "Initializing chezmoi..."; \
		mkdir -p ~/.local/share; \
		ln -sf "$$(pwd)" ~/.local/share/chezmoi; \
		echo "✓ Chezmoi initialized with source: $$(pwd)"; \
		echo ""; \
	fi
	@echo "Applying dotfiles with chezmoi..."
	@chezmoi apply -v
	@echo ""
	@$(MAKE) install-tmux-plugins
	@echo ""
	@echo "✓ Full setup complete!"
	@echo ""
	@echo "Next steps:"
ifeq ($(OS),linux)
	@echo "  1. Setup keyd for macOS-style shortcuts: make setup-keyd"
	@echo "  2. Restart your shell with: exec zsh"
else
	@echo "  1. Restart your shell with: exec zsh"
endif

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
