#!/bin/bash
# Enable and start the OpenSSH server with the chezmoi-managed configuration.
# This script runs once per machine via chezmoi's run_once mechanism.

set -euo pipefail

SERVICE_NAME="sshd"
SOURCE_TEMPLATE="${CHEZMOI_SOURCE_DIR:-$HOME/.local/share/chezmoi}/etc/ssh/sshd_config.tmpl"
DEST_CONFIG="/etc/ssh/sshd_config"

# Render the sshd configuration template to a temporary file.
render_config() {
    local tmpfile
    tmpfile="$(mktemp)"
    if [[ -n "${CHEZMOI_COMMAND:-}" ]]; then
        cat "${SOURCE_TEMPLATE}" > "${tmpfile}"
    elif command -v chezmoi >/dev/null 2>&1; then
        if ! chezmoi execute-template < "${SOURCE_TEMPLATE}" > "${tmpfile}"; then
            echo "Failed to render sshd configuration template."
            rm -f "${tmpfile}"
            exit 1
        fi
    else
        cat "${SOURCE_TEMPLATE}" > "${tmpfile}"
    fi
    echo "${tmpfile}"
}

# Ensure sshd is available before attempting to enable it.
if ! command -v sshd >/dev/null 2>&1; then
    echo "sshd binary not found. Install openssh before running this script."
    exit 0
fi

# Ensure systemd has the sshd service unit.
if ! systemctl list-unit-files "${SERVICE_NAME}.service" 2>/dev/null | grep -q "^${SERVICE_NAME}.service"; then
    echo "systemd unit ${SERVICE_NAME}.service not found. Skipping enablement."
    exit 0
fi

# Ensure the template exists.
if [[ ! -f "${SOURCE_TEMPLATE}" ]]; then
    echo "Expected sshd template at ${SOURCE_TEMPLATE} not found."
    exit 1
fi

RENDERED_CONFIG="$(render_config)"
trap 'rm -f "${RENDERED_CONFIG}"' EXIT

ensure_hostkeys() {
    if sudo test -f /etc/ssh/ssh_host_ed25519_key; then
        return
    fi
    echo "Generating SSH host keys..."
    sudo ssh-keygen -A
}

ensure_hostkeys

echo "Validating sshd configuration..."
if ! sudo sshd -t -f "${RENDERED_CONFIG}"; then
    echo "sshd configuration validation failed. Aborting."
    exit 1
fi

echo "Installing sshd configuration to ${DEST_CONFIG}..."
sudo install -o root -g root -m 600 "${RENDERED_CONFIG}" "${DEST_CONFIG}"

# Enable and start/reload the sshd service.
if systemctl is-enabled "${SERVICE_NAME}" >/dev/null 2>&1; then
    echo "sshd service already enabled."
else
    echo "Enabling sshd service..."
    sudo systemctl enable "${SERVICE_NAME}"
fi

if systemctl is-active "${SERVICE_NAME}" >/dev/null 2>&1; then
    echo "sshd service already running. Reloading to pick up configuration..."
    sudo systemctl reload "${SERVICE_NAME}"
else
    echo "Starting sshd service..."
    sudo systemctl start "${SERVICE_NAME}"
fi

echo "sshd is enabled and running with the chezmoi-managed configuration."
