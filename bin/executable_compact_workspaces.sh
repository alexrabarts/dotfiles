#!/bin/bash
#
# compact_workspaces.sh - Compact Hyprland workspace numbering
# Moves all windows down to fill gaps in workspace IDs

set -euo pipefail

# Configuration
SLEEP_BETWEEN_MOVES=0.1

# Get workspace information
get_workspaces() {
    hyprctl workspaces -j 2>/dev/null || {
        echo "Error: Failed to get workspaces. Is Hyprland running?" >&2
        exit 1
    }
}

# Get client information
get_clients() {
    hyprctl clients -j 2>/dev/null || {
        echo "Error: Failed to get clients" >&2
        exit 1
    }
}

# Extract occupied workspace IDs (positive only, sorted)
get_occupied_workspaces() {
    get_clients | jq -r '.[].workspace.id' | \
        grep '^[0-9]' | \
        sort -n | \
        uniq
}

# Get all workspace IDs (positive only, sorted)
get_all_workspaces() {
    get_workspaces | jq -r '.[].id' | \
        grep '^[0-9]' | \
        sort -n | \
        uniq
}

# Find gaps and create workspace mapping
# Returns lines like "source_id target_id"
create_workspace_mapping() {
    local -a occupied=()
    while IFS= read -r ws; do
        occupied+=("$ws")
    done < <(get_occupied_workspaces)

    if [ ${#occupied[@]} -eq 0 ]; then
        return 0
    fi

    local next_target=1
    local -A mapping

    for ws in "${occupied[@]}"; do
        if [ "$ws" -ne "$next_target" ]; then
            mapping[$ws]=$next_target
        fi
        ((next_target++))
    done

    # Output mapping
    for src in "${!mapping[@]}"; do
        echo "$src ${mapping[$src]}"
    done | sort -n
}

# Move all windows from one workspace to another
move_workspace_windows() {
    local from_ws=$1
    local to_ws=$2
    local moved=0

    # Get all window addresses in the source workspace
    local -a addresses
    while IFS= read -r addr; do
        addresses+=("$addr")
    done < <(get_clients | jq -r ".[] | select(.workspace.id == $from_ws) | .address")

    # Move each window
    for addr in "${addresses[@]}"; do
        if hyprctl dispatch movetoworkspace "$to_ws,address:$addr" >/dev/null 2>&1; then
            ((moved++))
            sleep "$SLEEP_BETWEEN_MOVES"
        else
            echo "Warning: Failed to move window $addr" >&2
        fi
    done

    if [ $moved -gt 0 ]; then
        echo "Moved $moved window(s) from workspace $from_ws → $to_ws"
    fi
}

# Main compaction logic
main() {
    # Check if jq is installed
    if ! command -v jq >/dev/null 2>&1; then
        echo "Error: jq is required but not installed" >&2
        exit 1
    fi

    # Get workspace mapping
    local mapping
    mapping=$(create_workspace_mapping)

    if [ -z "$mapping" ]; then
        echo "Workspaces already compacted"
        return 0
    fi

    # Apply mapping (process in reverse order to avoid conflicts)
    echo "Compacting workspaces..."
    while IFS=' ' read -r from_ws to_ws; do
        move_workspace_windows "$from_ws" "$to_ws"
    done <<< "$mapping"

    echo "Workspace compaction complete"
}

main "$@"
