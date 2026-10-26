#!/usr/bin/env bash
# Эталонное решение linux-07 (для tests/selftest.sh)
set -euo pipefail
chown root:inventory /etc/inventory/config.ini
chmod 640 /etc/inventory/config.ini
chown inventory:inventory /var/lib/inventory
chmod 750 /var/lib/inventory
systemctl reset-failed inventory || true
systemctl restart inventory
sleep 2
