#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-12
. "$(dirname "$0")/../../../lib/check.sh"

check "orders.service активен" systemctl is-active -q orders
check "orders.service в автозагрузке" systemctl is-enabled -q orders
check_http "GET /health → 200" 200 http://127.0.0.1:8012/health
check "настройки берутся из /etc/default/orders" bash -c "systemctl cat orders | grep -Eq '^EnvironmentFile=-?/etc/default/orders'"
finish
