#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-24
. "$(dirname "$0")/../../../lib/check.sh"

ip=$(primary_ip)
check "metrics-api активен" systemctl is-active -q metrics-api
check_http "curl http://$ip:8024/health → 200" 200 "http://$ip:8024/health"
finish
