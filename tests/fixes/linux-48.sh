#!/usr/bin/env bash
# Эталонное решение linux-48 (для tests/selftest.sh)
set -euo pipefail
mkdir -p /root/answers
echo "state=T" > /root/answers/linux-48.txt
kill -CONT "$(systemctl show -p MainPID --value quotes-api)"
sleep 1
