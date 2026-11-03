#!/usr/bin/env bash
# postgres-03: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=postgres-03
. "$(dirname "$0")/../../../lib/common.sh"

psql_su -c "DROP DATABASE IF EXISTS crm WITH (FORCE)" >/dev/null 2>&1 || psql_su -c "DROP DATABASE IF EXISTS crm" >/dev/null 2>&1
rm -rf /var/backups/postgres
exit 0
