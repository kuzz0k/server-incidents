#!/usr/bin/env bash
# Эталонное решение linux-52 (для tests/selftest.sh)
set -euo pipefail
sed -i 's|from="10.20.0.0/16"|from="10.20.0.0/16,127.0.0.1"|' /home/reporter/.ssh/authorized_keys
chage -E -1 reporter
