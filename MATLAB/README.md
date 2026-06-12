# MATLAB on Compute Node

Submits a SLURM interactive job with X11 forwarding enabled and launches
the MATLAB GUI on the allocated compute node. The MATLAB window appears
directly on the ThinLinc desktop — no browser or extra setup required.

## Files

| File | Description |
|------|-------------|
| `matlab.sh` | Main launcher script |
| `matlab.desktop` | Desktop entry file |

## How it works

1. A confirmation dialog (via `zenity`) shows the requested resources.
2. `srun` submits an interactive job with `--x11` and `--pty bash`.
3. A `mate-terminal` window opens, showing the allocated compute node hostname.
4. The MATLAB module is loaded and `matlab` is started on the compute node.
5. Because `--x11` is set, the MATLAB GUI window is forwarded back to the
   ThinLinc desktop via X11 and appears as a regular desktop window.
6. When MATLAB is closed, the SLURM job is automatically released.

## Requirements

- SLURM must be compiled/configured with X11 forwarding support
  (`srun --x11`).
- The `$DISPLAY` environment variable must be set in the ThinLinc session
  (it normally is by default).

## Configuration

Edit the variables at the top of `matlab.sh`:

```bash
PARTITION="caslake"   # SLURM partition name
CORES=4               # Number of CPU cores to request
HOURS=4               # Maximum runtime in hours
MATLAB_MODULE="matlab"  # Module name for MATLAB (e.g. "matlab/2023b")
```

## Installation

1. Copy the `MATLAB/` directory to the shared scripts location:
   ```bash
   cp -r MATLAB/ /usr/local/share/thinlinc-desktop-apps/
   ```
2. Make the script executable:
   ```bash
   chmod +x /usr/local/share/thinlinc-desktop-apps/MATLAB/matlab.sh
   ```
3. Update the `Exec=` path in `matlab.desktop` to match.
4. Deploy the `.desktop` file using the
   [ThinLinc Desktop Customizer (tldc)](https://www.cendio.com/resources/docs/tag/tldc.html).
