#!/usr/bin/env bash
set -euo pipefail
TASK_ID=postgres-04
. "$(dirname "$0")/../../../lib/common.sh"

D=$(pg_dir)
remove_unit report-worker
ensure_user report
psql_su -c "DROP DATABASE IF EXISTS reportsdb"
psql_su -c "DROP ROLE IF EXISTS report"
psql_su -c "DROP ROLE IF EXISTS app"

mkdir -p "$D/conf.d"
echo "max_connections = 20" > "$D/conf.d/90-connections.conf"
chown postgres:postgres "$D/conf.d/90-connections.conf"
pg_restart

psql_su <<'SQL'
CREATE ROLE app LOGIN PASSWORD 'App-Pass-2026';
CREATE ROLE report LOGIN;
CREATE DATABASE reportsdb OWNER app;
\c reportsdb
CREATE TABLE reports (id serial PRIMARY KEY, title text, created_at timestamptz DEFAULT now());
INSERT INTO reports (title) SELECT 'report ' || g FROM generate_series(1, 1000) g;
ALTER TABLE reports OWNER TO app;
GRANT SELECT ON reports TO report;
SQL

mkdir -p "$TRAINER_LIB"
cat > "$TRAINER_LIB/report-worker.sh" <<'EOF'
#!/bin/bash
# Воркер отчётов: держит «пул» соединений к базе (каждое — в открытой транзакции)
for i in $(seq 1 17); do
  (
    while true; do
      { echo "BEGIN; SELECT count(*) FROM reports;"; sleep 3600; } | psql -X -q -d reportsdb >/dev/null 2>&1
      sleep 5
    done
  ) &
done
wait
EOF
chmod 0755 "$TRAINER_LIB/report-worker.sh"

write_unit report-worker <<EOF
[Unit]
Description=Report worker
After=postgresql.service

[Service]
User=report
WorkingDirectory=/
ExecStart=$TRAINER_LIB/report-worker.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now report-worker >/dev/null 2>&1
sleep 5
