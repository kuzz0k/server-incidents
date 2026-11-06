#!/usr/bin/env bash
# Эталонное решение linux-58 (для tests/selftest.sh)
set -euo pipefail
echo /opt/vendor/lib > /etc/ld.so.conf.d/vendor.conf
ldconfig
systemctl reset-failed vendor-scanner || true
systemctl restart vendor-scanner
sleep 2
