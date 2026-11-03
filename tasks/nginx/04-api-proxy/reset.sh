#!/usr/bin/env bash
# nginx-04: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=nginx-04
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit api-backend
nginx_remove_site api

if nginx -t >/dev/null 2>&1; then nginx_apply || systemctl restart nginx; else warn "nginx -t с ошибкой после отката — проверь конфиг"; fi
exit 0
