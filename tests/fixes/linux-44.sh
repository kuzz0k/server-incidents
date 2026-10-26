#!/usr/bin/env bash
# Эталонное решение linux-44 (для tests/selftest.sh)
set -euo pipefail
mkdir -p /root/answers
echo "dest=127.0.0.1:8440" > /root/answers/linux-44.txt
sed -i 's/^API_PORT=.*/API_PORT=8044/' /etc/default/order-sync
systemctl restart order-sync
sleep 2
