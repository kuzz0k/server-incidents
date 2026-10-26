#!/usr/bin/env bash
set -uo pipefail
TASK_ID=postgres-04
. "$(dirname "$0")/../../../lib/check.sh"

app_connects() { [[ $(PGPASSWORD=App-Pass-2026 PGCONNECT_TIMEOUT=5 psql -X -qAt -h 127.0.0.1 -U app -d reportsdb -c 'select 1' 2>/dev/null) == 1 ]]; }
limit_ok() { local n; n=$(psql_su -c "SELECT rolconnlimit FROM pg_roles WHERE rolname = 'report'"); [[ -n $n ]] && (( n >= 1 && n <= 5 )); }
report_conns() { (( $(psql_su -c "SELECT count(*) FROM pg_stat_activity WHERE usename = 'report'") <= 5 )); }

check "app подключается к reportsdb" app_connects
check "у роли report CONNECTION LIMIT от 1 до 5" limit_ok
check "у report открыто не больше 5 соединений" report_conns
check "max_connections = 20" bash -c "[[ \$(cd / && sudo -u postgres psql -XqAt -c 'show max_connections') == 20 ]]"
check "report-worker активен" systemctl is-active -q report-worker
finish
