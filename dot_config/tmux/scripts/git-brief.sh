#!/usr/bin/env bash
set -euo pipefail

dir="$1"
if [[ -z "$dir" ]]; then
  exit 0
fi
if ! cd "$dir" 2>/dev/null; then
  exit 0
fi
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  exit 0
fi

branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo "detached")
counts=""

if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
  ahead=$(git rev-list --count '@{u}'..HEAD 2>/dev/null || echo 0)
  behind=$(git rev-list --count HEAD..'@{u}' 2>/dev/null || echo 0)
  if [[ "$ahead" -gt 0 ]]; then
    counts+=" ↑·$ahead"
  fi
  if [[ "$behind" -gt 0 ]]; then
    counts+=" ↓·$behind"
  fi
fi

staged=$(git diff --cached --name-only --ignore-submodules 2>/dev/null | sed '/^$/d' | wc -l | tr -d ' ')
unstaged=$(git diff --name-only --ignore-submodules 2>/dev/null | sed '/^$/d' | wc -l | tr -d ' ')
untracked=$(git ls-files --others --exclude-standard 2>/dev/null | sed '/^$/d' | wc -l | tr -d ' ')

if [[ "$staged" -gt 0 ]]; then
  counts+=" ✚ $staged"
fi
if [[ "$unstaged" -gt 0 ]]; then
  counts+=" ∆ $unstaged"
fi
if [[ "$untracked" -gt 0 ]]; then
  counts+=" … $untracked"
fi

printf '#[fg=#94e2d5]#[fg=#11111b,bg=#94e2d5]󰊢 #[fg=#cdd6f4,bg=#313244] ⎇ %s%s #[fg=#313244]' "$branch" "$counts"
