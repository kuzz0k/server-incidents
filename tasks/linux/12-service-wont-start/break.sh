#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-12
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit orders
ensure_user orders
rm -rf /etc/orders
cat > /etc/default/orders <<'EOF'
NAME=orders
PORT=8012
DB_DSN=postgres://orders@db.internal/orders
EOF

write_unit orders <<EOF
[Unit]
Description=Orders API
After=network.target

[Service]
User=orders
EnvironmentFile=/etc/orders/orders.env
Environment=REQUIRE=DB_DSN
ExecStart=/usr/bin/python $WEBAPP
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl start orders >/dev/null 2>&1 || true
