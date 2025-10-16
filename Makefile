.PHONY: install setup-age check-prerequisites help

help:
	@echo "Chezmoi dotfiles setup"
	@echo ""
	@echo "Usage:"
	@echo "  make install              - Full setup (age key + apply dotfiles)"
	@echo "  make setup-age            - Setup age encryption only"
	@echo "  make check-prerequisites  - Check if required tools are installed"
	@echo ""

check-prerequisites:
	@echo "Checking prerequisites..."
	@command -v chezmoi >/dev/null 2>&1 || { echo "✗ chezmoi not found. Install: brew install chezmoi"; exit 1; }
	@echo "✓ chezmoi found"
	@command -v age >/dev/null 2>&1 || { echo "✗ age not found. Install: brew install age"; exit 1; }
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
