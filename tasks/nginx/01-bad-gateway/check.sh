#!/usr/bin/env bash
set -uo pipefail
TASK_ID=nginx-01
. "$(dirname "$0")/../../../lib/check.sh"

check "nginx -t без ошибок" nginx -t
check "nginx активен" systemctl is-active -q nginx
check_http "GET http://127.0.0.1:8101/ → 200" 200 http://127.0.0.1:8101/
check_body "ответ от shop backend" "shop backend v2" http://127.0.0.1:8101/
check "бэкенд по-прежнему на 9110" bash -c "ss -Hltn 'sport = :9110' | grep -q ."
finish
