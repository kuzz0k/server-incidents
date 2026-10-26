#!/usr/bin/env bash
# Эталонное решение linux-12 (для tests/selftest.sh)
set -euo pipefail
sed -i 's|^EnvironmentFile=.*|EnvironmentFile=/etc/default/orders|; s|/usr/bin/python |/usr/bin/python3 |' /etc/systemd/system/orders.service
systemctl daemon-reload
systemctl enable --now orders
sleep 2
