#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-15
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit gateway legacy-gw
ensure_user gateway
mkdir -p /opt/legacy-gw
echo "legacy gateway v0.9 (deprecated)" > /opt/legacy-gw/index.html

write_unit legacy-gw <<'EOF'
[Unit]
Description=Legacy API gateway (deprecated)
After=network.target

[Service]
ExecStart=/usr/bin/python3 -m http.server 8015 --directory /opt/legacy-gw
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now legacy-gw >/dev/null 2>&1
wait_for_port 8015

write_unit gateway <<EOF
[Unit]
Description=API gateway
After=network.target

[Service]
User=gateway
Environment=NAME=gateway PORT=8015
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now gateway >/dev/null 2>&1 || true
