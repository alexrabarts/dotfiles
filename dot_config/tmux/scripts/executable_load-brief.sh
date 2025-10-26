#!/usr/bin/env bash
set -euo pipefail

if command -v nproc >/dev/null 2>&1; then
  cores=$(nproc 2>/dev/null || echo 1)
else
  cores=$(grep -c '^processor' /proc/cpuinfo 2>/dev/null || echo 1)
fi

if [[ -z "${cores:-}" || "$cores" -le 0 ]]; then
  cores=1
fi

if [[ -r /proc/loadavg ]]; then
  load=$(awk '{printf "%.1f", $1}' /proc/loadavg 2>/dev/null)
else
  load="?"
fi

bg_color="#89b4fa"
if [[ "$load" != "?" ]]; then
  ratio=$(awk -v load="$load" -v cores="$cores" 'BEGIN { if (cores <= 0) cores = 1; printf "%d", (load / cores) * 100 }')
  if (( ratio <= 70 )); then
    bg_color="#a6e3a1"
  elif (( ratio <= 100 )); then
    bg_color="#f9e2af"
  else
    bg_color="#f38ba8"
  fi
fi

printf '#[fg=%s]#[fg=#11111b,bg=%s]󰊚 #[fg=#cdd6f4,bg=#313244] %s #[fg=#313244]' "$bg_color" "$bg_color" "$load"
