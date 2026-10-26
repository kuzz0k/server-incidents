#!/usr/bin/env bash
# Эталонное решение postgres-02 (для tests/selftest.sh)
set -euo pipefail
. "$(dirname "$0")/../../lib/common.sh"
psql_su -d analytics -c "CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_events_user_created ON events (user_id, created_at DESC)"
psql_su -d analytics -c "ANALYZE events"
