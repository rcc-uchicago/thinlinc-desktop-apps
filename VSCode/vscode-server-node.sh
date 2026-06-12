#!/bin/bash
# vscode-server-node.sh
#
# Runs ON the compute node (invoked via SSH from vscode-server-launch.sh).
# Loads the VS Code Server module and starts code-server on the requested port.
#
# Environment variables (set by the calling SSH command):
#   VSCODE_MODULE  — module name for VS Code Server (code-server)
#   PORT           — TCP port for code-server to listen on

module load "${VSCODE_MODULE}"

echo "VS Code module loaded: $VSCODE_MODULE"
echo "Starting code-server on port $PORT ..."

# --bind-addr 127.0.0.1:PORT  Bind only to loopback; accessible only via the
#                              SSH tunnel from the ThinLinc desktop.
# --auth none                 Disable password authentication (users are
#                              already authenticated via ThinLinc/SSH).
code-server \
    --bind-addr "127.0.0.1:${PORT}" \
    --auth none
