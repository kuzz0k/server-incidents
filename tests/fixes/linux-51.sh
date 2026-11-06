#!/usr/bin/env bash
# Эталонное решение linux-51 (для tests/selftest.sh)
set -euo pipefail
line=$(journalctl -u payment-gw -p err -o short-iso --no-pager -q | grep -m1 'order_id=')
mkdir -p /root/answers
{
  echo "error_order=$(grep -oE 'order_id=ORD-[0-9]+' <<<"$line" | cut -d= -f2)"
  echo "error_time=$(sed -E 's/^[0-9-]+T([0-9:]+).*/\1/' <<<"$line")"
  echo "restarts=$(systemctl show -p NRestarts --value payment-gw)"
  echo "exit_code=$(journalctl -u payment-gw --no-pager -q | grep -oE 'status=[0-9]+' | head -1 | cut -d= -f2)"
} > /root/answers/linux-51.txt
