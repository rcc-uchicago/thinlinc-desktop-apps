# Interactive Terminal on Compute Node

Submits a SLURM interactive job and opens a terminal on the allocated compute
node. This is the simplest way for users to get an interactive shell on a
compute node directly from the ThinLinc desktop.

## Files

| File | Description |
|------|-------------|
| `interactive-terminal.sh` | Main launcher script |
| `interactive-terminal.desktop` | Desktop entry file |

## How it works

1. A confirmation dialog (via `zenity`) shows the requested resources.
2. `srun` submits an interactive job to SLURM and waits for a compute node.
3. A `mate-terminal` window opens with a shell on the allocated node.
4. The `srun` command that was used is printed in the terminal so users can
   learn from it and reproduce it themselves.
5. When the terminal is closed, the SLURM job is automatically released.

## Configuration

Edit the variables at the top of `interactive-terminal.sh`:

```bash
PARTITION="caslake"   # SLURM partition name
CORES=4               # Number of CPU cores to request
HOURS=4               # Maximum runtime in hours
```

## Installation

1. Copy the `InteractiveTerminal/` directory to the shared scripts location,
   e.g. `/usr/local/share/thinlinc-desktop-apps/InteractiveTerminal/`.
2. Make the script executable:
   ```bash
   chmod +x /usr/local/share/thinlinc-desktop-apps/InteractiveTerminal/interactive-terminal.sh
   ```
3. Update the `Exec=` path in `interactive-terminal.desktop` to match.
4. Deploy the `.desktop` file to user desktops using the
   [ThinLinc Desktop Customizer (tldc)](https://www.cendio.com/resources/docs/tag/tldc.html).
