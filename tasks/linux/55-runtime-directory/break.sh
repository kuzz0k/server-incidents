#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-55
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit sessiond
rm -f /etc/tmpfiles.d/sessiond.conf
remove_user sessiond
ensure_user sessiond
rm -rf /run/sessiond
write_unit sessiond <<EOF
[Unit]
Description=Session daemon
After=network.target

[Service]
User=sessiond
Environment=NAME=sessiond PORT=8055 DATA_DIR=/run/sessiond
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now sessiond >/dev/null 2>&1
wait_for_port 8055
