#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-18
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit chat-server
ensure_user chat
cat > /etc/security/limits.d/90-chat.conf <<'EOF'
# raise limits for chat-server (ticket OPS-1182)
chat soft nofile 65536
chat hard nofile 65536
EOF

write_unit chat-server <<EOF
[Unit]
Description=Chat server
After=network.target

[Service]
User=chat
Environment=NAME=chat-server PORT=8018 OPEN_FDS=300
ExecStart=/usr/bin/python3 $WEBAPP
LimitNOFILE=128
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now chat-server >/dev/null 2>&1 || true
