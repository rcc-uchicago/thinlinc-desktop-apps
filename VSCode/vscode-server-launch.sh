#!/bin/bash
# vscode-server-launch.sh
#
# Helper script that runs INSIDE the gnome-terminal window.
# It allocates a SLURM node, starts VS Code Server (code-server), establishes
# an SSH port tunnel back to the ThinLinc desktop, and opens the browser.
#
# Arguments (passed by vscode-server.sh):
#   $1  SLURM partition
#   $2  Number of CPU cores
#   $3  Max runtime in hours
#   $4  Module name for VS Code Server
#   $5  Path to the node-side startup script (vscode-server-node.sh)

set -e

PARTITION="${1:-caslake}"
CORES="${2:-4}"
HOURS="${3:-4}"
VSCODE_MODULE="${4:-vscode-server}"
NODE_SCRIPT="${5}"

echo "=== VS Code Server Launcher ==="
echo "Partition : $PARTITION"
echo "Cores     : $CORES"
echo "Max time  : $HOURS hours"
echo ""
echo "Requesting SLURM allocation..."

ALLOC_OUT=$(salloc \
    --partition="$PARTITION" \
    --nodes=1 --ntasks=1 \
    --cpus-per-task="$CORES" \
    --time="$HOURS:00:00" \
    --job-name=vscode_server \
    --no-shell 2>&1)

JOBID=$(echo "$ALLOC_OUT" | grep -oP 'Granted job allocation \K[0-9]+')

if [ -z "$JOBID" ]; then
    echo ""
    echo "ERROR: Failed to obtain a SLURM allocation."
    echo "$ALLOC_OUT"
    read -rp "Press Enter to exit..."
    exit 1
fi

echo "Job ID: $JOBID"
echo "Waiting for node to become available..."

NODE=""
for _ in $(seq 1 60); do
    NODE=$(squeue -j "$JOBID" --noheader --format="%N" 2>/dev/null \
          | grep -v "^N/A$" | grep -v "^$" | head -1)
    [ -n "$NODE" ] && break
    sleep 2
done

if [ -z "$NODE" ]; then
    echo "ERROR: Timed out waiting for a compute node."
    scancel "$JOBID" 2>/dev/null
    read -rp "Press Enter to exit..."
    exit 1
fi

echo "Node      : $NODE"

PORT=$(python3 -c \
    'import socket; s=socket.socket(); s.bind(("", 0)); p=s.getsockname()[1]; s.close(); print(p)' \
    2>/dev/null || echo "8080")
echo "Local port: $PORT"
echo ""
echo "Starting VS Code Server on $NODE (this may take ~15 seconds)..."

# SSH into the compute node with port forwarding and run the startup script
ssh -o StrictHostKeyChecking=no \
    -L "${PORT}:localhost:${PORT}" \
    "$NODE" \
    "VSCODE_MODULE='$VSCODE_MODULE' PORT='$PORT' bash '$NODE_SCRIPT'" &
SSH_PID=$!

# Poll until the server responds
READY=0
for _ in $(seq 1 30); do
    sleep 2
    if curl -sf "http://localhost:${PORT}" >/dev/null 2>&1; then
        READY=1
        break
    fi
done

if [ "$READY" -eq 1 ]; then
    echo ""
    echo "VS Code Server is ready!"
    echo "URL: http://localhost:${PORT}"
    echo ""
    xdg-open "http://localhost:${PORT}" 2>/dev/null &
else
    echo ""
    echo "WARNING: Could not confirm that VS Code Server is reachable."
    echo "If the server started successfully, browse to: http://localhost:${PORT}"
    echo ""
fi

echo "Close this terminal (or press Ctrl+C) to stop the server."
echo ""

wait "$SSH_PID" || true

echo "VS Code Server session ended. Releasing SLURM job $JOBID..."
scancel "$JOBID" 2>/dev/null || true
sleep 2
