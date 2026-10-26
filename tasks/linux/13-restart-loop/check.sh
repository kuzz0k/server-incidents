#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-13
. "$(dirname "$0")/../../../lib/check.sh"

CONF=/etc/catalog/catalog.conf
check "catalog активен и не перезапускается 5 с" service_stable catalog 5
check_http "GET /health → 200" 200 http://127.0.0.1:8013/health
check "DB_HOST=10.0.0.5" grep -Eq '^\s*DB_HOST\s*=\s*10\.0\.0\.5\s*$' "$CONF"
check "CACHE_TTL=300" grep -Eiq '^\s*CACHE_TTL\s*=\s*300\s*$' "$CONF"
check "юнит не изменён (Restart=always)" bash -c "[[ \$(systemctl show -p Restart --value catalog) == always ]]"
finish
