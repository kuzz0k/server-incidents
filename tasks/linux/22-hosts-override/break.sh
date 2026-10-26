#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-22
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit payments-api
ensure_user payments
hosts_drop 'api\.payments\.internal'
cat >> /etc/hosts <<'EOF'

# payments API
127.0.0.21   api.payments.internal
127.0.0.22   api.payments.internal payments-api
EOF

write_unit payments-api <<EOF
[Unit]
Description=Payments API
After=network.target

[Service]
User=payments
Environment=NAME=payments-api BIND=127.0.0.22 PORT=8022
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now payments-api >/dev/null 2>&1
wait_for_port 8022
