#!/usr/bin/env bash
# Эталонное решение linux-53 (для tests/selftest.sh)
set -euo pipefail
mkdir -p /etc/systemd/system/report-exporter.service.d
printf '[Service]\nUMask=0027\n' > /etc/systemd/system/report-exporter.service.d/override.conf
systemctl daemon-reload
systemctl restart report-exporter
chmod g+r /srv/reports/*.txt
sleep 3
