#!/usr/bin/env bash
# Эталонное решение linux-16 (для tests/selftest.sh)
set -euo pipefail
sed -i 's/^POLL_INTERVAL=.*/POLL_INTERVAL=2/' /etc/thumbnailer.conf
systemctl restart thumbnailer
sleep 1
