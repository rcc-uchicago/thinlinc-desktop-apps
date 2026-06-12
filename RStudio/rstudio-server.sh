#!/bin/bash
# Launch RStudio Server on a SLURM compute node.
#
# This script allocates a compute node via SLURM, starts RStudio Server on
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
RSTUDIO_MODULE="rstudio"

# Detect the first SLURM account (pi-* group) for the current user
ACCOUNT=$(groups 2>/dev/null | tr ' ' '\n' | grep '^pi-' | head -1)

# ---------------------------------------------------------------------------
# Path to the helper script that runs on the compute node.
# Must be accessible from compute nodes (e.g., on shared storage).
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
NODE_SCRIPT="$SCRIPT_DIR/rstudio-server-node.sh"

zenity --info \
    --title="RStudio Server on Compute Node" \
    --text="This will start RStudio Server on a compute node.\n\nPartition: $PARTITION\nAccount: ${ACCOUNT:-none detected}\nCPU cores: $CORES\nMax runtime: $HOURS hours\n\nA browser window will open when the server is ready." \
    --no-wrap 2>/dev/null || true

# Open a terminal that runs the full setup process
gnome-terminal \
    --title="RStudio Server on Compute Node" \
    -- bash "$SCRIPT_DIR/rstudio-server-launch.sh" \
        "$PARTITION" "$CORES" "$HOURS" "$RSTUDIO_MODULE" "$NODE_SCRIPT" "$ACCOUNT"
