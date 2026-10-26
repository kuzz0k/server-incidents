#!/usr/bin/env bash
# Эталонное решение linux-01 (для tests/selftest.sh)
set -euo pipefail
truncate -s 0 /var/lib/reports/logs/debug.log
rm -f /var/lib/reports/logs/debug.log.1 /var/lib/reports/tmp/*.tmp
