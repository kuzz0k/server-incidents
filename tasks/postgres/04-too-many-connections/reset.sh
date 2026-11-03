#!/usr/bin/env bash
# postgres-04: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=postgres-04
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit report-worker
psql_su -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE usename = 'report'" >/dev/null 2>&1
psql_su -c "DROP DATABASE IF EXISTS reportsdb WITH (FORCE)" >/dev/null 2>&1 || psql_su -c "DROP DATABASE IF EXISTS reportsdb" >/dev/null 2>&1
psql_su -c "DROP ROLE IF EXISTS report" >/dev/null 2>&1
psql_su -c "DROP ROLE IF EXISTS app" >/dev/null 2>&1
remove_user report
D=$(pg_dir)
rm -f "$D/conf.d/90-connections.conf" "$TRAINER_LIB/report-worker.sh"
restore_original "$D/postgresql.conf"
pg_restart
exit 0
