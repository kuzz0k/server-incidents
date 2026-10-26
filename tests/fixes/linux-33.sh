#!/usr/bin/env bash
# Эталонное решение linux-33 (для tests/selftest.sh)
set -euo pipefail
systemctl disable --now report-sync
