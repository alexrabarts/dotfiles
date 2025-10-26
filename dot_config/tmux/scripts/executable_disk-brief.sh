#!/usr/bin/env bash
set -euo pipefail

path="${1:-/}"

# Get root/pane disk usage
if ! df_output=$(df -Pk "$path" 2>/dev/null | tail -n 1); then
  printf '#[fg=#fab387]#[fg=#11111b,bg=#fab387]󰋊 #[fg=#cdd6f4,bg=#313244] ? #[fg=#313244]'
  exit 0
fi

root_pct=$(awk '{print $5}' <<<"$df_output" | tr -d '%')
root_int=0
if [[ "$root_pct" =~ ^[0-9]+$ ]]; then
  root_int=$root_pct
fi

# Determine data disk path based on OS
data_path=""
if [[ -d /mnt/data ]]; then
  data_path="/mnt/data"
elif [[ -d /Volumes/Data ]]; then
  data_path="/Volumes/Data"
fi

# Get data disk usage if mounted
data_pct=""
data_int=0
if [[ -n "$data_path" ]] && df_data=$(df -Pk "$data_path" 2>/dev/null | tail -n 1); then
  data_pct=$(awk '{print $5}' <<<"$df_data" | tr -d '%')
  if [[ "$data_pct" =~ ^[0-9]+$ ]]; then
    data_int=$data_pct
  fi
fi

# Use highest percentage for color
max_pct=$root_int
if (( data_int > max_pct )); then
  max_pct=$data_int
fi

bg_color="#a6e3a1"
if (( max_pct >= 90 )); then
  bg_color="#f38ba8"
elif (( max_pct >= 70 )); then
  bg_color="#f9e2af"
fi

# Format output
if [[ -n "$data_pct" ]]; then
  printf '#[fg=%s]#[fg=#11111b,bg=%s]󰋊 #[fg=#cdd6f4,bg=#313244] %s%% %s%% #[fg=#313244]' "$bg_color" "$bg_color" "$root_pct" "$data_pct"
else
  printf '#[fg=%s]#[fg=#11111b,bg=%s]󰋊 #[fg=#cdd6f4,bg=#313244] %s%% #[fg=#313244]' "$bg_color" "$bg_color" "$root_pct"
fi
