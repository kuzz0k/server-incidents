#!/usr/bin/env bash
set -euo pipefail
TASK_ID=postgres-01
. "$(dirname "$0")/../../../lib/common.sh"

D=$(pg_dir)
psql_su -c "DROP DATABASE IF EXISTS shopdb WITH (FORCE)" 2>/dev/null || psql_su -c "DROP DATABASE IF EXISTS shopdb"
psql_su -c "DROP ROLE IF EXISTS shop"
sed -i -E '/^\s*host\S*\s+\S+\s+shop\s/d' "$D/pg_hba.conf"

grep -Eq "^\s*include_dir\s*=\s*'conf.d'" "$D/postgresql.conf" || echo "include_dir = 'conf.d'" >> "$D/postgresql.conf"
mkdir -p "$D/conf.d"
cat > "$D/conf.d/90-listen.conf" <<'EOF'
# security: do not expose PostgreSQL to the network (SEC-102)
listen_addresses = 'localhost'
EOF

line=$(grep -nEv '^\s*(#|$)' "$D/pg_hba.conf" | head -1 | cut -d: -f1)
sed -i "${line}i host    all             shop            0.0.0.0/0               reject" "$D/pg_hba.conf"
chown -R postgres:postgres "$D/conf.d"
pg_restart

psql_su <<'SQL'
CREATE ROLE shop NOLOGIN PASSWORD 'Shop-Pass-2026';
CREATE DATABASE shopdb;
\c shopdb
CREATE SCHEMA shop;
CREATE TABLE shop.orders (id serial PRIMARY KEY, customer text NOT NULL, total numeric(10,2) NOT NULL, created_at timestamptz DEFAULT now());
INSERT INTO shop.orders (customer, total) SELECT 'customer-' || g, (random() * 500)::numeric(10,2) FROM generate_series(1, 100) g;
REVOKE ALL ON SCHEMA shop FROM PUBLIC;
SQL
