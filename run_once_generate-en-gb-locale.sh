#!/usr/bin/env bash
set -euo pipefail

# Check if en_GB.UTF-8 locale is already generated
if locale -a 2>/dev/null | grep -q "^en_GB.utf8$"; then
  echo "✓ en_GB.UTF-8 locale already generated"
  exit 0
fi

echo "Generating en_GB.UTF-8 locale..."

# Check if locale.gen exists
if [ ! -f /etc/locale.gen ]; then
  echo "✗ /etc/locale.gen not found - not on a system that uses locale.gen"
  exit 1
fi

# Uncomment en_GB.UTF-8 in locale.gen if not already uncommented
if ! grep -q "^en_GB.UTF-8 UTF-8" /etc/locale.gen; then
  echo "  Uncommenting en_GB.UTF-8 in /etc/locale.gen..."
  sudo sed -i 's/^#\s*en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen
fi

# Generate locales
echo "  Running locale-gen..."
sudo locale-gen

echo "✓ en_GB.UTF-8 locale generated successfully"
echo "  Note: You may need to restart your shell for changes to take effect"
