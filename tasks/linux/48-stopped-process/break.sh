#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-48
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit quotes-api
write_unit quotes-api <<EOF
[Unit]
Description=Quotes API
After=network.target

[Service]
DynamicUser=yes
Environment=NAME=quotes-api PORT=8048
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now quotes-api >/dev/null 2>&1
wait_for_port 8048
kill -STOP "$(systemctl show -p MainPID --value quotes-api)"
