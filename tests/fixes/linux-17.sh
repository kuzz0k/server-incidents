#!/usr/bin/env bash
# Эталонное решение linux-17 (для tests/selftest.sh)
set -euo pipefail
ppid=$(ps -eo stat=,ppid=,comm= | awk '$1 ~ /^Z/ && $3 == "batch-worker" {print $2; exit}')
mkdir -p /root/answers
echo "parent_pid=$ppid" > /root/answers/linux-17.txt
kill "$ppid"
sleep 1
