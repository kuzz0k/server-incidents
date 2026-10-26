#!/usr/bin/env bash
# Эталонное решение linux-02 (для tests/selftest.sh)
set -euo pipefail
systemctl restart metrics-agent
sleep 3
