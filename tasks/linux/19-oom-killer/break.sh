#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-19
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit imagecache
ensure_user imagecache
cat > /etc/imagecache.conf <<'EOF'
# imagecache settings
NAME=imagecache
PORT=8019
# in-memory cache size, MB
CACHE_MB=128
EOF

write_unit imagecache <<EOF
[Unit]
Description=Image cache service
After=network.target
StartLimitIntervalSec=0

[Service]
User=imagecache
Environment=CONFIG=/etc/imagecache.conf
ExecStart=/usr/bin/python3 $WEBAPP
MemoryMax=64M
MemorySwapMax=0
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now imagecache >/dev/null 2>&1 || true
