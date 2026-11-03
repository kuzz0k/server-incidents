#!/usr/bin/env bash
# postgres-01: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=postgres-01
. "$(dirname "$0")/../../../lib/common.sh"

psql_su -c "DROP DATABASE IF EXISTS shopdb WITH (FORCE)" >/dev/null 2>&1 || psql_su -c "DROP DATABASE IF EXISTS shopdb" >/dev/null 2>&1
psql_su -c "DROP ROLE IF EXISTS shop" >/dev/null 2>&1
D=$(pg_dir)
rm -f "$D/conf.d/90-listen.conf"
restore_original "$D/pg_hba.conf"
restore_original "$D/postgresql.conf"
pg_restart
exit 0
