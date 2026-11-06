#!/usr/bin/env bash
# Эталонное решение linux-55 (для tests/selftest.sh)
set -euo pipefail
mkdir -p /etc/systemd/system/sessiond.service.d
printf '[Service]\nRuntimeDirectory=sessiond\nRuntimeDirectoryMode=0750\n' > /etc/systemd/system/sessiond.service.d/override.conf
systemctl daemon-reload
systemctl restart sessiond
sleep 2
