#!/usr/bin/env bash
# Эталонное решение postgres-04 (для tests/selftest.sh)
set -euo pipefail
. "$(dirname "$0")/../../lib/common.sh"
psql_su <<'SQL'
ALTER ROLE report CONNECTION LIMIT 5;
ALTER ROLE report SET idle_in_transaction_session_timeout = '5min';
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE usename = 'report';
SQL
sleep 8
