#!/bin/bash
# Launch VS Code Server (code-server) on a SLURM compute node.
#
# This script allocates a compute node via SLURM, starts code-server on
# that node, creates an SSH port-forwarding tunnel, and opens the browser
# on the ThinLinc desktop. Intended for use as a ThinLinc desktop application.
#
# Requirements: zenity, gnome-terminal, ssh, xdg-open, python3, SLURM

# ---------------------------------------------------------------------------
# Configuration — adjust these to match your cluster
# ---------------------------------------------------------------------------
PARTITION="caslake"
CORES=4
HOURS=4
VSCODE_MODULE="vscode-server"

# Detect the first SLURM account (pi-* group) for the current user
ACCOUNT=$(groups 2>/dev/null | tr ' ' '\n' | grep '^pi-' | head -1)

# ---------------------------------------------------------------------------
# Path to the helper scripts (must be on a shared filesystem).
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

zenity --info \
    --title="VS Code Server on Compute Node" \
    --text="This will start VS Code Server on a compute node.\n\nPartition: $PARTITION\nAccount: ${ACCOUNT:-none detected}\nCPU cores: $CORES\nMax runtime: $HOURS hours\n\nA browser window will open when the server is ready." \
    --no-wrap 2>/dev/null || true

gnome-terminal \
    --title="VS Code Server on Compute Node" \
    -- bash "$SCRIPT_DIR/vscode-server-launch.sh" \
        "$PARTITION" "$CORES" "$HOURS" "$VSCODE_MODULE" \
        "$SCRIPT_DIR/vscode-server-node.sh" "$ACCOUNT"
