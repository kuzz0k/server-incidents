#!/usr/bin/env bash
# Эталонное решение linux-59 (для tests/selftest.sh)
set -euo pipefail
mkdir -p /root/answers /etc/systemd/system/cache-warmer.service.d
echo "unit=cache-warmer.service" > /root/answers/linux-59.txt
printf '[Service]\nMemoryHigh=250M\nMemoryMax=300M\nRestart=on-failure\n' > /etc/systemd/system/cache-warmer.service.d/override.conf
systemctl daemon-reload
systemctl restart cache-warmer
sleep 2
