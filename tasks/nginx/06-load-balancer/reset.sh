#!/usr/bin/env bash
# nginx-06: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=nginx-06
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit shop-a shop-b shop-c
nginx_remove_site shop-lb

if nginx -t >/dev/null 2>&1; then nginx_apply || systemctl restart nginx; else warn "nginx -t с ошибкой после отката — проверь конфиг"; fi
exit 0
