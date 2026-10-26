#!/usr/bin/env bash
# Эталонное решение linux-06 (для tests/selftest.sh)
set -euo pipefail
sed -i '/^\/var\/log\/billing/a\    su billing billing' /etc/logrotate.d/billing
logrotate -d /etc/logrotate.d/billing
