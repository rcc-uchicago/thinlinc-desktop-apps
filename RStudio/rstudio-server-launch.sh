#!/bin/bash
# rstudio-server-launch.sh
#
# Helper script that runs INSIDE the mate-terminal window.
# It allocates a SLURM node, starts RStudio Server, establishes an SSH port
# tunnel back to the ThinLinc desktop, and opens the browser.
#
# Arguments (passed by rstudio-server.sh):
#   $1  SLURM partition
#   $2  Number of CPU cores
#   $3  Max runtime in hours
#   $4  Module name for RStudio
#   $5  Path to the node-side startup script (rstudio-server-node.sh)

set -e

PARTITION="${1:-caslake}"
CORES="${2:-4}"
HOURS="${3:-4}"
RSTUDIO_MODULE="${4:-rstudio}"
NODE_SCRIPT="${5}"

echo "=== RStudio Server Launcher ==="
echo "Partition : $PARTITION"
echo "Cores     : $CORES"
echo "Max time  : $HOURS hours"
echo ""
echo "Requesting SLURM allocation..."

# Request an interactive allocation (no-shell = returns immediately with job ID)
ALLOC_OUT=$(salloc \
    --partition="$PARTITION" \
    --nodes=1 --ntasks=1 \
    --cpus-per-task="$CORES" \
    --time="$HOURS:00:00" \
    --job-name=rstudio_server \
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

# Wait until the job transitions to RUNNING and a node is assigned
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

echo "Node     : $NODE"

# Find a free local port on the ThinLinc login node
PORT=$(python3 -c \
    'import socket; s=socket.socket(); s.bind(("", 0)); p=s.getsockname()[1]; s.close(); print(p)' \
    2>/dev/null || echo "8787")
echo "Local port: $PORT"
echo ""
echo "Starting RStudio Server on $NODE (this may take ~15 seconds)..."

# SSH into the compute node:
#   - Forward local PORT → remote PORT
#   - Run the RStudio startup script with the desired port and module
ssh -o StrictHostKeyChecking=no \
    -L "${PORT}:localhost:${PORT}" \
    "$NODE" \
    "RSTUDIO_MODULE='$RSTUDIO_MODULE' PORT='$PORT' bash '$NODE_SCRIPT'" &
SSH_PID=$!

# Wait for RStudio Server to become reachable
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
    echo "RStudio Server is ready!"
    echo "URL: http://localhost:${PORT}"
    echo ""
    xdg-open "http://localhost:${PORT}" 2>/dev/null &
else
    echo ""
    echo "WARNING: Could not confirm that RStudio Server is reachable."
    echo "If the server started successfully, browse to: http://localhost:${PORT}"
    echo ""
fi

echo "Close this terminal (or press Ctrl+C) to stop the server."
echo ""

# Block until the SSH tunnel / RStudio Server session ends
wait "$SSH_PID" || true

echo "RStudio Server session ended. Releasing SLURM job $JOBID..."
scancel "$JOBID" 2>/dev/null || true
sleep 2
