#!/bin/bash
# Launch MATLAB on a SLURM compute node with X11 forwarding.
#
# This script submits an interactive SLURM job with X11 forwarding enabled
# and launches the MATLAB GUI on the allocated compute node. The MATLAB
# window appears on the ThinLinc desktop just like a local application.
#
# Requirements: zenity, gnome-terminal, SLURM (srun with --x11 support)

# ---------------------------------------------------------------------------
# Configuration — adjust these to match your cluster
# ---------------------------------------------------------------------------
PARTITION="caslake"
CORES=4
HOURS=4
MATLAB_MODULE="matlab"

zenity --info \
    --title="MATLAB on Compute Node" \
    --text="This will launch MATLAB on a compute node with X11 forwarding.\n\nPartition: $PARTITION\nCPU cores: $CORES\nMax runtime: $HOURS hours\n\nThe MATLAB window will open on your desktop when ready." \
    --no-wrap 2>/dev/null || true

CMD="srun --partition=$PARTITION --nodes=1 --ntasks=1 --cpus-per-task=$CORES --time=$HOURS:00:00 --job-name=matlab --x11 --pty bash"

gnome-terminal \
    --title="MATLAB on Compute Node" \
    -- bash -c "$CMD -c '
        echo
        echo \"Job started on \$HOSTNAME. Loading MATLAB module...\"
        echo \"Command used: $CMD\"
        echo
        module load $MATLAB_MODULE
        echo \"Starting MATLAB...\"
        matlab
    '"
