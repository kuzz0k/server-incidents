#!/usr/bin/env bash
# Эталонное решение linux-03 (для tests/selftest.sh)
set -euo pipefail
find /var/lib/sessions/store -type f -mtime +0 -delete
