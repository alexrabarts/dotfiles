#!/usr/bin/env bash
set -euo pipefail

# Get short hostname
hostname=$(hostname -s 2>/dev/null || hostname 2>/dev/null || echo "unknown")

# Detect SSH connection
if [[ -n "${SSH_CLIENT:-}" || -n "${SSH_TTY:-}" ]]; then
  # SSH session - use orange/yellow to indicate remote
  bg_color="#fab387"
else
  # Local session - use blue
  bg_color="#89b4fa"
fi

printf '#[fg=%s]#[fg=#11111b,bg=%s] #[fg=#cdd6f4,bg=#313244] %s #[fg=#313244]' "$bg_color" "$bg_color" "$hostname"
