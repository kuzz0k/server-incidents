#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-07
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit inventory
ensure_user inventory
rm -rf /etc/inventory /var/lib/inventory
install -d -m 0755 /etc/inventory /var/lib/inventory
cat > /etc/inventory/config.ini <<'EOF'
# inventory service
NAME=inventory
PORT=8007
DB_DSN=postgres://inventory:S3cr3t-Inv-2026@db.internal:5432/inventory
DATA_DIR=/var/lib/inventory
EOF
chown root:root /etc/inventory/config.ini
chmod 0600 /etc/inventory/config.ini

write_unit inventory <<EOF
[Unit]
Description=Inventory service
After=network.target

[Service]
User=inventory
Environment=CONFIG=/etc/inventory/config.ini REQUIRE=DB_DSN
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now inventory >/dev/null 2>&1 || true
