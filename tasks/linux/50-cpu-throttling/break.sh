#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-50
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit pricing-api
write_unit pricing-api <<EOF
[Unit]
Description=Pricing API
After=network.target

[Service]
DynamicUser=yes
Environment=NAME=pricing-api PORT=8050 BURN=/price:0.2
ExecStart=/usr/bin/python3 $WEBAPP
CPUQuota=4%
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now pricing-api >/dev/null 2>&1
wait_for_port 8050
