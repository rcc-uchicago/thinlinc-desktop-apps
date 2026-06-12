# thinlinc-desktop-apps

Collection of desktop apps for ThinLinc.

Goals:
* Desktop apps are added and changes under version control.
* Changes need to be submitted as pull requests that need reviews and approval.
* Sync to the ThinLinc server is done whenever a push or merge to the `main` branch happens.

---

A collection of desktop application launchers for the
[ThinLinc](https://www.cendio.com/thinlinc) remote desktop environment on
RCC's HPC cluster. Each app submits an interactive SLURM job and either opens
a terminal, a web-based IDE, or a GUI application on the allocated compute
node — all from a single click on the ThinLinc desktop.

---

## Applications

| App | Description | Launch method |
|-----|-------------|---------------|
| [InteractiveTerminal](InteractiveTerminal/) | Interactive shell on a compute node | `srun --pty bash` in a terminal |
| [RStudio](RStudio/) | RStudio Server in the browser | SSH port-forward + browser |
| [VSCode](VSCode/) | VS Code Server (`code-server`) in the browser | SSH port-forward + browser |
| [MATLAB](MATLAB/) | MATLAB GUI forwarded to the desktop | `srun --x11` + X11 forwarding |

---

## Prerequisites

All scripts require the following to be available on the ThinLinc login nodes:

- **SLURM** — `srun`, `salloc`, `squeue`, `scancel`
- **zenity** — for confirmation dialogs (`sudo apt install zenity`)
- **gnome-terminal** — the GNOME terminal emulator
- **ssh** — for port forwarding (RStudio and VS Code apps)
- **xdg-open** — to open the default browser (RStudio and VS Code apps)
- **python3** — for dynamic port selection (RStudio and VS Code apps)
- **curl** — to poll server readiness (RStudio and VS Code apps)

Software modules (`matlab`, `rstudio`, `vscode-server`) must be available
via the `module` command on the compute nodes.

---

## Installation

1. **Copy scripts to shared storage** (accessible from login *and* compute
   nodes):
   ```bash
   sudo cp -r . /usr/local/share/thinlinc-desktop-apps/
   sudo chmod +x /usr/local/share/thinlinc-desktop-apps/*/*.sh
   ```

2. **Update the `Exec=` paths** in each `.desktop` file to match the
   installation prefix, e.g.:
   ```
   Exec=/usr/local/share/thinlinc-desktop-apps/InteractiveTerminal/interactive-terminal.sh
   ```

3. **Adjust cluster-specific settings** (partition name, module names, default
   core/time requests) in each launcher script. See the `Configuration`
   section in each app's `README.md`.

4. **Deploy `.desktop` files** to user desktops using the
   [ThinLinc Desktop Customizer (tldc)](https://www.cendio.com/resources/docs/tag/tldc.html)
   or by placing them in the relevant skeleton/profile directory.

---

## Acknowledgements

These scripts were inspired by the
[HPCDesktop DesktopCustomizations](https://github.com/RobertHenschel/HPCDesktop/tree/main/DesktopCustomizations)
project by Robert Henschel.
