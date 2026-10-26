#!/usr/bin/env bash
set -uo pipefail
TASK_ID=nginx-02
. "$(dirname "$0")/../../../lib/check.sh"


check "nginx -t без ошибок" nginx -t
check "nginx активен" systemctl is-active -q nginx
check_body "лендинг на 8102" "Autumn sale landing" http://127.0.0.1:8102/
check "ответ от nginx без версии в Server" bash -c "curl -sI --max-time 5 http://127.0.0.1:8102/ | tr -d '\r' | grep -qx 'Server: nginx'"
check "есть заголовок X-Frame-Options" bash -c "curl -sI --max-time 5 http://127.0.0.1:8102/ | grep -qi '^X-Frame-Options:'"
finish
