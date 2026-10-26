#!/usr/bin/env bash
# Эталонное решение linux-15 (для tests/selftest.sh)
set -euo pipefail
systemctl disable --now legacy-gw
systemctl restart gateway
sleep 2
