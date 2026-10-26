#!/usr/bin/env bash
# Эталонное решение linux-24 (для tests/selftest.sh)
set -euo pipefail
sed -i 's/^BIND=.*/BIND=0.0.0.0/' /etc/metrics-api.conf
systemctl restart metrics-api
sleep 2
