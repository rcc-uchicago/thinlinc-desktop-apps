#!/bin/bash
# Launch an interactive terminal session on a SLURM compute node.
#
# This script submits an interactive SLURM job and opens a terminal
# on the allocated compute node. Intended for use as a ThinLinc
# desktop application.
#
# Requirements: zenity, gnome-terminal, SLURM (srun)

# ---------------------------------------------------------------------------
# Configuration — adjust these to match your cluster
# ---------------------------------------------------------------------------
PARTITION="caslake"
CORES=4
HOURS=4

# Detect the first SLURM account (pi-* group) for the current user
ACCOUNT=$(groups 2>/dev/null | tr ' ' '\n' | grep '^pi-' | head -1)

zenity --info \
    --title="Interactive Terminal on Compute Node" \
    --text="This will launch an interactive terminal on a compute node.\n\nPartition: $PARTITION\nAccount: ${ACCOUNT:-none detected}\nCPU cores: $CORES\nMax runtime: $HOURS hours" \
    --no-wrap 2>/dev/null || true

CMD="srun --partition=$PARTITION ${ACCOUNT:+--account=$ACCOUNT} --nodes=1 --ntasks=1 --cpus-per-task=$CORES --time=$HOURS:00:00 --job-name=interactive --pty bash"

gnome-terminal \
    --title="Interactive Terminal on Compute Node" \
    -- bash -c "$CMD -c 'echo; echo \"Job started on \$HOSTNAME. Command used:\"; echo \"$CMD\"; echo; exec bash'"
