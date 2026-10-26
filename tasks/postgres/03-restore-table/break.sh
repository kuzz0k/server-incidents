#!/usr/bin/env bash
set -euo pipefail
TASK_ID=postgres-03
. "$(dirname "$0")/../../../lib/common.sh"

psql_su -c "DROP DATABASE IF EXISTS crm"
psql_su -c "CREATE DATABASE crm"
psql_su -d crm <<'SQL'
CREATE TABLE customers (id serial PRIMARY KEY, name text NOT NULL, created_at timestamptz DEFAULT now());
CREATE TABLE deals (
  id serial PRIMARY KEY,
  customer_id int NOT NULL REFERENCES customers(id),
  amount numeric(10,2) NOT NULL,
  stage text NOT NULL
);
INSERT INTO customers (name) SELECT 'Customer ' || g FROM generate_series(1, 500) g;
INSERT INTO deals (customer_id, amount, stage)
SELECT 1 + (g % 500), round((random() * 10000)::numeric, 2), (ARRAY['lead', 'won', 'lost'])[1 + g % 3]
FROM generate_series(1, 2000) g;
SQL
psql_su -d crm -c "SELECT count(*) || ' ' || sum(amount) FROM deals" > "$TASK_VAR/deals.expected"

rm -rf /var/backups/postgres
install -d -o postgres -g postgres /var/backups/postgres
dump="/var/backups/postgres/crm-$(date -d yesterday +%F).dump"
(cd / && sudo -u postgres pg_dump -Fc -d crm -f "$dump")

psql_su -d crm <<'SQL'
INSERT INTO customers (name) SELECT 'New customer ' || g FROM generate_series(1, 25) g;
DROP TABLE deals;
SQL
