#!/usr/bin/env bash
# Эталонное решение linux-23 (для tests/selftest.sh)
set -euo pipefail
sed -i '/--dport 8023/d' /usr/local/sbin/fw-hardening.sh
systemctl restart fw-hardening
