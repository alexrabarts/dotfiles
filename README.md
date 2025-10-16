# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Prerequisites

- [Chezmoi](https://www.chezmoi.io/install/)
- [Age](https://github.com/FiloSottile/age) (for encrypted files)
- [1Password CLI](https://developer.1password.com/docs/cli/) (optional, for easier key retrieval)

Install on macOS:
```bash
brew install chezmoi age
```

## Setup on a New Machine

### Quick Setup

1. Clone this repo:
```bash
git clone <your-repo-url> ~/.local/share/chezmoi
cd ~/.local/share/chezmoi
```

2. Run setup:
```bash
make install
```

When prompted, paste your age private key from 1Password (document: "age-chezmoi-key").

### With 1Password CLI (easier)

If you have 1Password CLI configured:
```bash
mkdir -p ~/.config/age
op document get "age-chezmoi-key" > ~/.config/age/key.txt
chmod 600 ~/.config/age/key.txt
chezmoi apply
```

### Manual Setup

1. Clone the repo:
```bash
git clone <your-repo-url> ~/.local/share/chezmoi
```

2. Setup age key:
```bash
mkdir -p ~/.config/age
# Get key from 1Password and save to ~/.config/age/key.txt
chmod 600 ~/.config/age/key.txt
```

3. Apply dotfiles:
```bash
chezmoi apply
```

## Usage

### Making Changes

```bash
# Edit a file
chezmoi edit ~/.zshrc

# See what would change
chezmoi diff

# Apply changes
chezmoi apply

# Add a new file to chezmoi
chezmoi add ~/.config/newfile
```

### Encrypted Files

Files matching `private_*` are encrypted with age.

To add an encrypted file:
```bash
chezmoi add --encrypt ~/.env
```

## What's Included

- Zsh configuration (`.zshrc`, `.zprofile`)
- Utility scripts in `~/bin/`
  - `go-install` - Install Go versions from official releases
- Environment variables (encrypted)

## Troubleshooting

**"age: error: decrypting file: no identity matched"**
- Your age key is missing or incorrect
- Get the key from 1Password: `op document get "age-chezmoi-key"`
- Save it to `~/.config/age/key.txt` with permissions 600

**Changes not applying**
- Check what would change: `chezmoi diff`
- Force apply: `chezmoi apply -v`
