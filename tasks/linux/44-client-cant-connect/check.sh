#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-44
. "$(dirname "$0")/../../../lib/check.sh"

since=$(date '+%Y-%m-%d %H:%M:%S')
sleep 4
dest_ok() { [[ $(answer_get dest) =~ ^(127\.0\.0\.1|localhost):8440$ ]]; }
sync_ok() { journalctl -u order-sync --since "$since" --no-pager -q -o cat | grep -q 'sync ok'; }
api_got() { journalctl -u orders-api --since "$since" --no-pager -q -o cat | grep -q 'GET /health'; }

check "в ответе адрес, куда ходил клиент" dest_ok
check "order-sync активен" systemctl is-active -q order-sync
check "в логе order-sync есть sync ok" sync_ok
check "orders-api получает запросы" api_got
check "orders-api на прежнем порту 8044" port_listening 8044
finish
