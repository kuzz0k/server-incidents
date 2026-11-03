#!/usr/bin/env bash
# postgres-02: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=postgres-02
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit analytics-dashboard
psql_su -c "DROP DATABASE IF EXISTS analytics WITH (FORCE)" >/dev/null 2>&1 || psql_su -c "DROP DATABASE IF EXISTS analytics" >/dev/null 2>&1
rm -f "$(pg_dir)/conf.d/90-slowlog.conf" "$TRAINER_LIB/analytics-dashboard.sh"
psql_su -c "SELECT pg_reload_conf()" >/dev/null 2>&1
exit 0
