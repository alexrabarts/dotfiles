#!/usr/bin/env bash
set -euo pipefail

if [[ -r /proc/loadavg ]]; then
  load=$(awk '{printf "%.2f", $1}' /proc/loadavg 2>/dev/null)
else
  load="?"
fi

printf '#[fg=#89b4fa]#[fg=#11111b,bg=#89b4fa]󰊚 #[fg=#cdd6f4,bg=#313244] %s #[fg=#313244]' "$load"
