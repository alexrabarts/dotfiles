#!/usr/bin/env bash
set -euo pipefail

read -r _ user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
sleep 0.1
read -r _ user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 guest2 guest_nice2 < /proc/stat

prev_total=$((user + nice + system + idle + iowait + irq + softirq + steal))
prev_idle=$((idle + iowait))
cur_total=$((user2 + nice2 + system2 + idle2 + iowait2 + irq2 + softirq2 + steal2))
cur_idle=$((idle2 + iowait2))

diff_total=$((cur_total - prev_total))
diff_idle=$((cur_idle - prev_idle))

usage=0
if (( diff_total > 0 )); then
  usage=$(( (diff_total - diff_idle) * 1000 / diff_total ))
fi

integer=$((usage / 10))
frac=$((usage % 10))

printf '#[fg=#f9e2af]#[fg=#11111b,bg=#f9e2af] #[fg=#cdd6f4,bg=#313244] %d.%d%% #[fg=#313244]' "$integer" "$frac"
