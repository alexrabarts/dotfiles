#!/usr/bin/env bash
# Reload the Caps Lock remapping LaunchAgent whenever the plist changes.

set -euo pipefail

if [[ $(uname -s) != "Darwin" ]]; then
  exit 0
fi

AGENT_LABEL="com.alexrabarts.swapcaps"
PLIST="${HOME}/Library/LaunchAgents/${AGENT_LABEL}.plist"
TARGET="gui/$(id -u)"

if [[ ! -f "${PLIST}" ]]; then
  echo "LaunchAgent plist ${PLIST} not found; skipping reload." >&2
  exit 0
fi

if launchctl print "${TARGET}/${AGENT_LABEL}" >/dev/null 2>&1; then
  launchctl bootout "${TARGET}" "${PLIST}" >/dev/null 2>&1 || true
fi

launchctl bootstrap "${TARGET}" "${PLIST}"
launchctl enable "${TARGET}/${AGENT_LABEL}" >/dev/null 2>&1 || true
launchctl kickstart -k "${TARGET}/${AGENT_LABEL}"

echo "Reloaded ${AGENT_LABEL} LaunchAgent to map Caps Lock to Control."
