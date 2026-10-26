#!/usr/bin/env bash
# Эталонное решение linux-11 (для tests/selftest.sh)
set -euo pipefail
chattr -i /etc/payment/config.yml
/opt/payment/deploy.sh
chattr +i /etc/payment/config.yml
