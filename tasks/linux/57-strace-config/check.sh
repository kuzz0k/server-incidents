#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-57
. "$(dirname "$0")/../../../lib/check.sh"

check "geo-api активен и стабилен 5 с" service_stable geo-api 5
check_http "GET :8057/health → 200" 200 http://127.0.0.1:8057/health
check "конфиг лежит там, где его ищет программа, содержимое прежнее" \
  bash -c "[[ \$(sha256sum < /etc/geo/geo-api.conf | cut -d' ' -f1) == \$(cat $TASK_VAR/conf.sha256) ]]"
finish
