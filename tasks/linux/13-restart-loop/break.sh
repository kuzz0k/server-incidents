#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-13
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit catalog
ensure_user catalog
mkdir -p /etc/catalog
cat > /etc/catalog/catalog.conf <<'EOF'
# catalog service config
NAME=catalog
PORT=8013
cache_ttl 300
DB_HSOT=10.0.0.5
LOG_LEVEL=info
EOF
chmod 0644 /etc/catalog/catalog.conf

write_unit catalog <<EOF
[Unit]
Description=Catalog service
After=network.target
StartLimitIntervalSec=30
StartLimitBurst=5

[Service]
User=catalog
Environment=CONFIG=/etc/catalog/catalog.conf REQUIRE=DB_HOST,CACHE_TTL
ExecStart=/usr/bin/python3 $WEBAPP
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now catalog >/dev/null 2>&1 || true
sleep 8
