#!/usr/bin/env bash
set -euo pipefail

# Get short hostname
hostname=$(hostname -s 2>/dev/null || hostname 2>/dev/null || echo "unknown")

# Detect SSH connection and set color
if [[ -n "${SSH_CLIENT:-}" || -n "${SSH_TTY:-}" ]]; then
  # SSH session - use orange/yellow to indicate remote
  bg_color="#fab387"
  icon="󱂇"  # Server rack icon for SSH
else
  # Local session - use blue
  bg_color="#89b4fa"

  # Select icon based on hostname
  case "$hostname" in
    alex-om|alex-mbp|alex-mba)
      icon="󰌢"  # Network/laptop icon
      ;;
    alex-mm)
      icon="󰟀"  # Desktop icon
      ;;
    alex-hetzner)
      icon="󰒋"  # Server icon
      ;;
    *)
      icon="󰟀"  # Default desktop icon
      ;;
  esac
fi

printf '#[fg=%s]#[fg=#11111b,bg=%s]%s #[fg=#cdd6f4,bg=#313244] %s#[fg=#313244]' "$bg_color" "$bg_color" "$icon" "$hostname"
