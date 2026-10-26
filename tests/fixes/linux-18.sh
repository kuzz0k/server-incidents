#!/usr/bin/env bash
# Эталонное решение linux-18 (для tests/selftest.sh)
set -euo pipefail
mkdir -p /etc/systemd/system/chat-server.service.d
printf '[Service]\nLimitNOFILE=65536\n' > /etc/systemd/system/chat-server.service.d/override.conf
systemctl daemon-reload
systemctl reset-failed chat-server || true
systemctl restart chat-server
sleep 2
