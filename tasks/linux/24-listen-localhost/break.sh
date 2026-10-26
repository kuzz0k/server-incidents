#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-24
. "$(dirname "$0")/../../../lib/common.sh"

[[ -n $(primary_ip) ]] || die "Не удалось определить основной IP сервера"
install_webapp
remove_unit metrics-api
cat > /etc/metrics-api.conf <<'EOF'
NAME=metrics-api
BIND=127.0.0.1
PORT=8024
EOF

write_unit metrics-api <<EOF
[Unit]
Description=Metrics API
After=network.target

[Service]
DynamicUser=yes
Environment=CONFIG=/etc/metrics-api.conf
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now metrics-api >/dev/null 2>&1
wait_for_port 8024
