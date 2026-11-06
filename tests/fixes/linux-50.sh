#!/usr/bin/env bash
# Эталонное решение linux-50 (для tests/selftest.sh)
set -euo pipefail
mkdir -p /etc/systemd/system/pricing-api.service.d
printf '[Service]\nCPUQuota=50%%\n' > /etc/systemd/system/pricing-api.service.d/override.conf
systemctl daemon-reload
sleep 1
