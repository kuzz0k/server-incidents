#!/usr/bin/env bash
# Эталонное решение postgres-01 (для tests/selftest.sh)
set -euo pipefail
. "$(dirname "$0")/../../lib/common.sh"
D=$(pg_dir)
sed -i "s/^listen_addresses.*/listen_addresses = '*'/" "$D/conf.d/90-listen.conf"
sed -i -E '/^\s*host\s.*shop.*reject/d' "$D/pg_hba.conf"
echo "host    shopdb          shop            0.0.0.0/0               scram-sha-256" >> "$D/pg_hba.conf"
pg_restart
psql_su -d shopdb <<'SQL'
ALTER ROLE shop LOGIN;
GRANT USAGE ON SCHEMA shop TO shop;
GRANT SELECT ON ALL TABLES IN SCHEMA shop TO shop;
SQL
