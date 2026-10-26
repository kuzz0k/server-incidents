#!/usr/bin/env bash
# Эталонное решение linux-34 (для tests/selftest.sh)
set -euo pipefail
mkdir -p /root/answers /etc/systemd/system/search-reindex.service.d
echo "unit=search-reindex.service" > /root/answers/linux-34.txt
printf '[Service]\nIOSchedulingClass=idle\nNice=19\n' > /etc/systemd/system/search-reindex.service.d/override.conf
systemctl daemon-reload
systemctl restart search-reindex
sleep 1
