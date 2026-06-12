# VS Code Server on Compute Node

Submits a SLURM interactive job, starts VS Code Server (`code-server`) on the
allocated compute node, creates an SSH port-forwarding tunnel to the ThinLinc
desktop, and opens the browser automatically.

## Files

| File | Description |
|------|-------------|
| `vscode-server.sh` | Main launcher script (run by the desktop icon) |
| `vscode-server-launch.sh` | Terminal helper: allocates node, sets up tunnel, opens browser |
| `vscode-server-node.sh` | Runs **on the compute node** — loads the module and starts `code-server` |
| `vscode-server.desktop` | Desktop entry file |

## How it works

1. A confirmation dialog (via `zenity`) shows the requested resources.
2. `vscode-server-launch.sh` runs inside a `mate-terminal` window and:
   - Calls `salloc --no-shell` to obtain a SLURM allocation.
   - Polls `squeue` until the allocated node hostname is known.
   - Finds a free local TCP port.
   - SSH's into the compute node with local port forwarding
     (`-L PORT:localhost:PORT`).
   - On the compute node, `vscode-server-node.sh` loads the VS Code module
     and starts `code-server` bound to `127.0.0.1`.
   - Waits for the server to respond, then opens the browser at
     `http://localhost:PORT`.
3. When the terminal is closed (or Ctrl+C is pressed), the SSH tunnel drops,
   `code-server` exits, and the SLURM job is cancelled.

### Security note

`--auth none` disables the code-server password prompt because users are
already authenticated through their ThinLinc session. The server listens
**only on the loopback interface** (`127.0.0.1`) of the compute node and is
accessible exclusively through the encrypted SSH tunnel.

## Configuration

Edit the variables at the top of `vscode-server.sh`:

```bash
PARTITION="caslake"          # SLURM partition name
CORES=4                      # Number of CPU cores to request
HOURS=4                      # Maximum runtime in hours
VSCODE_MODULE="vscode-server"  # Module name for VS Code Server
```

## Installation

1. Copy the `VSCode/` directory to the shared scripts location:
   ```bash
   cp -r VSCode/ /usr/local/share/thinlinc-desktop-apps/
   ```
2. Make the scripts executable:
   ```bash
   chmod +x /usr/local/share/thinlinc-desktop-apps/VSCode/*.sh
   ```
3. Ensure the `VSCode/` directory is on a **shared filesystem** accessible
   from both the ThinLinc login nodes and the compute nodes.
4. Update the `Exec=` path in `vscode-server.desktop` to match.
5. Deploy the `.desktop` file using the
   [ThinLinc Desktop Customizer (tldc)](https://www.cendio.com/resources/docs/tag/tldc.html).
