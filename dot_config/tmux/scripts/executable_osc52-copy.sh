#!/usr/bin/env bash
# OSC52 clipboard copy for tmux over SSH
# Reads from stdin and sends to terminal clipboard using OSC52 escape sequences
# Works with any terminal that supports OSC52 (iTerm2, Ghostty, Alacritty, etc.)

set -eu

# Read input from stdin
buf=$(cat)

# Get length after base64 encoding
buflen=$(printf %s "$buf" | base64 | wc -c)

# Maximum OSC52 sequence length (most terminals support 100KB)
maxlen=100000

# Check if content is too large
if [ "$buflen" -gt "$maxlen" ]; then
  printf "Selection too large to copy via OSC52 (max %d bytes)" "$maxlen" >&2
  exit 1
fi

# Encode and send OSC52 sequence
# Format: ESC ] 52 ; c ; <base64-encoded-data> BEL
# ESC ] = \033]  (or \e] or \x1b])
# BEL = \a       (or \007 or \x07)
printf "\033]52;c;%s\a" "$(printf %s "$buf" | base64 | tr -d '\r\n')"
