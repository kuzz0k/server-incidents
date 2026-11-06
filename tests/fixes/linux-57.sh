#!/usr/bin/env bash
# Эталонное решение linux-57 (для tests/selftest.sh)
set -euo pipefail
mkdir -p /etc/geo
cp /etc/geo-api.conf /etc/geo/geo-api.conf
systemctl reset-failed geo-api || true
systemctl restart geo-api
sleep 2
