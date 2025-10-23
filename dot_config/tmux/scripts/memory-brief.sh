#!/usr/bin/env bash
set -euo pipefail

# Read memory info from /proc/meminfo
mem_total_kb=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
mem_available_kb=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)

usage_pct=0
if [[ -n "${mem_total_kb}" && -n "${mem_available_kb}" && "${mem_total_kb}" -gt 0 ]]; then
  used_kb=$((mem_total_kb - mem_available_kb))
  usage_pct=$((used_kb * 1000 / mem_total_kb))
fi

integer=$((usage_pct / 10))
frac=$((usage_pct % 10))

bg_color="#a6e3a1"
if (( usage_pct >= 850 )); then
  bg_color="#f38ba8"
elif (( usage_pct >= 650 )); then
  bg_color="#f9e2af"
fi

printf '#[fg=%s]#[fg=#11111b,bg=%s]󰍛 #[fg=#cdd6f4,bg=#313244] %d.%d%% #[fg=#313244]' "$bg_color" "$bg_color" "$integer" "$frac"
