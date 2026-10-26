#!/usr/bin/env bash
set -euo pipefail
TASK_ID=postgres-02
. "$(dirname "$0")/../../../lib/common.sh"

D=$(pg_dir)
remove_unit analytics-dashboard
psql_su -c "DROP DATABASE IF EXISTS analytics"
psql_su -c "CREATE DATABASE analytics"
info "Генерирую 2 млн строк…"
psql_su -d analytics <<'SQL'
CREATE TABLE events (
  id bigserial PRIMARY KEY,
  user_id int NOT NULL,
  type text NOT NULL,
  created_at timestamptz NOT NULL,
  payload text
);
INSERT INTO events (user_id, type, created_at, payload)
SELECT (random() * 49999)::int + 1,
       (ARRAY['view', 'click', 'purchase', 'login'])[1 + (random() * 3)::int],
       now() - random() * interval '365 days',
       md5(g::text)
FROM generate_series(1, 2000000) g;
ANALYZE events;
SQL

mkdir -p "$D/conf.d"
echo "log_min_duration_statement = 100" > "$D/conf.d/90-slowlog.conf"
chown postgres:postgres "$D/conf.d/90-slowlog.conf"
psql_su -c "SELECT pg_reload_conf()" >/dev/null

mkdir -p "$TRAINER_LIB"
cat > "$TRAINER_LIB/analytics-dashboard.sh" <<'EOF'
#!/bin/bash
# Дашборд аналитики: каждые 2 секунды запрашивает последние события пользователя
while true; do
  u=$((RANDOM % 50000 + 1))
  psql -X -q -d analytics -c "SELECT id, type, created_at FROM events WHERE user_id = $u AND created_at > now() - interval '30 days' ORDER BY created_at DESC LIMIT 20" >/dev/null
  sleep 2
done
EOF
chmod 0755 "$TRAINER_LIB/analytics-dashboard.sh"

write_unit analytics-dashboard <<EOF
[Unit]
Description=Analytics dashboard backend
After=postgresql.service

[Service]
User=postgres
WorkingDirectory=/
ExecStart=$TRAINER_LIB/analytics-dashboard.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now analytics-dashboard >/dev/null 2>&1
