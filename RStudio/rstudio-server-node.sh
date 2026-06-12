#!/bin/bash
# rstudio-server-node.sh
#
# Runs ON the compute node (invoked via SSH from rstudio-server-launch.sh).
# Loads the RStudio module and starts rserver on the requested port.
#
# Environment variables (set by the calling SSH command):
#   RSTUDIO_MODULE  — module name for RStudio Server
#   PORT            — TCP port for rserver to listen on

module load "${RSTUDIO_MODULE}"

echo "RStudio module loaded: $RSTUDIO_MODULE"
echo "Starting rserver on port $PORT ..."

# --auth-none=1         Disable authentication (users are already authenticated
#                       via their ThinLinc session; the port is only accessible
#                       through the SSH tunnel).
# --www-address=127.0.0.1  Bind only to loopback so the server is not
#                           reachable directly over the network.
rserver \
    --www-port="$PORT" \
    --www-address=127.0.0.1 \
    --auth-none=1 \
    --server-user="$USER"
