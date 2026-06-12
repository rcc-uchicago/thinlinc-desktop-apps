# RStudio Server on Compute Node

Submits a SLURM interactive job, starts RStudio Server on the allocated
compute node, creates an SSH port-forwarding tunnel to the ThinLinc desktop,
and opens the browser automatically.

## Files

| File | Description |
|------|-------------|
| `rstudio-server.sh` | Main launcher script (run by the desktop icon) |
| `rstudio-server-launch.sh` | Terminal helper: allocates node, sets up tunnel, opens browser |
| `rstudio-server-node.sh` | Runs **on the compute node** — loads the module and starts `rserver` |
| `rstudio-server.desktop` | Desktop entry file |

## How it works

1. A confirmation dialog (via `zenity`) shows the requested resources.
2. `rstudio-server-launch.sh` runs inside a `gnome-terminal` window and:
   - Calls `salloc --no-shell` to obtain a SLURM allocation.
   - Polls `squeue` until the allocated node hostname is known.
   - Finds a free local TCP port.
   - SSH's into the compute node with local port forwarding
     (`-L PORT:localhost:PORT`).
   - On the compute node, `rstudio-server-node.sh` loads the RStudio module
     and starts `rserver` bound to `127.0.0.1`.
   - Waits for the server to respond, then opens the browser at
     `http://localhost:PORT`.
3. When the terminal is closed (or Ctrl+C is pressed), the SSH tunnel drops,
   RStudio Server exits, and the SLURM job is cancelled.

### Security note

`--auth-none=1` disables the RStudio login prompt because users are already
authenticated through their ThinLinc session. The server listens **only on
the loopback interface** (`127.0.0.1`) of the compute node and is accessible
exclusively through the encrypted SSH tunnel.

## Configuration

Edit the variables at the top of `rstudio-server.sh`:

```bash
PARTITION="caslake"       # SLURM partition name
CORES=4                   # Number of CPU cores to request
HOURS=4                   # Maximum runtime in hours
RSTUDIO_MODULE="rstudio"  # Module name for RStudio Server
```

## Installation

1. Copy the `RStudio/` directory to the shared scripts location:
   ```bash
   cp -r RStudio/ /usr/local/share/thinlinc-desktop-apps/
   ```
2. Make the scripts executable:
   ```bash
   chmod +x /usr/local/share/thinlinc-desktop-apps/RStudio/*.sh
   ```
3. Ensure the `RStudio/` directory is on a **shared filesystem** accessible
   from both the ThinLinc login nodes and the compute nodes (e.g. `/project`,
   `/software`, etc.).
4. Update the `Exec=` path in `rstudio-server.desktop` to match.
5. Deploy the `.desktop` file using the
   [ThinLinc Desktop Customizer (tldc)](https://www.cendio.com/resources/docs/tag/tldc.html).
