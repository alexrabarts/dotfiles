#!/usr/bin/env bash
set -euo pipefail

path="${1:-/}"

if ! df_output=$(df -Pk "$path" 2>/dev/null | tail -n 1); then
  printf '#[fg=#fab387]#[fg=#11111b,bg=#fab387]󰋊 #[fg=#cdd6f4,bg=#313244] ? #[fg=#313244]'
  exit 0
fi

used_pct=$(awk '{print $5}' <<<"$df_output" | tr -d '%')
used_int=0
if [[ "$used_pct" =~ ^[0-9]+$ ]]; then
  used_int=$used_pct
fi

bg_color="#a6e3a1"
if (( used_int >= 90 )); then
  bg_color="#f38ba8"
elif (( used_int >= 70 )); then
  bg_color="#f9e2af"
fi

printf '#[fg=%s]#[fg=#11111b,bg=%s]󰋊 #[fg=#cdd6f4,bg=#313244] %s%% #[fg=#313244]' "$bg_color" "$bg_color" "$used_pct"
